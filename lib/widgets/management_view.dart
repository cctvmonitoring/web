import 'package:flutter/material.dart';

class ManagementView extends StatefulWidget {
  const ManagementView({super.key});

  @override
  State<ManagementView> createState() => _ManagementViewState();
}

class _ManagementViewState extends State<ManagementView> {
  // 선택된 관리 카테고리
  String _selectedCategory = '사용자 관리';

  // 사용자 목록 데이터
  final List<Map<String, dynamic>> _users = [
    {
      'name': '관리자',
      'role': '시스템 관리자',
      'lastLogin': '2024-03-20 10:30',
      'status': '활성',
    },
    {
      'name': '보안관리자',
      'role': '보안 관리자',
      'lastLogin': '2024-03-20 09:15',
      'status': '활성',
    },
    {
      'name': '감시원1',
      'role': '감시원',
      'lastLogin': '2024-03-20 08:45',
      'status': '활성',
    },
  ];

  // 카메라 설정 데이터
  final List<Map<String, dynamic>> _cameras = [
    {
      'id': 'CAM001',
      'location': '1층 로비',
      'status': '정상',
      'resolution': '1080p',
      'fps': 30,
    },
    {
      'id': 'CAM002',
      'location': '2층 복도',
      'status': '정상',
      'resolution': '1080p',
      'fps': 30,
    },
    {
      'id': 'CAM003',
      'location': '주차장',
      'status': '점검중',
      'resolution': '1080p',
      'fps': 30,
    },
  ];

  // 알림 규칙 데이터
  final List<Map<String, dynamic>> _notificationRules = [
    {
      'name': '사람 감지',
      'type': '객체 감지',
      'action': '알림 전송',
      'status': '활성',
    },
    {
      'name': '이상 행동',
      'type': '행동 분석',
      'action': '알림 전송 + 녹화',
      'status': '활성',
    },
    {
      'name': '시스템 오류',
      'type': '시스템',
      'action': '관리자 알림',
      'status': '활성',
    },
  ];

  // 시스템 로그 데이터
  final List<Map<String, dynamic>> _systemLogs = [
    {
      'timestamp': '2024-03-20 10:30:15',
      'level': 'INFO',
      'message': '시스템 시작',
    },
    {
      'timestamp': '2024-03-20 10:30:20',
      'level': 'INFO',
      'message': '카메라 연결 완료',
    },
    {
      'timestamp': '2024-03-20 10:31:00',
      'level': 'WARNING',
      'message': 'CAM003 카메라 연결 불안정',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 카테고리 선택
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                '관리 카테고리:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCategory,
                items: [
                  '사용자 관리',
                  '카메라 설정',
                  '알림 규칙',
                  '시스템 로그',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        // 관리 내용 표시
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // 새 항목 추가 기능
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('새로 만들기'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildManagementContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementContent() {
    switch (_selectedCategory) {
      case '사용자 관리':
        return _buildUserManagement();
      case '카메라 설정':
        return _buildCameraSettings();
      case '알림 규칙':
        return _buildNotificationRules();
      case '시스템 로그':
        return _buildSystemLogs();
      default:
        return const Center(child: Text('데이터를 불러오는 중...'));
    }
  }

  Widget _buildUserManagement() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 사용자 목록 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '이름',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '역할',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '마지막 로그인',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '상태',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '작업',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 사용자 목록
          ..._users.map((user) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(user['name']),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(user['role']),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(user['lastLogin']),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: user['status'] == '활성'
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        user['status'],
                        style: TextStyle(
                          color: user['status'] == '활성'
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // 사용자 수정 기능
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // 사용자 삭제 기능
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCameraSettings() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 카메라 설정 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '위치',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '상태',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '해상도',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'FPS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '작업',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 카메라 설정 목록
          ..._cameras.map((camera) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(camera['id']),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(camera['location']),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: camera['status'] == '정상'
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        camera['status'],
                        style: TextStyle(
                          color: camera['status'] == '정상'
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(camera['resolution']),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('${camera['fps']}'),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // 카메라 설정 수정 기능
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            // 카메라 재시작 기능
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationRules() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 알림 규칙 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '이름',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '유형',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '동작',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '상태',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '작업',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 알림 규칙 목록
          ..._notificationRules.map((rule) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(rule['name']),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(rule['type']),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(rule['action']),
                  ),
                  Expanded(
                    flex: 1,
                    child: Switch(
                      value: rule['status'] == '활성',
                      onChanged: (bool value) {
                        // 알림 규칙 활성화/비활성화 기능
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // 알림 규칙 수정 기능
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // 알림 규칙 삭제 기능
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSystemLogs() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 시스템 로그 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '시간',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '레벨',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '메시지',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 시스템 로그 목록
          ..._systemLogs.map((log) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(log['timestamp']),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: log['level'] == 'INFO'
                            ? Colors.blue[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        log['level'],
                        style: TextStyle(
                          color: log['level'] == 'INFO'
                              ? Colors.blue[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(log['message']),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
} 