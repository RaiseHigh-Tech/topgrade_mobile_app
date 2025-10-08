import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../utils/constants/api_endpoints.dart';

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
  // Video Player Controller
  VideoPlayerController? videoPlayerController;

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
  var showVolumeSlider = false.obs;

  // Timer for hiding controls
  Timer? _controlsTimer;
  Timer? _volumeSliderTimer;

  // Playlist data
  var playlist = <VideoItem>[].obs;
  var moduleStructure = <ModuleVideoStructure>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Configure audio session for video playback
    _configureAudioSession();

    // Check if there are navigation arguments with server data
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      // Check if we have syllabus data from course details
      if (args.containsKey('syllabus') && args.containsKey('currentTopicId')) {
        _initializeFromServerData(args);
      } else {
        // No syllabus data available
        _showNoVideosError();
      }
    } else {
      // No arguments provided
      _showNoVideosError();
    }
  }

  @override
  void onClose() {
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

      // Extract all topics from all modules and create module structure
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

              // Only add topics that have video URLs
              if (videoUrl.isNotEmpty) {
                // Convert relative URL to absolute URL if needed
                String fullVideoUrl = videoUrl;
                if (!videoUrl.startsWith('http')) {
                  // Use base URL from API endpoints
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

                // Check if this is the current topic to play
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
                ), // Expand if contains current video
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

      // Stop current video and reset state
      if (videoPlayerController != null) {
        await videoPlayerController!.pause();
        isPlaying.value = false;
      }

      // Properly dispose previous controller
      await _disposeVideoController();

      // Update current video info
      currentVideoIndex.value = index;
      currentVideo.value = playlist[index];

      // Reset position and duration
      currentPosition.value = Duration.zero;
      totalDuration.value = Duration.zero;

      print('🎬 Loading video at index $index: ${playlist[index].url}');

      // Create new video controller
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(playlist[index].url),
      );

      // Initialize video player with timeout
      await videoPlayerController!.initialize().timeout(
        Duration(seconds: 30), // Increased timeout
        onTimeout: () {
          throw Exception('Video initialization timeout after 30 seconds');
        },
      );

      // Set initial volume and update observable
      await setVolume(1.0);

      // Setup listeners AFTER successful initialization
      videoPlayerController!.addListener(_videoPlayerListener);

      // Update duration
      totalDuration.value = videoPlayerController!.value.duration;

      // Set initial volume and update observable
      await setVolume(1.0);
      
      // Auto play video
      await videoPlayerController!.play();
      isPlaying.value = true;
      
      print('🔊 Video started with audio enabled');
    } catch (e) {
      hasError.value = true;

      // Clean up on error
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

      // Update position and playing state
      currentPosition.value = videoPlayerController!.value.position;
      isPlaying.value = videoPlayerController!.value.isPlaying;

      // Check if video ended (with small buffer to prevent premature ending)
      final position = videoPlayerController!.value.position;
      final duration = videoPlayerController!.value.duration;

      if (position.inMilliseconds > 0 &&
          duration.inMilliseconds > 0 &&
          (position.inMilliseconds >= duration.inMilliseconds - 1000)) {
        // Auto play next video if available
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

  // Seek to position
  Future<void> seekTo(Duration position) async {
    if (videoPlayerController != null) {
      await videoPlayerController!.seekTo(position);
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

  // Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (videoPlayerController != null) {
      await videoPlayerController!.setPlaybackSpeed(speed);
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    if (videoPlayerController != null) {
      // Clamp volume between 0.0 and 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await videoPlayerController!.setVolume(clampedVolume);
      currentVolume.value = clampedVolume;
      print('🔊 Volume set to: ${(clampedVolume * 100).round()}%');
    }
  }

  // Toggle volume slider visibility
  void toggleVolumeSlider() {
    showVolumeSlider.value = !showVolumeSlider.value;
    
    if (showVolumeSlider.value) {
      _startVolumeSliderTimer();
    } else {
      _volumeSliderTimer?.cancel();
    }
  }

  // Show volume slider temporarily
  void showVolumeSliderTemporarily() {
    showVolumeSlider.value = true;
    _startVolumeSliderTimer();
  }

  // Start timer to hide volume slider
  void _startVolumeSliderTimer() {
    _volumeSliderTimer?.cancel();
    _volumeSliderTimer = Timer(Duration(seconds: 3), () {
      showVolumeSlider.value = false;
    });
  }

  // Mute/Unmute toggle
  Future<void> toggleMute() async {
    if (currentVolume.value > 0) {
      // Mute
      await setVolume(0.0);
    } else {
      // Unmute to 70% volume
      await setVolume(0.7);
    }
  }

  // Configure audio session for proper video playback
  Future<void> _configureAudioSession() async {
    try {
      // Enable audio focus for video playback
      await SystemChannels.platform.invokeMethod('AudioManager.requestAudioFocus');
      
      // Set system volume to ensure audio is audible
      await SystemChannels.platform.invokeMethod('AudioManager.setStreamVolume', {
        'streamType': 'STREAM_MUSIC',
        'volume': 15, // Set to a reasonable volume level
        'flags': 0,
      });
      
      print('✅ Audio session configured successfully');
    } catch (e) {
      print('⚠️ Failed to configure audio session: $e');
      // Audio configuration failed, but continue with video playback
    }
  }

  // Add video to playlist
  void addVideoToPlaylist(VideoItem video) {
    playlist.add(video);
  }

  // Remove video from playlist
  void removeVideoFromPlaylist(int index) {
    if (index >= 0 && index < playlist.length) {
      // If removing current video, play next or previous
      if (index == currentVideoIndex.value) {
        if (hasNextVideo) {
          playNextVideo();
        } else if (hasPreviousVideo) {
          playPreviousVideo();
        }
      }

      playlist.removeAt(index);

      // Update current video index if needed
      if (index < currentVideoIndex.value) {
        currentVideoIndex.value--;
      }
    }
  }

  // Clear playlist
  void clearPlaylist() {
    videoPlayerController?.dispose();
    playlist.clear();
    currentVideoIndex.value = 0;
    currentVideo.value = null;
    isPlaying.value = false;
  }

  // Shuffle playlist
  void shufflePlaylist() {
    final currentVideoItem = currentVideo.value;
    playlist.shuffle();

    // Find the new index of current video
    if (currentVideoItem != null) {
      final newIndex = playlist.indexWhere(
        (video) => video.url == currentVideoItem.url,
      );
      if (newIndex != -1) {
        currentVideoIndex.value = newIndex;
      }
    }
  }
}
