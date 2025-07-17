/// 녹화된 영상 데이터 모델
/// 서버에서 받은 영상 파일 정보를 담는 클래스
class RecordedVideo {
  final String filename;    // 파일명 (recv_20250530_003433.mp4)
  final int size;          // 파일 크기 (바이트)
  final DateTime created;  // 파일 생성일
  final DateTime modified; // 파일 수정일
  final String url;        // 스트리밍 URL (/videos/파일명)

  RecordedVideo({
    required this.filename,
    required this.size,
    required this.created,
    required this.modified,
    required this.url,
  });

  factory RecordedVideo.fromJson(Map<String, dynamic> json) {
    return RecordedVideo(
      filename: (json['filename'] ?? json['name']) as String,
      size: json['size'] as int,
      created: json['created'] != null ? DateTime.parse(json['created'] as String) : DateTime.now(),
      modified: json['modified'] != null ? DateTime.parse(json['modified'] as String) : DateTime.now(),
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'size': size,
      'created': created.toIso8601String(),
      'modified': modified.toIso8601String(),
      'url': url,
    };
  }

  /// 파일 크기를 읽기 쉬운 형태로 변환 (B, KB, MB, GB)
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// 파일명에서 녹화 날짜/시간 추출
  /// recv_20250530_003433.mp4 -> 2025-05-30 00:34:33
  DateTime? get recordedDateTime {
    final match = RegExp(r'recv_(\d{8})_(\d{6})\.mp4').firstMatch(filename);
    if (match != null) {
      final dateStr = match.group(1)!; // 20250530
      final timeStr = match.group(2)!; // 003433

      // 날짜 파싱: YYYYMMDD
      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));

      // 시간 파싱: HHMMSS
      final hour = int.parse(timeStr.substring(0, 2));
      final minute = int.parse(timeStr.substring(2, 4));
      final second = int.parse(timeStr.substring(4, 6));

      return DateTime(year, month, day, hour, minute, second);
    }
    return null; // 파일명 형식이 맞지 않으면 null
  }

  /// 녹화 날짜를 문자열로 반환 (2025-05-30)
  String get recordedDateString {
    final dateTime = recordedDateTime;
    if (dateTime != null) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }

  /// 녹화 시간을 문자열로 반환 (00:34:33)
  String get recordedTimeString {
    final dateTime = recordedDateTime;
    if (dateTime != null) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }

  /// 영상 고유 ID 추출 (20250530_003433)
  String get videoId {
    final match = RegExp(r'recv_(\d{8}_\d{6})\.mp4').firstMatch(filename);
    return match?.group(1) ?? 'Unknown';
  }
}
