import 'dart:async';
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

  // Timer for hiding controls
  Timer? _controlsTimer;

  // Playlist data
  var playlist = <VideoItem>[].obs;
  var moduleStructure = <ModuleVideoStructure>[].obs;

  @override
  void onInit() {
    super.onInit();

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
    videoPlayerController?.dispose();
    _controlsTimer?.cancel();
    super.onClose();
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
      currentVideoIndex.value = index;
      currentVideo.value = playlist[index];

      // Dispose previous controller
      await videoPlayerController?.dispose();

      // Try network video first, then fallback to test content
      try {
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(playlist[index].url),
        );

        // Initialize video player with timeout
        await videoPlayerController!.initialize().timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Network video initialization timeout');
          },
        );
      } catch (networkError) {
        // Dispose failed controller
        await videoPlayerController?.dispose();

        // Create a simple test scenario - show error but don't crash
        throw Exception('Video not available: $networkError');
      }

      // Setup listeners
      videoPlayerController!.addListener(_videoPlayerListener);

      // Update duration
      totalDuration.value = videoPlayerController!.value.duration;

      // Auto play video
      await videoPlayerController!.play();
      isPlaying.value = true;
    } catch (e) {
      hasError.value = true;

      // Clear the video controller on error
      await videoPlayerController?.dispose();
      videoPlayerController = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Video player listener
  void _videoPlayerListener() {
    if (videoPlayerController != null) {
      currentPosition.value = videoPlayerController!.value.position;
      isPlaying.value = videoPlayerController!.value.isPlaying;

      // Check if video ended
      if (videoPlayerController!.value.position >=
          videoPlayerController!.value.duration) {
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
      await videoPlayerController!.setVolume(volume);
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
