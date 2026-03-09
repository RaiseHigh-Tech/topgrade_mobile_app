import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:better_player_plus/better_player_plus.dart';
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
  var betterPlayerController = Rx<BetterPlayerController?>(null);

  late RemoteSource _remoteSource;

  var isLoading = true.obs;
  var hasError = false.obs;
  var isPlaylistVisible = true.obs;
  var currentVideoIndex = 0.obs;
  var currentVideo = Rx<VideoItem?>(null);

  // Position tracking for API progress updates
  Duration _lastApiUpdatePosition = Duration.zero;
  static const Duration _apiUpdateInterval = Duration(seconds: 30);

  var hasPurchased = false.obs;
  var purchaseId = 0.obs;
  var currentTopicId = 0.obs;

  var playlist = <VideoItem>[].obs;
  var moduleStructure = <ModuleVideoStructure>[].obs;

  BetterPlayerConfiguration get _playerConfig => BetterPlayerConfiguration(
    autoPlay: true,
    looping: false,
    aspectRatio: 16 / 9,
    fit: BoxFit.contain,
    controlsConfiguration: const BetterPlayerControlsConfiguration(
      showControls: true,
    ),
    deviceOrientationsOnFullScreen: const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    deviceOrientationsAfterFullScreen: const [
      DeviceOrientation.portraitUp,
    ],
    eventListener: _onPlayerEvent,
  );

  @override
  void onInit() {
    super.onInit();

    _remoteSource = RemoteSourceImpl(dio: Get.find<DioClient>());

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
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
    betterPlayerController.value?.dispose();
    betterPlayerController.value = null;
    super.onClose();
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        isLoading.value = false;
        break;
      case BetterPlayerEventType.progress:
        final position = event.parameters?['progress'] as Duration?;
        if (position != null) _handlePositionUpdate(position);
        break;
      case BetterPlayerEventType.exception:
        hasError.value = true;
        isLoading.value = false;
        debugPrint('❌ BetterPlayer exception: ${event.parameters}');
        break;
      case BetterPlayerEventType.finished:
        if (hasNextVideo) playNextVideo();
        break;
      default:
        break;
    }
  }

  void _handlePositionUpdate(Duration position) {
    final isPlaying = betterPlayerController.value?.isPlaying() ?? false;

    if (isPlaying &&
        position.inSeconds >=
            _lastApiUpdatePosition.inSeconds + _apiUpdateInterval.inSeconds) {
      if (hasPurchased.value &&
          currentTopicId.value > 0 &&
          purchaseId.value > 0) {
        _lastApiUpdatePosition = Duration(
          seconds: (position.inSeconds ~/ 30) * 30,
        );
        _updateProgressToServer(position.inSeconds);
      } else {
        debugPrint('❌ API update blocked - missing purchase requirements');
      }
    }
  }

  void _initializeFromServerData(Map<String, dynamic> args) {
    try {
      final syllabus = args['syllabus'];
      final currentTopicId = args['currentTopicId'] as int?;

      List<VideoItem> serverPlaylist = [];
      List<ModuleVideoStructure> modules = [];
      int startIndex = 0;
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
                  startIndex = videoIndex;
                }
                videoIndex++;
              }
            }
          }

          if (moduleVideos.isNotEmpty) {
            modules.add(
              ModuleVideoStructure(
                id: moduleId,
                title: moduleName,
                videos: moduleVideos,
                isExpanded: moduleVideos.any((v) => v.id == currentTopicId),
              ),
            );
          }
        }
      }

      if (serverPlaylist.isNotEmpty) {
        playlist.value = serverPlaylist;
        moduleStructure.value = modules;
        currentVideo.value = playlist[startIndex];
        _loadVideoAtIndex(startIndex);
      } else {
        _showNoVideosError();
      }
    } catch (e) {
      _showNoVideosError();
    }
  }

  void _showNoVideosError() {
    hasError.value = true;
    isLoading.value = false;
    playlist.value = [];
    moduleStructure.value = [];
    currentVideo.value = null;
  }

  void toggleModuleExpansion(int moduleId) {
    moduleStructure.value =
        moduleStructure.map((module) {
          if (module.id == moduleId) {
            return module.copyWith(isExpanded: !module.isExpanded);
          }
          return module;
        }).toList();
  }

  Future<void> _loadVideoAtIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      currentVideoIndex.value = index;
      currentVideo.value = playlist[index];
      _lastApiUpdatePosition = Duration.zero;

      // Dispose old controller and clear so widget removes it
      betterPlayerController.value?.dispose();
      betterPlayerController.value = null;

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        playlist[index].url,
      );

      // Create fresh controller for this video
      final newController = BetterPlayerController(_playerConfig);
      await newController.setupDataSource(dataSource);
      betterPlayerController.value = newController;

      debugPrint('✅ Video loaded: ${playlist[index].title}');
    } catch (e) {
      debugPrint('❌ Video loading error: $e');
      hasError.value = true;
      isLoading.value = false;
    }
  }

  void togglePlaylistVisibility() {
    isPlaylistVisible.value = !isPlaylistVisible.value;
  }

  Future<void> playVideoAtIndex(int index) async {
    await _loadVideoAtIndex(index);
  }

  Future<void> playPreviousVideo() async {
    if (hasPreviousVideo) await _loadVideoAtIndex(currentVideoIndex.value - 1);
  }

  Future<void> playNextVideo() async {
    if (hasNextVideo) await _loadVideoAtIndex(currentVideoIndex.value + 1);
  }

  bool get hasPreviousVideo => currentVideoIndex.value > 0;
  bool get hasNextVideo => currentVideoIndex.value < playlist.length - 1;

  int _retryCount = 0;
  static const int _maxRetries = 3;

  Future<void> retryVideo() async {
    _retryCount = 0;
    await _retryWithBackoff();
  }

  Future<void> _retryWithBackoff() async {
    if (_retryCount >= _maxRetries) {
      hasError.value = true;
      return;
    }
    _retryCount++;
    if (_retryCount > 1) {
      await Future.delayed(Duration(seconds: _retryCount * 2));
    }
    try {
      await _loadVideoAtIndex(currentVideoIndex.value);
      _retryCount = 0;
    } catch (e) {
      if (_retryCount < _maxRetries) {
        await _retryWithBackoff();
      } else {
        hasError.value = true;
      }
    }
  }

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
      }
    }
  }
}