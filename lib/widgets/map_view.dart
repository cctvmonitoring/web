import 'package:flutter/material.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // 선택된 구역
  String? _selectedZone;
  
  // 구역별 보안 등급
  final Map<String, String> _zoneSecurityLevels = {
    'A구역': '높음',
    'B구역': '중간',
    'C구역': '낮음',
  };

  // 카메라 위치 및 상태
  final List<Map<String, dynamic>> _cameras = [
    {'id': '404호', 'x': 0.3, 'y': 0.4, 'status': '정상'},
    {'id': '405호', 'x': 0.6, 'y': 0.4, 'status': '정상'},
    {'id': '406호', 'x': 0.3, 'y': 0.7, 'status': '이상'},
    {'id': '407호', 'x': 0.6, 'y': 0.7, 'status': '정상'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 좌측 컨트롤 패널
        SizedBox(
          width: 250,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '구역 관리',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 구역 선택 드롭다운
                  DropdownButtonFormField<String>(
                    value: _selectedZone,
                    decoration: const InputDecoration(
                      labelText: '구역 선택',
                      border: OutlineInputBorder(),
                    ),
                    items: _zoneSecurityLevels.keys.map((String zone) {
                      return DropdownMenuItem<String>(
                        value: zone,
                        child: Text(zone),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedZone = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 보안 등급 설정
                  if (_selectedZone != null) ...[
                    Text('보안 등급: ${_zoneSecurityLevels[_selectedZone]}'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _zoneSecurityLevels[_selectedZone],
                      decoration: const InputDecoration(
                        labelText: '등급 변경',
                        border: OutlineInputBorder(),
                      ),
                      items: ['높음', '중간', '낮음'].map((String level) {
                        return DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null && _selectedZone != null) {
                          setState(() {
                            _zoneSecurityLevels[_selectedZone!] = newValue;
                          });
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    '카메라 상태',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cameras.length,
                      itemBuilder: (context, index) {
                        final camera = _cameras[index];
                        return ListTile(
                          leading: Icon(
                            Icons.videocam,
                            color: camera['status'] == '정상'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(camera['id']),
                          subtitle: Text('상태: ${camera['status']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              // TODO: 카메라 설정 다이얼로그
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 우측 평면도
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '시설 평면도',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_in),
                            onPressed: () {
                              // TODO: 확대 기능
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out),
                            onPressed: () {
                              // TODO: 축소 기능
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              // TODO: 새로고침
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        // 평면도 배경
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('평면도가 여기에 표시됩니다'),
                          ),
                        ),
                        // 카메라 위치 표시
                        ..._cameras.map((camera) {
                          return Positioned(
                            left: MediaQuery.of(context).size.width * camera['x'],
                            top: MediaQuery.of(context).size.height * camera['y'],
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: camera['status'] == '정상'
                                    ? Colors.green.withOpacity(0.8)
                                    : Colors.red.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 