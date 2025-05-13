import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/camera_tile.dart';

class History2 extends StatefulWidget {
  final DateTime selectedDate;

  const History2({super.key, required this.selectedDate});

  @override
  State<History2> createState() => _History2State();
}

class _History2State extends State<History2> {
  double _currentPosition = 0.0; // 슬라이더 위치 (0~60분)
  bool _isPlaying = false; // 재생/일시정지 상태

  @override
  Widget build(BuildContext context) {
    // 선택한 날짜를 표시용으로 포맷팅
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selectedDate);
    // 현재 슬라이더 위치를 MM:SS 형식으로 포맷팅
    final currentTime = Duration(minutes: _currentPosition.toInt());
    final formattedTime = '${currentTime.inMinutes.toString().padLeft(2, '0')}:${(currentTime.inSeconds % 60).toString().padLeft(2, '0')}';
    const totalTime = '60:00'; // 전체 재생 시간 (60분)

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildFocusedLayout(context, '404호'), // 404호를 중심으로 하는 레이아웃 구성
          ),
          // 비디오 재생 컨트롤 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // 재생/일시정지 버튼
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                    // TODO: 비디오 재생/일시정지 로직 구현 예정
                  },
                ),
                const SizedBox(width: 8),
                Text(formattedTime, style: const TextStyle(fontSize: 16)), // 현재 시간
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _currentPosition,
                    min: 0.0,
                    max: 60.0, // 최대 60분
                    divisions: 3600, // 1초 단위로 나눔 (60 * 60)
                    label: formattedTime,
                    onChanged: (value) {
                      setState(() {
                        _currentPosition = value;
                      });
                      // TODO: 비디오 탐색(Seek) 로직 구현 예정
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(totalTime, style: const TextStyle(fontSize: 16)), // 전체 시간
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 404호 확대 카메라와 주변 카메라들을 포함한 레이아웃 구성
  Widget _buildFocusedLayout(BuildContext context, String focusedCamId) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        double centerWidth = width * 0.6;
        double centerHeight = height * 0.6;
        double sideWidth = width * 0.18;
        double sideHeight = centerHeight;
        double topBottomWidth = centerWidth;
        double topBottomHeight = height * 0.18;

        return Stack(
          children: [
            // 상단 카메라들
            Positioned(
              top: 0,
              left: (width - topBottomWidth) / 2,
              width: topBottomWidth,
              height: topBottomHeight,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${400 + index}호'),
                    ),
                  ),
                ),
              ),
            ),
            // 좌측 카메라들
            Positioned(
              top: topBottomHeight + 8,
              left: 0,
              width: sideWidth,
              height: sideHeight,
              child: Column(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${403 + index}호'),
                    ),
                  ),
                ),
              ),
            ),
            // 우측 카메라들
            Positioned(
              top: topBottomHeight + 8,
              right: 0,
              width: sideWidth,
              height: sideHeight,
              child: Column(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${406 + index}호'),
                    ),
                  ),
                ),
              ),
            ),
            // 하단 카메라들
            Positioned(
              bottom: 0,
              left: (width - topBottomWidth) / 2,
              width: topBottomWidth,
              height: topBottomHeight,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${409 + index}호'),
                    ),
                  ),
                ),
              ),
            ),
            // 중앙 확대 카메라 (404호)
            Center(
              child: Container(
                width: centerWidth,
                height: centerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 3), // 빨간 테두리 강조
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CameraTile(
                  roomName: focusedCamId,
                  isAlert: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
