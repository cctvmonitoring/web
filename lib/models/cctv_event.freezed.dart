part of 'cctv_event.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CctvEvent _$CctvEventFromJson(Map<String, dynamic> json) {
  return _CctvEvent.fromJson(json);
}

/// @nodoc
mixin _$CctvEvent {
  String get camId => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  List<dynamic> get objects => throw _privateConstructorUsedError;

  /// Serializes this CctvEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CctvEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CctvEventCopyWith<CctvEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CctvEventCopyWith<$Res> {
  factory $CctvEventCopyWith(CctvEvent value, $Res Function(CctvEvent) then) =
      _$CctvEventCopyWithImpl<$Res, CctvEvent>;
  @useResult
  $Res call({String camId, int timestamp, List<dynamic> objects});
}

/// @nodoc
class _$CctvEventCopyWithImpl<$Res, $Val extends CctvEvent>
    implements $CctvEventCopyWith<$Res> {
  _$CctvEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CctvEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? camId = null,
    Object? timestamp = null,
    Object? objects = null,
  }) {
    return _then(
      _value.copyWith(
            camId:
                null == camId
                    ? _value.camId
                    : camId // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as int,
            objects:
                null == objects
                    ? _value.objects
                    : objects // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CctvEventImplCopyWith<$Res>
    implements $CctvEventCopyWith<$Res> {
  factory _$$CctvEventImplCopyWith(
    _$CctvEventImpl value,
    $Res Function(_$CctvEventImpl) then,
  ) = __$$CctvEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String camId, int timestamp, List<dynamic> objects});
}

/// @nodoc
class __$$CctvEventImplCopyWithImpl<$Res>
    extends _$CctvEventCopyWithImpl<$Res, _$CctvEventImpl>
    implements _$$CctvEventImplCopyWith<$Res> {
  __$$CctvEventImplCopyWithImpl(
    _$CctvEventImpl _value,
    $Res Function(_$CctvEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CctvEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? camId = null,
    Object? timestamp = null,
    Object? objects = null,
  }) {
    return _then(
      _$CctvEventImpl(
        camId:
            null == camId
                ? _value.camId
                : camId // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as int,
        objects:
            null == objects
                ? _value._objects
                : objects // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CctvEventImpl implements _CctvEvent {
  const _$CctvEventImpl({
    required this.camId,
    required this.timestamp,
    required final List<dynamic> objects,
  }) : _objects = objects;

  factory _$CctvEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CctvEventImplFromJson(json);

  @override
  final String camId;
  @override
  final int timestamp;
  final List<dynamic> _objects;
  @override
  List<dynamic> get objects {
    if (_objects is EqualUnmodifiableListView) return _objects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_objects);
  }

  @override
  String toString() {
    return 'CctvEvent(camId: $camId, timestamp: $timestamp, objects: $objects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CctvEventImpl &&
            (identical(other.camId, camId) || other.camId == camId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._objects, _objects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    camId,
    timestamp,
    const DeepCollectionEquality().hash(_objects),
  );

  /// Create a copy of CctvEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CctvEventImplCopyWith<_$CctvEventImpl> get copyWith =>
      __$$CctvEventImplCopyWithImpl<_$CctvEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CctvEventImplToJson(this);
  }
}

abstract class _CctvEvent implements CctvEvent {
  const factory _CctvEvent({
    required final String camId,
    required final int timestamp,
    required final List<dynamic> objects,
  }) = _$CctvEventImpl;

  factory _CctvEvent.fromJson(Map<String, dynamic> json) =
      _$CctvEventImpl.fromJson;

  @override
  String get camId;
  @override
  int get timestamp;
  @override
  List<dynamic> get objects;

  /// Create a copy of CctvEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CctvEventImplCopyWith<_$CctvEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
