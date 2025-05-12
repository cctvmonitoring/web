import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool _isNotificationEnabled = true; // 알림 활성화 상태
  String _selectedTheme = 'Light'; // 선택된 테마
  String _selectedLanguage = '한국어'; // 선택된 언어

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            '일반 설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('알림 활성화'),
            trailing: Switch(
              value: _isNotificationEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isNotificationEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('테마 변경'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              items: const [
                DropdownMenuItem(value: 'Light', child: Text('라이트 모드')),
                DropdownMenuItem(value: 'Dark', child: Text('다크 모드')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedTheme = value!;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('언어 설정'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: '한국어', child: Text('한국어')),
                DropdownMenuItem(value: 'English', child: Text('English')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ),
          const Divider(),
          const Text(
            '보안 설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('2단계 인증 활성화'),
            trailing: Switch(
              value: false, // 기본값
              onChanged: (bool value) {
                // TODO: 2단계 인증 로직 추가
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('비밀번호 변경'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: 비밀번호 변경 화면으로 이동
              },
              child: const Text('변경'),
            ),
          ),
          const Divider(),
          const Text(
            '시스템 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('앱 버전'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('서버 상태'),
            subtitle: const Text('정상 작동 중'),
          ),
        ],
      ),
    );
  }
}
