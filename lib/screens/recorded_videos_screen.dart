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
  List<dynamic> _videos = [];
  List<dynamic> _filteredVideos = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  DateTime? _selectedDate;
  String _currentPath = '';
  int _offset = 0;
  final int _limit = 100;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadVideos(reset: true);
  }

  Future<void> _loadVideos({String? path, bool reset = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final offset = reset ? 0 : _offset;
      final videos = await VideoApiService.getRecordedVideos(path: path ?? _currentPath, offset: offset, limit: _limit);
      setState(() {
        if (reset) {
          _videos = videos;
        } else {
          // 폴더는 항상 맨 위에, 파일만 append
          final folders = videos.where((item) => item is Map && item['type'] == 'directory').toList();
          final files = videos.where((item) => item is RecordedVideo).toList();
          if (_offset == 0) {
            _videos = [...folders, ...files];
          } else {
            // 폴더는 이미 있으므로 파일만 추가
            _videos.addAll(files);
          }
        }
        _filteredVideos = _videos;
        _isLoading = false;
        _currentPath = path ?? _currentPath;
        _offset = offset + _limit;
        _hasMore = videos.where((item) => item is RecordedVideo).length == _limit;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterVideos() {
    List<dynamic> filtered = _videos;
    // 파일만 필터링 적용 (폴더는 항상 노출)
    if (_selectedDate != null || _searchQuery.isNotEmpty) {
      filtered = _videos.where((item) {
        if (item is RecordedVideo) {
          bool dateMatch = true;
          if (_selectedDate != null) {
            final recordedDate = item.recordedDateTime;
            if (recordedDate != null) {
              dateMatch = recordedDate.year == _selectedDate!.year &&
                          recordedDate.month == _selectedDate!.month &&
                          recordedDate.day == _selectedDate!.day;
            } else {
              dateMatch = false;
            }
          }
          bool searchMatch = _searchQuery.isEmpty ||
            item.filename.toLowerCase().contains(_searchQuery.toLowerCase());
          return dateMatch && searchMatch;
        }
        // 폴더는 항상 노출
        return item is Map && item['type'] == 'directory';
      }).toList();
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

  void _loadMore() {
    _loadVideos(reset: false);
  }

  void _enterFolder(String folderName) {
    final newPath = _currentPath.isEmpty ? folderName : '$_currentPath/$folderName';
    setState(() {
      _offset = 0;
      _hasMore = true;
    });
    _loadVideos(path: newPath, reset: true);
  }

  bool get _isRoot => _currentPath.isEmpty;

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
         if (_hasMore && !_isLoading && _filteredVideos.any((item) => item is RecordedVideo))
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 8),
             child: ElevatedButton(
               onPressed: _loadMore,
               child: const Text('더 보기'),
             ),
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
      itemCount: _filteredVideos.length + (_isRoot ? 0 : 1),
      itemBuilder: (context, index) {
        // 상위 폴더로 이동 버튼
        if (!_isRoot && index == 0) {
          return ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.white),
            title: const Text('상위 폴더로', style: TextStyle(color: Colors.white)),
            onTap: () {
              final parts = _currentPath.split('/');
              parts.removeLast();
              final parentPath = parts.join('/');
              _loadVideos(path: parentPath.isEmpty ? null : parentPath);
            },
          );
        }
        final realIndex = _isRoot ? index : index - 1;
        final item = _filteredVideos[realIndex];
        if (item is RecordedVideo) {
          return _buildVideoCard(item);
        } else if (item is Map && item['type'] == 'directory') {
          return ListTile(
            leading: const Icon(Icons.folder, color: Colors.amber),
            title: Text(item['name'], style: const TextStyle(color: Colors.white)),
            onTap: () => _enterFolder(item['name']),
          );
        } else {
          return const SizedBox.shrink();
        }
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
