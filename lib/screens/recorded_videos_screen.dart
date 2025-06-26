import 'package:flutter/material.dart';
import '../models/recorded_video.dart';
import '../services/video_api_service.dart';
import 'video_player_screen.dart';

class RecordedVideosScreen extends StatefulWidget {
  const RecordedVideosScreen({super.key});

  @override
  State<RecordedVideosScreen> createState() => _RecordedVideosScreenState();
}

class _RecordedVideosScreenState extends State<RecordedVideosScreen> {
  List<RecordedVideo> _videos = [];
  List<RecordedVideo> _filteredVideos = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final videos = await VideoApiService.getRecordedVideos();
      setState(() {
        _videos = videos;
        _filteredVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterVideos() {
    List<RecordedVideo> filtered = _videos;

    // 날짜 필터링
    if (_selectedDate != null) {
      filtered = VideoApiService.filterVideosByDate(filtered, _selectedDate!);
    }

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filtered = VideoApiService.searchVideosByFilename(filtered, _searchQuery);
    }

    setState(() {
      _filteredVideos = filtered;
    });
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _filterVideos();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _filterVideos();
  }

  void _playVideo(RecordedVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              border: Border(
                bottom: BorderSide(color: Colors.grey[700]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                // 제목
                const Text(
                  '녹화영상 목록',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 검색바와 필터 버튼
                Row(
                  children: [
                    // 검색바
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '파일명, 날짜, 시간으로 검색... (예: 20250530, 003433)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFF3A3A3A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _filterVideos();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 날짜 필터 버튼
                    ElevatedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(_selectedDate != null 
                        ? '${_selectedDate!.month}/${_selectedDate!.day}'
                        : '날짜'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDate != null 
                          ? Colors.blue[600] 
                          : const Color(0xFF3A3A3A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    // 날짜 필터 초기화 버튼
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _clearDateFilter,
                        icon: const Icon(Icons.clear, color: Colors.white),
                        tooltip: '날짜 필터 해제',
                      ),
                    ],
                    
                    // 새로고침 버튼
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _loadVideos,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: '새로고침',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 영상 목록
          Expanded(
            child: _buildVideoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(color: Colors.red[400], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideos,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _videos.isEmpty ? '녹화된 영상이 없습니다' : '검색 결과가 없습니다',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVideos.length,
      itemBuilder: (context, index) {
        final video = _filteredVideos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(RecordedVideo video) {
    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.play_circle_outline,
            color: Colors.blue,
            size: 24,
          ),
        ),
        title: Text(
          video.filename,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '녹화일시: ${video.recordedDateString} ${video.recordedTimeString}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            Text(
              '파일생성: ${_formatDateTime(video.created)}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            Text(
              '크기: ${video.formattedSize}',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
        trailing: const Icon(Icons.play_arrow, color: Colors.blue),
        onTap: () => _playVideo(video),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
