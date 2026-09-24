// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapScene {

 MapContent get content; MapCameraFocus get focus;
/// Create a copy of MapScene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapSceneCopyWith<MapScene> get copyWith => _$MapSceneCopyWithImpl<MapScene>(this as MapScene, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapScene;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapScene&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.focus, _this.focus) || other.focus == _this.focus));
}


@override
int get hashCode {
  final _this = this as MapScene;
  return Object.hash(runtimeType,_this.content,_this.focus);
}

@override
String toString() {
  final _this = this as MapScene;
  return 'MapScene(content: ${_this.content}, focus: ${_this.focus})';
}


}

/// @nodoc
abstract mixin class $MapSceneCopyWith<$Res>  {
  factory $MapSceneCopyWith(MapScene value, $Res Function(MapScene) _then) = _$MapSceneCopyWithImpl;
@useResult
$Res call({
 MapContent content, MapCameraFocus focus
});


$MapContentCopyWith<$Res> get content;

}
/// @nodoc
class _$MapSceneCopyWithImpl<$Res>
    implements $MapSceneCopyWith<$Res> {
  _$MapSceneCopyWithImpl(this._self, this._then);

  final MapScene _self;
  final $Res Function(MapScene) _then;

/// Create a copy of MapScene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? focus = null,}) {
  return _then(MapScene(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MapContent,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as MapCameraFocus,
  ));
}
/// Create a copy of MapScene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapContentCopyWith<$Res> get content {
  
  return $MapContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapScene].
extension MapScenePatterns on MapScene {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapScene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapScene() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapScene value)  $default,){
final _that = this;
switch (_that) {
case _MapScene():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapScene value)?  $default,){
final _that = this;
switch (_that) {
case _MapScene() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapContent content,  MapCameraFocus focus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapScene() when $default != null:
return $default(_that.content,_that.focus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapContent content,  MapCameraFocus focus)  $default,) {final _that = this;
switch (_that) {
case _MapScene():
return $default(_that.content,_that.focus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapContent content,  MapCameraFocus focus)?  $default,) {final _that = this;
switch (_that) {
case _MapScene() when $default != null:
return $default(_that.content,_that.focus);case _:
  return null;

}
}

}

/// @nodoc


class _MapScene implements MapScene {
  const _MapScene({this.content = const MapContent(), this.focus = MapCameraFocus.places});
  

@override@JsonKey() final  MapContent content;
@override@JsonKey() final  MapCameraFocus focus;

/// Create a copy of MapScene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapSceneCopyWith<_MapScene> get copyWith => __$MapSceneCopyWithImpl<_MapScene>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapScene&&(identical(other.content, content) || other.content == content)&&(identical(other.focus, focus) || other.focus == focus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,content,focus);
}

@override
String toString() {
    return 'MapScene(content: $content, focus: $focus)';
}


}

/// @nodoc
abstract mixin class _$MapSceneCopyWith<$Res> implements $MapSceneCopyWith<$Res> {
  factory _$MapSceneCopyWith(_MapScene value, $Res Function(_MapScene) _then) = __$MapSceneCopyWithImpl;
@override @useResult
$Res call({
 MapContent content, MapCameraFocus focus
});


@override $MapContentCopyWith<$Res> get content;

}
/// @nodoc
class __$MapSceneCopyWithImpl<$Res>
    implements _$MapSceneCopyWith<$Res> {
  __$MapSceneCopyWithImpl(this._self, this._then);

  final _MapScene _self;
  final $Res Function(_MapScene) _then;

/// Create a copy of MapScene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? focus = null,}) {
  return _then(_MapScene(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MapContent,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as MapCameraFocus,
  ));
}

/// Create a copy of MapScene
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
