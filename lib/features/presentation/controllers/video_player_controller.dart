import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:dio/dio.dart';
import '../../../utils/constants/api_endpoints.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class VideoItem {
  final int id;
  final String title;
  final String url;
  final String duration;
  final String? description;
  final String? thumbnail;
  final int moduleId;
  final String moduleName;

  VideoItem({
    required this.id,
    required this.title,
    required this.url,
    required this.duration,
    this.description,
    this.thumbnail,
    required this.moduleId,
    required this.moduleName,
  });
}

class ModuleVideoStructure {
  final int id;
  final String title;
  final List<VideoItem> videos;
  final bool isExpanded;

  ModuleVideoStructure({
    required this.id,
    required this.title,
    required this.videos,
    this.isExpanded = false,
  });

  ModuleVideoStructure copyWith({
    int? id,
    String? title,
    List<VideoItem>? videos,
    bool? isExpanded,
  }) {
    return ModuleVideoStructure(
      id: id ?? this.id,
      title: title ?? this.title,
      videos: videos ?? this.videos,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class VideoPlayerScreenController extends GetxController {
  // Media Kit player and controller
  late final Player player;
  VideoController? videoController;

  // Remote source for API calls
  late RemoteSource _remoteSource;

  // Observable variables
  var isLoading = true.obs;
  var hasError = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;
  var isPlaylistVisible = true.obs;
  var currentVideoIndex = 0.obs;
  var currentVideo = Rx<VideoItem?>(null);
  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var currentVolume = 1.0.obs;

  // Timer for hiding controls
  Timer? _controlsTimer;
  Timer? _volumeSliderTimer;

  // Position tracking for milestones
  Duration _lastApiUpdatePosition = Duration.zero;
  static const Duration _apiUpdateInterval = Duration(seconds: 30);

  // Progress tracking variables
  var hasPurchased = false.obs;
  var purchaseId = 0.obs;
  var currentTopicId = 0.obs;

  // Playlist data
  var playlist = <VideoItem>[].obs;
  var moduleStructure = <ModuleVideoStructure>[].obs;
  
  // Stream subscriptions
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<bool>? _bufferingSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize Media Kit player with configuration
    player = Player(
      configuration: PlayerConfiguration(
        title: 'Video Player',
        bufferSize: 32 * 1024 * 1024, // 32MB buffer
        logLevel: MPVLogLevel.warn,
      ),
    );
    
    // Initialize video controller with configuration  
    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        width: 640,
        height: 360,
      ),
    );
    
    // Initialize remote source
    _remoteSource = RemoteSourceImpl(dio: Get.find<DioClient>());

    _setupPlayerListeners();

    // Get navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      // Initialize progress tracking from navigation arguments
      hasPurchased.value = args['hasPurchased'] ?? false;
      purchaseId.value = args['purchaseId'] ?? 0;
      currentTopicId.value = args['currentTopicId'] ?? 0;

      if (args.containsKey('syllabus') && args.containsKey('currentTopicId')) {
        _initializeFromServerData(args);
      } else {
        _showNoVideosError();
      }
    } else {
      _showNoVideosError();
    }
  }

  @override
  void onClose() {
    _cancelSubscriptions();
    _disposePlayer();
    _controlsTimer?.cancel();
    _volumeSliderTimer?.cancel();
    super.onClose();
  }

  // Cancel all stream subscriptions
  void _cancelSubscriptions() {
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingSubscription?.cancel();
  }

  // Properly dispose player and controller
  Future<void> _disposePlayer() async {
    await player.dispose();
    videoController = null;
  }

  // Initialize playlist from server data
  void _initializeFromServerData(Map<String, dynamic> args) {
    try {
      final syllabus = args['syllabus'];
      final currentTopicId = args['currentTopicId'] as int?;

      List<VideoItem> serverPlaylist = [];
      List<ModuleVideoStructure> modules = [];
      int currentVideoIndex = 0;
      int videoIndex = 0;

      if (syllabus != null && syllabus['modules'] != null) {
        for (var moduleData in syllabus['modules']) {
          final moduleId = moduleData['id'] ?? 0;
          final moduleName = moduleData['module_title'] ?? 'Unknown Module';
          List<VideoItem> moduleVideos = [];

          if (moduleData['topics'] != null) {
            for (var topic in moduleData['topics']) {
              final topicId = topic['id'];
              final topicTitle = topic['topic_title'] ?? 'Unknown Topic';
              final videoUrl = topic['video_url'] ?? '';
              final videoDuration = topic['video_duration'] ?? '00:00';

              if (videoUrl.isNotEmpty) {
                String fullVideoUrl = videoUrl;
                if (!videoUrl.startsWith('http')) {
                  fullVideoUrl = '${ApiEndpoints.baseUrl}$videoUrl';
                }

                final videoItem = VideoItem(
                  id: topicId,
                  title: topicTitle,
                  url: fullVideoUrl,
                  duration: videoDuration,
                  description: 'Module: $moduleName',
                  moduleId: moduleId,
                  moduleName: moduleName,
                );

                serverPlaylist.add(videoItem);
                moduleVideos.add(videoItem);
                if (topicId == currentTopicId) {
                  currentVideoIndex = videoIndex;
                }
                videoIndex++;
              }
            }
          }

          // Add module to structure if it has videos
          if (moduleVideos.isNotEmpty) {
            modules.add(
              ModuleVideoStructure(
                id: moduleId,
                title: moduleName,
                videos: moduleVideos,
                isExpanded: moduleVideos.any(
                  (video) => video.id == currentTopicId,
                ),
              ),
            );
          }
        }
      }

      if (serverPlaylist.isNotEmpty) {
        playlist.value = serverPlaylist;
        moduleStructure.value = modules;
        currentVideo.value = playlist[currentVideoIndex];
        _loadVideoAtIndex(currentVideoIndex);
      } else {
        _showNoVideosError();
      }
    } catch (e) {
      _showNoVideosError();
    }
  }

  // Show error when no videos are available
  void _showNoVideosError() {
    hasError.value = true;
    isLoading.value = false;
    playlist.value = [];
    moduleStructure.value = [];
    currentVideo.value = null;
  }

  // Toggle module expansion
  void toggleModuleExpansion(int moduleId) {
    final updatedModules =
        moduleStructure.map((module) {
          if (module.id == moduleId) {
            return module.copyWith(isExpanded: !module.isExpanded);
          }
          return module;
        }).toList();

    moduleStructure.value = updatedModules;
  }

  // Load video at specific index
  Future<void> _loadVideoAtIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      currentVideoIndex.value = index;
      currentVideo.value = playlist[index];

      currentPosition.value = Duration.zero;
      totalDuration.value = Duration.zero;

      // Open media with Media Kit
      await player.open(
        Media(playlist[index].url),
        play: false, // Don't auto-play, we'll play manually after buffering
      );

      // Set volume
      await player.setVolume(100.0);
      currentVolume.value = 1.0;

      // Wait a bit for video to initialize
      await Future.delayed(Duration(milliseconds: 500));

      // Start playing
      await player.play();
      
      isLoading.value = false;

      debugPrint('✅ Video loaded successfully: ${playlist[index].title}');
    } catch (e) {
      debugPrint('❌ Video loading error: $e');
      hasError.value = true;
      isLoading.value = false;
    }
  }

  // Setup player stream listeners
  void _setupPlayerListeners() {
    // Listen to playing state
    _playingSubscription = player.stream.playing.listen((playing) {
      isPlaying.value = playing;
      debugPrint('🎬 Player state changed - Playing: $playing');
    });

    // Listen to buffering state
    _bufferingSubscription = player.stream.buffering.listen((buffering) {
      debugPrint('📦 Buffering: $buffering');
      if (buffering) {
        isLoading.value = true;
      } else {
        isLoading.value = false;
      }
    });

    // Listen to position changes
    _positionSubscription = player.stream.position.listen((position) {
      currentPosition.value = position;

      // API Update every 30 seconds when playing (for purchased content only)
      if (isPlaying.value &&
          position.inSeconds >=
              _lastApiUpdatePosition.inSeconds + _apiUpdateInterval.inSeconds) {
        print('   - isPlaying: ${isPlaying.value}');
        print('   - hasPurchased: ${hasPurchased.value}');
        print('   - currentTopicId: ${currentTopicId.value}');
        print('   - purchaseId: ${purchaseId.value}');
        print('   - position: ${position.inSeconds}s');

        if (hasPurchased.value &&
            currentTopicId.value > 0 &&
            purchaseId.value > 0) {
          _lastApiUpdatePosition = Duration(
            seconds: (position.inSeconds ~/ 30) * 30,
          );
          _updateProgressToServer(position.inSeconds);
        } else {
          debugPrint('❌ DEBUG: API update blocked - missing purchase requirements');
        }
      }

      // Check for video end and auto-play next
      if (position.inMilliseconds > 0 &&
          totalDuration.value.inMilliseconds > 0 &&
          (position.inMilliseconds >= totalDuration.value.inMilliseconds - 1000)) {
        if (hasNextVideo) {
          playNextVideo();
        }
      }
    });

    // Listen to duration changes
    _durationSubscription = player.stream.duration.listen((duration) {
      totalDuration.value = duration;
      debugPrint('⏱️ Duration set: ${formatDuration(duration)}');
    });
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    await player.playOrPause();
  }

  // Show/Hide controls
  void toggleControls() {
    showControls.value = !showControls.value;

    if (showControls.value) {
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  // Start timer to hide controls
  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(Duration(seconds: 3), () {
      showControls.value = false;
    });
  }

  // Toggle playlist visibility
  void togglePlaylistVisibility() {
    isPlaylistVisible.value = !isPlaylistVisible.value;
  }

  // Play video at specific index
  Future<void> playVideoAtIndex(int index) async {
    await _loadVideoAtIndex(index);
  }

  // Play previous video
  Future<void> playPreviousVideo() async {
    if (hasPreviousVideo) {
      await _loadVideoAtIndex(currentVideoIndex.value - 1);
    }
  }

  // Play next video
  Future<void> playNextVideo() async {
    if (hasNextVideo) {
      await _loadVideoAtIndex(currentVideoIndex.value + 1);
    }
  }

  // Check if has previous video
  bool get hasPreviousVideo => currentVideoIndex.value > 0;

  // Check if has next video
  bool get hasNextVideo => currentVideoIndex.value < playlist.length - 1;

  // Retry video loading with exponential backoff
  int _retryCount = 0;
  static const int _maxRetries = 3;
  
  Future<void> retryVideo() async {
    _retryCount = 0;
    await _retryWithBackoff();
  }
  
  Future<void> _retryWithBackoff() async {
    if (_retryCount >= _maxRetries) {
      debugPrint('❌ Max retry attempts reached');
      hasError.value = true;
      return;
    }
    
    _retryCount++;
    debugPrint('🔄 Retry attempt $_retryCount of $_maxRetries');
    
    // Wait before retrying with exponential backoff
    if (_retryCount > 1) {
      final delaySeconds = _retryCount * 2; // 2, 4, 6 seconds
      debugPrint('⏳ Waiting ${delaySeconds}s before retry...');
      await Future.delayed(Duration(seconds: delaySeconds));
    }
    
    try {
      await _loadVideoAtIndex(currentVideoIndex.value);
      _retryCount = 0; // Reset on success
    } catch (e) {
      debugPrint('❌ Retry failed: $e');
      if (_retryCount < _maxRetries) {
        await _retryWithBackoff();
      } else {
        hasError.value = true;
      }
    }
  }

  // Format duration
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await player.setVolume(clampedVolume * 100.0); // Media Kit uses 0-100 scale
    currentVolume.value = clampedVolume;
  }

  // Mute/Unmute toggle
  Future<void> toggleMute() async {
    if (currentVolume.value > 0) {
      await setVolume(0.0);
    } else {
      await setVolume(0.7);
    }
  }


  // Update progress to server every 30 seconds
  Future<void> _updateProgressToServer(int watchTimeSeconds) async {
    if (!hasPurchased.value ||
        currentTopicId.value <= 0 ||
        purchaseId.value <= 0) {
      return;
    }

    try {
      final response = await _remoteSource.updateLearningProgress(
        topicId: currentTopicId.value,
        purchaseId: purchaseId.value,
        watchTimeSeconds: watchTimeSeconds,
      );

      if (response.success) {
        debugPrint('✅ API: Progress updated successfully!');
      } else {
        debugPrint('❌ API: Progress update failed - ${response.message}');
      }
    } catch (e) {
      debugPrint('❌ API: Failed to update progress: $e');
      if (e is DioException) {
        debugPrint('❌ API: Dio error details: ${e.response?.data}');
      } else {
        debugPrint('❌ API: Non-Dio error: ${e.runtimeType}');
      }
    }
  }
}
