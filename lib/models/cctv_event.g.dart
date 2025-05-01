part of 'cctv_event.dart';

_$CctvEventImpl _$$CctvEventImplFromJson(Map<String, dynamic> json) =>
    _$CctvEventImpl(
      camId: json['camId'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      objects: json['objects'] as List<dynamic>,
    );

Map<String, dynamic> _$$CctvEventImplToJson(_$CctvEventImpl instance) =>
    <String, dynamic>{
      'camId': instance.camId,
      'timestamp': instance.timestamp,
      'objects': instance.objects,
    };
