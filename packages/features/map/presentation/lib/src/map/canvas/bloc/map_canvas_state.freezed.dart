// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_canvas_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapCanvasState {

 MapContent get content; MapCanvasStatus get status; MapCameraFocus get focus; PlaceDetails? get selected; MapCanvasFailure? get failure;
/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapCanvasStateCopyWith<MapCanvasState> get copyWith => _$MapCanvasStateCopyWithImpl<MapCanvasState>(this as MapCanvasState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapCanvasState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapCanvasState&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.focus, _this.focus) || other.focus == _this.focus)&&(identical(other.selected, _this.selected) || other.selected == _this.selected)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as MapCanvasState;
  return Object.hash(runtimeType,_this.content,_this.status,_this.focus,_this.selected,_this.failure);
}

@override
String toString() {
  final _this = this as MapCanvasState;
  return 'MapCanvasState(content: ${_this.content}, status: ${_this.status}, focus: ${_this.focus}, selected: ${_this.selected}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $MapCanvasStateCopyWith<$Res>  {
  factory $MapCanvasStateCopyWith(MapCanvasState value, $Res Function(MapCanvasState) _then) = _$MapCanvasStateCopyWithImpl;
@useResult
$Res call({
 MapContent content, MapCanvasStatus status, MapCameraFocus focus, PlaceDetails? selected, MapCanvasFailure? failure
});


$MapContentCopyWith<$Res> get content;

}
/// @nodoc
class _$MapCanvasStateCopyWithImpl<$Res>
    implements $MapCanvasStateCopyWith<$Res> {
  _$MapCanvasStateCopyWithImpl(this._self, this._then);

  final MapCanvasState _self;
  final $Res Function(MapCanvasState) _then;

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? status = null,Object? focus = null,Object? selected = freezed,Object? failure = freezed,}) {
  return _then(MapCanvasState(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MapContent,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MapCanvasStatus,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as MapCameraFocus,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as MapCanvasFailure?,
  ));
}
/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapContentCopyWith<$Res> get content {
  
  return $MapContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapCanvasState].
extension MapCanvasStatePatterns on MapCanvasState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapCanvasState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapCanvasState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapCanvasState value)  $default,){
final _that = this;
switch (_that) {
case _MapCanvasState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapCanvasState value)?  $default,){
final _that = this;
switch (_that) {
case _MapCanvasState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapContent content,  MapCanvasStatus status,  MapCameraFocus focus,  PlaceDetails? selected,  MapCanvasFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapCanvasState() when $default != null:
return $default(_that.content,_that.status,_that.focus,_that.selected,_that.failure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapContent content,  MapCanvasStatus status,  MapCameraFocus focus,  PlaceDetails? selected,  MapCanvasFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _MapCanvasState():
return $default(_that.content,_that.status,_that.focus,_that.selected,_that.failure);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapContent content,  MapCanvasStatus status,  MapCameraFocus focus,  PlaceDetails? selected,  MapCanvasFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _MapCanvasState() when $default != null:
return $default(_that.content,_that.status,_that.focus,_that.selected,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _MapCanvasState extends MapCanvasState {
  const _MapCanvasState({this.content = const MapContent(), this.status = MapCanvasStatus.waitingForMap, this.focus = MapCameraFocus.places, this.selected, this.failure}): super._();
  

@override@JsonKey() final  MapContent content;
@override@JsonKey() final  MapCanvasStatus status;
@override@JsonKey() final  MapCameraFocus focus;
@override final  PlaceDetails? selected;
@override final  MapCanvasFailure? failure;

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapCanvasStateCopyWith<_MapCanvasState> get copyWith => __$MapCanvasStateCopyWithImpl<_MapCanvasState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapCanvasState&&(identical(other.content, content) || other.content == content)&&(identical(other.status, status) || other.status == status)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,content,status,focus,selected,failure);
}

@override
String toString() {
    return 'MapCanvasState(content: $content, status: $status, focus: $focus, selected: $selected, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$MapCanvasStateCopyWith<$Res> implements $MapCanvasStateCopyWith<$Res> {
  factory _$MapCanvasStateCopyWith(_MapCanvasState value, $Res Function(_MapCanvasState) _then) = __$MapCanvasStateCopyWithImpl;
@override @useResult
$Res call({
 MapContent content, MapCanvasStatus status, MapCameraFocus focus, PlaceDetails? selected, MapCanvasFailure? failure
});


@override $MapContentCopyWith<$Res> get content;

}
/// @nodoc
class __$MapCanvasStateCopyWithImpl<$Res>
    implements _$MapCanvasStateCopyWith<$Res> {
  __$MapCanvasStateCopyWithImpl(this._self, this._then);

  final _MapCanvasState _self;
  final $Res Function(_MapCanvasState) _then;

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? status = null,Object? focus = null,Object? selected = freezed,Object? failure = freezed,}) {
  return _then(_MapCanvasState(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MapContent,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MapCanvasStatus,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as MapCameraFocus,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as MapCanvasFailure?,
  ));
}

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapContentCopyWith<$Res> get content {
  
  return $MapContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}

// dart format on
