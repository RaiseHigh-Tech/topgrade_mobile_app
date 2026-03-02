# Project Code Editions Documentation

This document summarizes all modifications and enhancements made to the codebase to improve the video player experience, implement resume functionality, and optimize performance.

## 1. Video Player Logic & Performance (`video_player_controller.dart`)
- **Controller Management**: Implemented stable `videoId` tags for `Get.put`/`Get.delete` to ensure efficient controller reuse and prevent memory leaks.
- **Fast Playback Optimization**: 
    - Removed arbitrary startup delays.
    - Optimized state listeners (playing, buffering, position) to hide the loading screen as soon as the first frame is decoded or playback begins.
    - Added safety checks to ensure `isLoading` is forced to false if playback position moves.
- **Adaptive Configuration**: Removed fixed 32MB buffer and hardcoded 640x360 dimensions to allow `media_kit` to use optimized defaults and auto-scale to device resolution. This resolves "black screen" issues on longer videos.
- **Buffering State**: Added a separate `isBuffering` observable to track real-time network stalls while keeping the video visible.

## 2. Video Player UI (`video_player_screen.dart`)
- **Branded Loading State**: Replaced the default black screen with a dynamic loading UI featuring:
    - **Thumbnail Background**: Shows the video thumbnail behind an overlay while loading.
    - **Status Label**: Displays "Preparing video...".
    - **Timing Display**: Shows the total video duration (e.g., "12:45") on the loading screen to keep the user informed.
- **Buffering Overlay**: Added a centered spinner that appears mid-playback only when the network stalls, preventing the screen from going black again.
- **Automatic Resume**: Updated screen logic to receive and use the correct `currentTopicId` calculated by the course controller.

## 3. Course Resume Logic (`course_details_controller.dart` & `course_details.dart`)
- **Granular Resume (Lecture-level)**: 
    - Upgraded from module-level to topic-level resume.
    - Added `completed_topics` and `total_topics` tracking to the `ProgressModel`.
    - Implemented a syllabus flattening utility to find the exact next lecture the user needs to watch.
    - The "Go to Course" button now opens the precise lecture following the last completed one.
- **Safe Navigation**: Updated the navigation arguments to correctly pass syllabus data and calculated resume IDs.

## 4. Progress Synchronization & API (`my_learnings_controller.dart` & `Models`)
- **Data Integrity**: Added `toJson()` methods to all learning-related models for better data handling and debugging.
- **Advanced Logging**: 
    - Implemented chunked terminal logging in `MyLearningsController` to prevent server responses from being cut off.
    - Added formatted JSON output for easier analysis.
    - Added explicit percentage indicator logs (e.g., `📊 COURSE: ... | PERCENTAGE: 6.6%`).
- **Home Sync**: Ensures that progress updates from the video player (via 30s interval pulses) are correctly reflected on the home screen "Continue Watching" cards.

## 5. Home Screen Enhancements (`home_page.dart`)
- **Progress Visuals**: Verified the `LinearProgressIndicator` logic to correctly use the `percentage` field from the API.
- **Refresh on Return**: Updated the navigation triggers to refresh learning data when coming back from a course session.

---
**Status**: All core requirements (Immediate load, Granular Resume, No black screens, Branded loading) have been implemented and verified.

---

## Edition — 2026-02-28: HLS Support, MPV Fast-Start & Black Screen Fix

**Files Modified:** `video_player_controller.dart`, `video_player_screen.dart`

### Changes
1. **MPV Fast-Start Options**: `Player.ready` callback casts to `NativePlayer` and sets `cache=yes`, `demuxer-max-bytes=100MB`, `demuxer-readahead-secs=20`, `video-sync=audio`, `ytdl=no` → first frame appears faster.
2. **HLS URL Auto-Detection**: Added `_isHlsUrl()` helper detecting `.m3u8`/`hls`/`/stream/`. `media_kit 1.2.6` + libmpv natively supports HLS — no extra package needed.
3. **Black Screen Fix**: `isLoading=false` fires immediately when `player.stream.playing→true` OR `position > 0ms`. Mid-play rebuffers show only small overlay spinner.
4. **Resume-Position Support**: `_loadVideoAtIndex(index, {resumeSeconds})` seeks to saved position after first frame, guarded by `_hasSeekedToResume` flag.
5. **Loading UI Badge**: Loading overlay shows `⚡ HLS Stream` (green) or `📁 MP4` (orange) badge.
6. **PopScope**: Replaced deprecated `WillPopScope` → `PopScope`.

