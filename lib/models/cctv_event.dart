import 'package:freezed_annotation/freezed_annotation.dart';

part 'cctv_event.freezed.dart';
part 'cctv_event.g.dart';

@freezed
class CctvEvent with _$CctvEvent {
  const factory CctvEvent({
    required String camId,
    required int timestamp,
    required List<dynamic> objects,
  }) = _CctvEvent;

  factory CctvEvent.fromJson(Map<String, dynamic> json) => _$CctvEventFromJson(json);
}
