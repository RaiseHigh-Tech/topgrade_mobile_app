import 'dart:async';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoItem {
  final String title;
  final String url;
  final String duration;
  final String? description;
  final String? thumbnail;

  VideoItem({
    required this.title,
    required this.url,
    required this.duration,
    this.description,
    this.thumbnail,
  });
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
  
  @override
  void onInit() {
    super.onInit();
    _initializeDummyPlaylist();
    
    // Check if there are navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      print('Video Player Arguments: $args');
      // You can use these arguments to customize the playlist or start video
    }
    
    _loadVideoAtIndex(0);
  }
  
  @override
  void onClose() {
    videoPlayerController?.dispose();
    _controlsTimer?.cancel();
    super.onClose();
  }
  
  // Initialize dummy playlist with sample videos
  void _initializeDummyPlaylist() {
    playlist.value = [
      VideoItem(
        title: "Introduction to Flutter Development",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        duration: "15:32",
        description: "Learn the basics of Flutter development and how to create your first mobile application.",
      ),
      VideoItem(
        title: "Setting up Development Environment",
        url: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4", 
        duration: "22:15",
        description: "Complete guide to setting up Flutter development environment on Windows, Mac, and Linux.",
      ),
      VideoItem(
        title: "Understanding Widgets in Flutter",
        url: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4",
        duration: "18:45",
        description: "Deep dive into Flutter widgets - StatelessWidget, StatefulWidget, and custom widgets.",
      ),
      VideoItem(
        title: "State Management with GetX",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        duration: "25:30",
        description: "Learn how to manage application state effectively using GetX state management solution.",
      ),
      VideoItem(
        title: "Building Responsive UI",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        duration: "20:12",
        description: "Create responsive user interfaces that work perfectly on all screen sizes and orientations.",
      ),
      VideoItem(
        title: "Navigation and Routing",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        duration: "16:58",
        description: "Master Flutter navigation and routing to create seamless user experiences.",
      ),
      VideoItem(
        title: "Working with APIs and HTTP",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        duration: "28:20",
        description: "Learn how to integrate REST APIs and handle HTTP requests in your Flutter applications.",
      ),
      VideoItem(
        title: "Local Database with SQLite",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        duration: "24:35",
        description: "Implement local data storage using SQLite database for offline functionality.",
      ),
    ];
    
    if (playlist.isNotEmpty) {
      currentVideo.value = playlist.first;
    }
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
      
      // Create new video player controller
      print('🎬 Creating video player for URL: ${playlist[index].url}');
      
      // Try network video first, then fallback to test content
      try {
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(playlist[index].url),
        );
        
        // Initialize video player with timeout
        print('🎬 Initializing network video...');
        await videoPlayerController!.initialize().timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Network video initialization timeout');
          },
        );
        
        print('✅ Network video loaded successfully');
        
      } catch (networkError) {
        print('❌ Network video failed: $networkError');
        print('🔄 Trying alternative approach...');
        
        // Dispose failed controller
        await videoPlayerController?.dispose();
        
        // Create a simple test scenario - show error but don't crash
        throw Exception('Video not available: $networkError');
      }
      
      // Setup listeners
      videoPlayerController!.addListener(_videoPlayerListener);
      
      // Update duration
      totalDuration.value = videoPlayerController!.value.duration;
      print('🎬 Video duration: ${formatDuration(totalDuration.value)}');
      
      // Auto play video
      await videoPlayerController!.play();
      isPlaying.value = true;
      print('▶️ Video started playing');
      
    } catch (e) {
      hasError.value = true;
      print('❌ Error loading video: $e');
      
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
      if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
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
      final newIndex = playlist.indexWhere((video) => video.url == currentVideoItem.url);
      if (newIndex != -1) {
        currentVideoIndex.value = newIndex;
      }
    }
  }
}