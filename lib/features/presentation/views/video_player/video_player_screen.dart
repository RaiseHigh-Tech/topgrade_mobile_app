import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/video_player_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerScreenController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    print('🎬 VideoPlayerScreen initState called');
    
    // Create a fresh controller instance to avoid reuse issues
    _controller = Get.put(
      VideoPlayerScreenController(),
      tag: DateTime.now().millisecondsSinceEpoch.toString(), // Unique tag
    );
    
    // Set preferred orientations for video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation when leaving video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Properly dispose controller
    Get.delete<VideoPlayerScreenController>(
      tag: _controller.hashCode.toString(),
    );
    
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎬 VideoPlayerScreen build called');
    return GetBuilder<XThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: _isFullScreen ? Colors.black : themeController.backgroundColor,
        appBar: _isFullScreen ? null : AppBar(
          backgroundColor: themeController.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeController.textColor),
            onPressed: () => Get.back(),
          ),
          title: Obx(() => Text(
            _controller.currentVideo.value?.title ?? 'Video Player',
            style: TextStyle(
              fontSize: XSizes.textSizeMd,
              fontFamily: XFonts.lexend,
              fontWeight: FontWeight.w600,
              color: themeController.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
          actions: [
            IconButton(
              icon: Icon(Icons.playlist_play, color: themeController.primaryColor),
              onPressed: () {
                // Toggle playlist visibility
                _controller.togglePlaylistVisibility();
              },
            ),
          ],
        ),
        body: _isFullScreen
            ? _buildFullScreenVideo(themeController)
            : _buildNormalView(themeController),
      ),
    );
  }

  Widget _buildFullScreenVideo(XThemeController themeController) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _buildVideoPlayer(themeController, isFullScreen: true),
      ),
    );
  }

  Widget _buildNormalView(XThemeController themeController) {
    return Obx(() => Column(
      children: [
        // Video Player Section
        Container(
          width: double.infinity,
          height: 250,
          color: Colors.black,
          child: _buildVideoPlayer(themeController),
        ),
        
        // Video Info Section
        Container(
          padding: EdgeInsets.all(XSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _controller.currentVideo.value?.title ?? 'Loading...',
                style: TextStyle(
                  fontSize: XSizes.textSizeLg,
                  fontFamily: XFonts.lexend,
                  fontWeight: FontWeight.w700,
                  color: themeController.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: XSizes.spacingSm),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: themeController.textColor.withValues(alpha: 0.6)),
                  SizedBox(width: XSizes.spacingXs),
                  Text(
                    _controller.currentVideo.value?.duration ?? '00:00',
                    style: TextStyle(
                      fontSize: XSizes.textSizeXs,
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: XSizes.spacingSm,
                      vertical: XSizes.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: themeController.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
                    ),
                    child: Text(
                      'Module ${_controller.currentVideoIndex.value + 1}',
                      style: TextStyle(
                        fontSize: XSizes.textSizeXs,
                        fontFamily: XFonts.lexend,
                        fontWeight: FontWeight.w500,
                        color: themeController.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (_controller.currentVideo.value?.description != null && _controller.currentVideo.value!.description!.isNotEmpty) ...[
                SizedBox(height: XSizes.spacingMd),
                Text(
                  _controller.currentVideo.value!.description!,
                  style: TextStyle(
                    fontSize: XSizes.textSizeSm,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        
        // Playlist Section
        if (_controller.isPlaylistVisible.value)
          Expanded(
            child: _buildPlaylist(themeController),
          ),
      ],
    ));
  }

  Widget _buildVideoPlayer(XThemeController themeController, {bool isFullScreen = false}) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: themeController.primaryColor,
          ),
        );
      }

      if (_controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: themeController.textColor.withValues(alpha: 0.5),
              ),
              SizedBox(height: XSizes.spacingMd),
              Text(
                'Failed to load video',
                style: TextStyle(
                  fontSize: XSizes.textSizeSm,
                  fontFamily: XFonts.lexend,
                  color: themeController.textColor.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: XSizes.spacingMd),
              ElevatedButton(
                onPressed: () => _controller.retryVideo(),
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (_controller.videoPlayerController != null) {
        return AspectRatio(
          aspectRatio: _controller.videoPlayerController!.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_controller.videoPlayerController!),
              
              // Video Controls Overlay
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _controller.toggleControls(),
                  child: AnimatedOpacity(
                    opacity: _controller.showControls.value ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      color: Colors.black26,
                      child: _buildVideoControls(themeController, isFullScreen),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'No video loaded',
            style: TextStyle(
              color: Colors.white,
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVideoControls(XThemeController themeController, bool isFullScreen) {
    return Stack(
      children: [
        // Play/Pause Button (Center)
        Center(
          child: GestureDetector(
            onTap: () => _controller.togglePlayPause(),
            child: Container(
              padding: EdgeInsets.all(XSizes.paddingMd),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Obx(() => Icon(
                _controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: isFullScreen ? 48 : 36,
              )),
            ),
          ),
        ),
        
        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(XSizes.paddingSm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                Obx(() => VideoProgressIndicator(
                  _controller.videoPlayerController!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: themeController.primaryColor,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white12,
                  ),
                )),
                SizedBox(height: XSizes.spacingSm),
                
                // Control Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time Display
                    Obx(() => Text(
                      '${_controller.formatDuration(_controller.currentPosition.value)} / ${_controller.formatDuration(_controller.totalDuration.value)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: XSizes.textSizeXs,
                        fontFamily: XFonts.lexend,
                      ),
                    )),
                    
                    // Control Buttons
                    Row(
                      children: [
                        // Previous Video
                        IconButton(
                          onPressed: _controller.hasPreviousVideo ? () => _controller.playPreviousVideo() : null,
                          icon: Icon(
                            Icons.skip_previous,
                            color: _controller.hasPreviousVideo ? Colors.white : Colors.white38,
                            size: 24,
                          ),
                        ),
                        
                        // Next Video
                        IconButton(
                          onPressed: _controller.hasNextVideo ? () => _controller.playNextVideo() : null,
                          icon: Icon(
                            Icons.skip_next,
                            color: _controller.hasNextVideo ? Colors.white : Colors.white38,
                            size: 24,
                          ),
                        ),
                        
                        // Fullscreen Toggle
                        IconButton(
                          onPressed: _toggleFullScreen,
                          icon: Icon(
                            _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylist(XThemeController themeController) {
    return Container(
      decoration: BoxDecoration(
        color: themeController.backgroundColor,
        border: Border(
          top: BorderSide(
            color: themeController.textColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Playlist Header
          Container(
            padding: EdgeInsets.all(XSizes.paddingMd),
            child: Row(
              children: [
                Icon(
                  Icons.playlist_play,
                  color: themeController.primaryColor,
                  size: 20,
                ),
                SizedBox(width: XSizes.spacingSm),
                Text(
                  'Playlist',
                  style: TextStyle(
                    fontSize: XSizes.textSizeMd,
                    fontFamily: XFonts.lexend,
                    fontWeight: FontWeight.w600,
                    color: themeController.textColor,
                  ),
                ),
                Spacer(),
                Obx(() => Text(
                  '${_controller.currentVideoIndex.value + 1} of ${_controller.playlist.length}',
                  style: TextStyle(
                    fontSize: XSizes.textSizeXs,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.6),
                  ),
                )),
              ],
            ),
          ),
          
          // Playlist Items with Module Structure
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: _controller.moduleStructure.length,
              itemBuilder: (context, moduleIndex) {
                final module = _controller.moduleStructure[moduleIndex];
                
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: XSizes.marginSm,
                    vertical: XSizes.marginXs,
                  ),
                  decoration: BoxDecoration(
                    color: themeController.backgroundColor,
                    border: Border.all(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                  ),
                  child: Column(
                    children: [
                      // Module Header
                      InkWell(
                        onTap: () => _controller.toggleModuleExpansion(module.id),
                        borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                        child: Container(
                          padding: EdgeInsets.all(XSizes.paddingSm),
                          child: Row(
                            children: [
                              Container(
                                width: XSizes.iconSizeLg,
                                height: XSizes.iconSizeLg,
                                decoration: BoxDecoration(
                                  color: themeController.primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${moduleIndex + 1}',
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeXs,
                                      fontFamily: XFonts.lexend,
                                      fontWeight: FontWeight.w600,
                                      color: themeController.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: XSizes.spacingSm),
                              Expanded(
                                child: Text(
                                  module.title,
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeSm,
                                    fontFamily: XFonts.lexend,
                                    fontWeight: FontWeight.w600,
                                    color: themeController.textColor,
                                  ),
                                ),
                              ),
                              Icon(
                                module.isExpanded 
                                    ? Icons.keyboard_arrow_up 
                                    : Icons.keyboard_arrow_down,
                                color: themeController.textColor.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Module Topics
                      if (module.isExpanded)
                        Container(
                          color: themeController.backgroundColor,
                          child: Column(
                            children: module.videos.map((video) {
                              final videoIndex = _controller.playlist.indexWhere((v) => v.id == video.id);
                              final isCurrentVideo = videoIndex == _controller.currentVideoIndex.value;
                              
                              return Container(
                                margin: EdgeInsets.only(
                                  left: XSizes.marginMd,
                                  right: XSizes.marginSm,
                                  bottom: XSizes.marginXs,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentVideo
                                      ? themeController.primaryColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
                                  border: isCurrentVideo
                                      ? Border.all(color: themeController.primaryColor.withValues(alpha: 0.3))
                                      : null,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: XSizes.paddingSm,
                                    vertical: XSizes.paddingXs,
                                  ),
                                  leading: Container(
                                    width: 50,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: themeController.textColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(XSizes.borderRadiusXs),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Icon(
                                            isCurrentVideo ? Icons.play_arrow : Icons.play_circle_outline,
                                            color: isCurrentVideo
                                                ? themeController.primaryColor
                                                : themeController.textColor.withValues(alpha: 0.5),
                                            size: 18,
                                          ),
                                        ),
                                        if (isCurrentVideo)
                                          Positioned(
                                            bottom: 2,
                                            right: 2,
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: themeController.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    video.title,
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeXs,
                                      fontFamily: XFonts.lexend,
                                      fontWeight: isCurrentVideo ? FontWeight.w600 : FontWeight.w400,
                                      color: isCurrentVideo
                                          ? themeController.primaryColor
                                          : themeController.textColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    video.duration,
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeXs - 1,
                                      fontFamily: XFonts.lexend,
                                      color: themeController.textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  trailing: isCurrentVideo
                                      ? Icon(
                                          Icons.volume_up,
                                          color: themeController.primaryColor,
                                          size: 14,
                                        )
                                      : null,
                                  onTap: () => _controller.playVideoAtIndex(videoIndex),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}