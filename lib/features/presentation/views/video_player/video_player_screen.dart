import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:better_player_plus/better_player_plus.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      VideoPlayerScreenController(),
      tag: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  void dispose() {
    Get.delete<VideoPlayerScreenController>(
      tag: _controller.hashCode.toString(),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Scaffold(
            backgroundColor: themeController.backgroundColor,
            appBar: AppBar(
              backgroundColor: themeController.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: themeController.textColor),
                onPressed: () => Get.back(),
              ),
              title: Obx(
                () => Text(
                  _controller.currentVideo.value?.title ?? 'Video Player',
                  style: TextStyle(
                    fontSize: XSizes.textSizeMd,
                    fontFamily: XFonts.lexend,
                    fontWeight: FontWeight.w600,
                    color: themeController.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.playlist_play,
                    color: themeController.primaryColor,
                  ),
                  onPressed: () => _controller.togglePlaylistVisibility(),
                ),
              ],
            ),
            body: _buildBody(themeController),
          ),
    );
  }

  Widget _buildBody(XThemeController themeController) {
    return Obx(
      () => Column(
        children: [
          // Video Player - fixed height
          SizedBox(
            width: double.infinity,
            height: 250,
            child: ColoredBox(
              color: Colors.black,
              child: _buildVideoPlayer(themeController),
            ),
          ),

          // Info + Playlist - takes remaining space
          Expanded(
            child:
                _controller.isPlaylistVisible.value
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVideoInfo(themeController),
                        Expanded(child: _buildPlaylist(themeController)),
                      ],
                    )
                    : SingleChildScrollView(
                      child: _buildVideoInfo(themeController),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo(XThemeController themeController) {
    return Container(
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
              Icon(
                Icons.access_time,
                size: 16,
                color: themeController.textColor.withValues(alpha: 0.6),
              ),
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
          if (_controller.currentVideo.value?.description != null &&
              _controller.currentVideo.value!.description!.isNotEmpty) ...[
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
    );
  }

  Widget _buildVideoPlayer(XThemeController themeController) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: themeController.primaryColor),
        );
      }

      if (_controller.hasError.value) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(XSizes.paddingLg),
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
                    fontSize: XSizes.textSizeMd,
                    fontFamily: XFonts.lexend,
                    fontWeight: FontWeight.w600,
                    color: themeController.textColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: XSizes.spacingSm),
                Text(
                  'This could be due to:\n• Poor internet connection\n• Video format not supported\n• Server unavailable',
                  style: TextStyle(
                    fontSize: XSizes.textSizeXs,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: XSizes.spacingLg),
                ElevatedButton.icon(
                  onPressed: () => _controller.retryVideo(),
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: XSizes.paddingLg,
                      vertical: XSizes.paddingMd,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (_controller.betterPlayerController.value != null) {
        return BetterPlayer(
          key: ValueKey(_controller.currentVideoIndex.value),
          controller: _controller.betterPlayerController.value!,
        );
      }

      return Center(
        child: Text(
          'No video loaded',
          style: TextStyle(
            color: Colors.white,
            fontSize: XSizes.textSizeSm,
            fontFamily: XFonts.lexend,
          ),
        ),
      );
    });
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
                Obx(
                  () => Text(
                    '${_controller.currentVideoIndex.value + 1} of ${_controller.playlist.length}',
                    style: TextStyle(
                      fontSize: XSizes.textSizeXs,
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Playlist Items
          Expanded(
            child: Obx(
              () => ListView.builder(
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
                          onTap:
                              () =>
                                  _controller.toggleModuleExpansion(module.id),
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(XSizes.paddingSm),
                            child: Row(
                              children: [
                                Container(
                                  width: XSizes.iconSizeLg,
                                  height: XSizes.iconSizeLg,
                                  decoration: BoxDecoration(
                                    color: themeController.primaryColor
                                        .withValues(alpha: 0.1),
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
                                  color: themeController.textColor.withValues(
                                    alpha: 0.6,
                                  ),
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
                              children:
                                  module.videos.map((video) {
                                    final videoIndex = _controller.playlist
                                        .indexWhere((v) => v.id == video.id);
                                    final isCurrentVideo =
                                        videoIndex ==
                                        _controller.currentVideoIndex.value;

                                    return Container(
                                      margin: EdgeInsets.only(
                                        left: XSizes.marginMd,
                                        right: XSizes.marginSm,
                                        bottom: XSizes.marginXs,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isCurrentVideo
                                                ? themeController.primaryColor
                                                    .withValues(alpha: 0.1)
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          XSizes.borderRadiusSm,
                                        ),
                                        border:
                                            isCurrentVideo
                                                ? Border.all(
                                                  color: themeController
                                                      .primaryColor
                                                      .withValues(alpha: 0.3),
                                                )
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
                                            color: themeController.textColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              XSizes.borderRadiusXs,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Icon(
                                                  isCurrentVideo
                                                      ? Icons.play_arrow
                                                      : Icons
                                                          .play_circle_outline,
                                                  color:
                                                      isCurrentVideo
                                                          ? themeController
                                                              .primaryColor
                                                          : themeController
                                                              .textColor
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
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
                                                      color:
                                                          themeController
                                                              .primaryColor,
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
                                            fontWeight:
                                                isCurrentVideo
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                            color:
                                                isCurrentVideo
                                                    ? themeController
                                                        .primaryColor
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
                                            color: themeController.textColor
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                        trailing:
                                            isCurrentVideo
                                                ? Icon(
                                                  Icons.volume_up,
                                                  color:
                                                      themeController
                                                          .primaryColor,
                                                  size: 14,
                                                )
                                                : null,
                                        onTap:
                                            () => _controller.playVideoAtIndex(
                                              videoIndex,
                                            ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
