import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../models/recorded_video.dart';
import '../services/video_api_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final RecordedVideo video;
  final String currentPath;

  const VideoPlayerScreen({super.key, required this.video, required this.currentPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;
  late html.VideoElement _webVideoElement;
  String _webVideoViewType = '';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebVideo();
    } else {
      _initializeVideo();
    }
  }

  // 웹용 비디오 초기화
  void _initializeWebVideo() {
    final videoUrl = VideoApiService.getVideoUrl(widget.video.filename, path: widget.currentPath);
    print('Loading web video from: $videoUrl');
    
    _webVideoViewType = 'video-${widget.video.filename}-${DateTime.now().millisecondsSinceEpoch}';
    
    _webVideoElement = html.VideoElement()
      ..src = videoUrl
      ..controls = true
      ..autoplay = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.backgroundColor = 'black';
    
    // 웹 비디오 이벤트 리스너
    _webVideoElement.onLoadedData.listen((_) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    });
    
    _webVideoElement.onError.listen((error) {
      print('Web video error: $error');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load video. Please check the video format and server connection.';
      });
    });
    
    // HTML 요소를 Flutter에 등록
    ui_web.platformViewRegistry.registerViewFactory(
      _webVideoViewType,
      (int viewId) => _webVideoElement,
    );
    
    setState(() {
      _isLoading = false;
    });
  }

  // 모바일용 비디오 초기화 (기존 방식)
  Future<void> _initializeVideo() async {
    try {
      final videoUrl = VideoApiService.getVideoUrl(widget.video.filename, path: widget.currentPath);
      print('Loading video from: $videoUrl');
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      await _controller!.initialize();
      
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      
      // 자동 재생
      _controller!.play();
      
    } catch (e) {
      print('Video initialization error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (kIsWeb) {
      if (_webVideoElement.paused) {
        _webVideoElement.play();
      } else {
        _webVideoElement.pause();
      }
    } else if (_controller != null) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      });
    }
  }

  void _seekTo(Duration position) {
    if (kIsWeb) {
      _webVideoElement.currentTime = position.inSeconds.toDouble();
    } else {
      _controller?.seekTo(position);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filename: ${widget.video.filename}'),
            Text('Size: ${widget.video.size}'),
            Text('Created: ${widget.video.created}'),
            if (widget.video.modified != null)
              Text('Modified: ${widget.video.modified}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.video.filename,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showVideoInfo,
          ),
        ],
      ),
      body: _buildVideoPlayer(),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              '영상을 불러오는 중...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              '영상을 재생할 수 없습니다',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                if (kIsWeb) {
                  _initializeWebVideo();
                } else {
                  _initializeVideo();
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 웹에서는 HTML video 요소 사용
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: HtmlElementView(
          viewType: _webVideoViewType,
        ),
      );
    }

    // 모바일에서는 기존 video_player 사용
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // 비디오 플레이어
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          
          // 컨트롤 오버레이
          if (_showControls) _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Column(
        children: [
          const Spacer(),
          
          // 재생/일시정지 버튼
          Center(
            child: IconButton(
              iconSize: 64,
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _togglePlayPause,
            ),
          ),
          
          const Spacer(),
          
          // 하단 컨트롤 바
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 진행 바
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blue,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white24,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 시간 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _controller!,
                      builder: (context, value, child) {
                        return Text(
                          _formatDuration(value.position),
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    Text(
                      _formatDuration(_controller!.value.duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
