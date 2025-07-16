import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recorded_video.dart';
import '../core/constants.dart';

/// 녹화 영상 관련 API 서비스
/// 서버와 통신하여 영상 목록 조회, 검색, 필터링 기능 제공
class VideoApiService {
  // 서버 URL - constants.dart에서 IP 주소 가져옴
  static const String baseUrl = nodeServerUrl; // 'http://192.168.1.10:3000'
  
  /// 서버에서 녹화된 영상 및 폴더 목록 조회 (폴더 브라우저 지원)
  /// GET /api/videos 호출하여 폴더/파일 혼합 목록 반환
  static Future<List<dynamic>> getRecordedVideos({String? path}) async {
    try {
      final uri = path == null
        ? Uri.parse('$baseUrl/api/videos')
        : Uri.parse('$baseUrl/api/videos?path=$path');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10)); // 10초 타임아웃

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videosJson = data['videos'] as List;

        // 폴더/파일 분기 처리
        return videosJson.map((item) {
          if (item['type'] == 'file') {
            return RecordedVideo.fromJson(item);
          } else if (item['type'] == 'directory') {
            // 폴더는 Map 그대로 반환 (추후 FolderItem 모델화 가능)
            return item;
          } else {
            return null;
          }
        }).where((e) => e != null).toList();
      } else {
        throw Exception('Failed to load videos: \\${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }



  /// 영상 스트리밍 URL 생성
  /// 파일명을 받아서 웹에서 재생 가능한 전체 URL 반환
  static String getVideoUrl(String filename) {
    return '$baseUrl/videos/$filename';
  }

  /// 영상 파일 존재 여부 확인
  /// HEAD 요청으로 파일이 서버에 있는지 체크
  static Future<bool> checkVideoExists(String filename) async {
    try {
      final response = await http.head(
        Uri.parse(getVideoUrl(filename)),
      ).timeout(const Duration(seconds: 5)); // 5초 타임아웃

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking video existence: $e');
      return false;
    }
  }

  /// 날짜별 영상 필터링
  /// 파일명의 녹화 날짜 기준으로 필터링 (recv_20250530_003433.mp4)
  static List<RecordedVideo> filterVideosByDate(
    List<RecordedVideo> videos,
    DateTime date
  ) {
    return videos.where((video) {
      final recordedDate = video.recordedDateTime;
      if (recordedDate != null) {
        // 파일명에서 추출한 녹화 날짜로 비교
        return recordedDate.year == date.year &&
               recordedDate.month == date.month &&
               recordedDate.day == date.day;
      }
      // 파일명 파싱 실패 시 파일 생성일로 대체
      return video.created.year == date.year &&
             video.created.month == date.month &&
             video.created.day == date.day;
    }).toList();
  }

  /// 영상 검색 기능
  /// 파일명, 날짜, 시간, ID로 검색 가능 (예: "20250530", "003433", "recv_")
  static List<RecordedVideo> searchVideosByFilename(
    List<RecordedVideo> videos,
    String query
  ) {
    if (query.isEmpty) return videos;

    final lowerQuery = query.toLowerCase();

    return videos.where((video) {
      return video.filename.toLowerCase().contains(lowerQuery) ||      // 파일명
             video.videoId.contains(query) ||                          // 영상ID
             video.recordedDateString.contains(query) ||               // 날짜
             video.recordedTimeString.contains(query);                 // 시간
    }).toList();
  }
}
