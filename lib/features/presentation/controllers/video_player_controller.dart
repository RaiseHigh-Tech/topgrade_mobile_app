import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? videoPlayerController;

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

  @override
  void onInit() {
    super.onInit();
    // Initialize remote source
    _remoteSource = RemoteSourceImpl(dio: Get.find<DioClient>());

    _configureAudioSession();

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
    _removeVideoPlayerListener();
    _disposeVideoController();
    _controlsTimer?.cancel();
    _volumeSliderTimer?.cancel();
    super.onClose();
  }

  // Properly dispose video controller
  Future<void> _disposeVideoController() async {
    if (videoPlayerController != null) {
      videoPlayerController!.removeListener(_videoPlayerListener);
      await videoPlayerController!.dispose();
      videoPlayerController = null;
    }
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

      if (videoPlayerController != null) {
        await videoPlayerController!.pause();
        isPlaying.value = false;
      }
      await _disposeVideoController();

      currentVideoIndex.value = index;
      currentVideo.value = playlist[index];

      currentPosition.value = Duration.zero;
      totalDuration.value = Duration.zero;

      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(playlist[index].url),
      );

      await videoPlayerController!.initialize().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timeout after 30 seconds');
        },
      );

      await setVolume(1.0);

      videoPlayerController!.addListener(_videoPlayerListener);
      totalDuration.value = videoPlayerController!.value.duration;
      await setVolume(1.0);

      await videoPlayerController!.play();
      isPlaying.value = true;

      _addVideoPlayerListener();
    } catch (e) {
      hasError.value = true;
      await _disposeVideoController();
    } finally {
      isLoading.value = false;
    }
  }

  // Video player listener
  void _videoPlayerListener() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      // Check for errors first
      if (videoPlayerController!.value.hasError) {
        hasError.value = true;
        return;
      }

      final position = videoPlayerController!.value.position;
      final duration = videoPlayerController!.value.duration;

      // Update observable values for UI
      currentPosition.value = position;
      totalDuration.value = duration;
      isPlaying.value = videoPlayerController!.value.isPlaying;

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
          duration.inMilliseconds > 0 &&
          (position.inMilliseconds >= duration.inMilliseconds - 1000)) {
        if (hasNextVideo) {
          playNextVideo();
        } else {
          isPlaying.value = false;
        }
      }
    }
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (videoPlayerController == null) return;

    if (videoPlayerController!.value.isPlaying) {
      await videoPlayerController!.pause();
    } else {
      await videoPlayerController!.play();
    }

    isPlaying.value = videoPlayerController!.value.isPlaying;
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

  // Retry video loading
  Future<void> retryVideo() async {
    await _loadVideoAtIndex(currentVideoIndex.value);
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
    if (videoPlayerController != null) {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await videoPlayerController!.setVolume(clampedVolume);
      currentVolume.value = clampedVolume;
    }
  }

  // Mute/Unmute toggle
  Future<void> toggleMute() async {
    if (currentVolume.value > 0) {
      await setVolume(0.0);
    } else {
      await setVolume(0.7);
    }
  }

  // Configure audio session for proper video playback
  Future<void> _configureAudioSession() async {
    try {
      await SystemChannels.platform.invokeMethod(
        'AudioManager.requestAudioFocus',
      );
      await SystemChannels.platform.invokeMethod(
        'AudioManager.setStreamVolume',
        {'streamType': 'STREAM_MUSIC', 'volume': 15, 'flags': 0},
      );
    } catch (e) {
      debugPrint('⚠️ Failed to configure audio session: $e');
    }
  }

  // Add video player listener for position-based printing
  void _addVideoPlayerListener() {
    if (videoPlayerController == null) return;
    videoPlayerController!.addListener(_videoPlayerListener);
  }

  // Remove video player listener
  void _removeVideoPlayerListener() {
    if (videoPlayerController != null) {
      videoPlayerController!.removeListener(_videoPlayerListener);
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