**Verification:** `flutter analyze` — **No issues found.**

---

## Edition — 2026-02-28 (Update 2): HLS Dev Test & Production URL Restore

**Date:** 2026-02-28 10:45–10:53 IST
**Files Modified:** `video_player_controller.dart`

### What Was Done

#### 1. HLS Test URL Hardcoded (Dev Testing)
- Temporarily hardcoded `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8` in `_loadVideoAtIndex()` to verify HLS playback on a real device.
- Purpose: Confirm `media_kit` + libmpv HLS pipeline works correctly before the backend migrates to HLS.

#### 2. Test Result on Moto g45 5G (Android 15)
- **✅ HLS stream started near-instantly** — no black screen, no delay.
- Loading badge showed **⚡ HLS Stream** (green) on the loading overlay.
- MPV fast-start options confirmed working.
- **Conclusion:** Player is fully HLS-ready. No code changes needed when backend switches to `.m3u8` URLs.

#### 3. Test URL Commented Out — Production URL Restored
- `devHlsTestUrl` line is commented out and preserved as a reference.
- `final url = playlist[index].url;` restored (real app video URL).
- App hot-restarted on device with production URLs.

```dart
// 🧪 DEV TEST (commented out — HLS confirmed working 2026-02-28)
// const String devHlsTestUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
// final url = devHlsTestUrl;
// ════════════════════════════════════════════════════════════════════════
final url = playlist[index].url; // ← production URL restored
```

### How to Re-enable HLS Test
Uncomment the `devHlsTestUrl` lines and comment out `playlist[index].url` — useful for future regression testing.

---

## 🔴 Root Cause Investigation — 2026-02-28: Black Screen on Lecture 3+ (5–15 min delay)

### Symptom
- Lecture 1, 2 → play immediately ✅
- Lecture 3 and some others → black screen for ~8 minutes, then plays ❌

### Root Cause — S3 Glacier Storage Class

Confirmed via HTTP header inspection:
```
curl -I https://media.topgradeinnovation.com/media/programs/regular/UI_UX_Design/UIUX_3.mp4_720p.mp4

HTTP/2 200
content-type: video/mp4
x-amz-storage-class: GLACIER     ← ⚠️ PROBLEM
x-cache: Miss from cloudfront     ← ⚠️ Not cached, retrieving from Glacier
```

**Lecture 2 (working):**
```
x-amz-storage-class: STANDARD    ← ✅ Hot storage, instant delivery
```

### Why 8 Minutes?
S3 Glacier is archival (cold) storage. When a file is requested:
1. CloudFront cache miss → request goes to S3 Glacier
2. Glacier initiates restore (Standard retrieval = 3–12 hours, Expedited = 1–5 min)
3. libmpv in the Flutter app silently retries/buffers while waiting
4. Once Glacier restores the file → CloudFront serves it → video plays

Chrome shows an XML error immediately because it does not retry. The Flutter app (libmpv) waits patiently, which is why the video eventually plays after ~8 minutes.

### Fix Required (Backend)
Move all course videos from Glacier → S3 Standard:
```bash
aws s3 cp s3://<bucket>/media/programs/regular/UI_UX_Design/ \
          s3://<bucket>/media/programs/regular/UI_UX_Design/ \
          --recursive \
          --storage-class STANDARD \
          --metadata-directive COPY
```

Apply this to **all program folders**, not just UI_UX_Design.

### Priority
| Fix | Impact | Who |
|-----|--------|-----|
| ✅ Move S3 Glacier → Standard | Fixes black screen instantly | **Backend team** |
| 🔜 Migrate MP4 → HLS (.m3u8) | Faster startup for long videos | Backend team |
| ✅ MPV fast-start options | Best possible MP4 startup (done) | App (done) |
