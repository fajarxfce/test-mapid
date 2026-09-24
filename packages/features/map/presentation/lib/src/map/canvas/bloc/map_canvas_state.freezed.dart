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

 MapScene get scene; MapRenderStatus get renderStatus; PlaceDetails? get selected;
/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapCanvasStateCopyWith<MapCanvasState> get copyWith => _$MapCanvasStateCopyWithImpl<MapCanvasState>(this as MapCanvasState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapCanvasState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapCanvasState&&(identical(other.scene, _this.scene) || other.scene == _this.scene)&&(identical(other.renderStatus, _this.renderStatus) || other.renderStatus == _this.renderStatus)&&(identical(other.selected, _this.selected) || other.selected == _this.selected));
}


@override
int get hashCode {
  final _this = this as MapCanvasState;
  return Object.hash(runtimeType,_this.scene,_this.renderStatus,_this.selected);
}

@override
String toString() {
  final _this = this as MapCanvasState;
  return 'MapCanvasState(scene: ${_this.scene}, renderStatus: ${_this.renderStatus}, selected: ${_this.selected})';
}


}

/// @nodoc
abstract mixin class $MapCanvasStateCopyWith<$Res>  {
  factory $MapCanvasStateCopyWith(MapCanvasState value, $Res Function(MapCanvasState) _then) = _$MapCanvasStateCopyWithImpl;
@useResult
$Res call({
 MapScene scene, MapRenderStatus renderStatus, PlaceDetails? selected
});


$MapSceneCopyWith<$Res> get scene;

}
/// @nodoc
class _$MapCanvasStateCopyWithImpl<$Res>
    implements $MapCanvasStateCopyWith<$Res> {
  _$MapCanvasStateCopyWithImpl(this._self, this._then);

  final MapCanvasState _self;
  final $Res Function(MapCanvasState) _then;

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scene = null,Object? renderStatus = null,Object? selected = freezed,}) {
  return _then(MapCanvasState(
scene: null == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as MapScene,renderStatus: null == renderStatus ? _self.renderStatus : renderStatus // ignore: cast_nullable_to_non_nullable
as MapRenderStatus,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,
  ));
}
/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapSceneCopyWith<$Res> get scene {
  
  return $MapSceneCopyWith<$Res>(_self.scene, (value) {
    return _then(_self.copyWith(scene: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapScene scene,  MapRenderStatus renderStatus,  PlaceDetails? selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapCanvasState() when $default != null:
return $default(_that.scene,_that.renderStatus,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapScene scene,  MapRenderStatus renderStatus,  PlaceDetails? selected)  $default,) {final _that = this;
switch (_that) {
case _MapCanvasState():
return $default(_that.scene,_that.renderStatus,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapScene scene,  MapRenderStatus renderStatus,  PlaceDetails? selected)?  $default,) {final _that = this;
switch (_that) {
case _MapCanvasState() when $default != null:
return $default(_that.scene,_that.renderStatus,_that.selected);case _:
  return null;

}
}

}

/// @nodoc


class _MapCanvasState extends MapCanvasState {
  const _MapCanvasState({this.scene = const MapScene(), this.renderStatus = MapRenderStatus.waitingForMap, this.selected}): super._();
  

@override@JsonKey() final  MapScene scene;
@override@JsonKey() final  MapRenderStatus renderStatus;
@override final  PlaceDetails? selected;

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapCanvasStateCopyWith<_MapCanvasState> get copyWith => __$MapCanvasStateCopyWithImpl<_MapCanvasState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapCanvasState&&(identical(other.scene, scene) || other.scene == scene)&&(identical(other.renderStatus, renderStatus) || other.renderStatus == renderStatus)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,scene,renderStatus,selected);
}

@override
String toString() {
    return 'MapCanvasState(scene: $scene, renderStatus: $renderStatus, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$MapCanvasStateCopyWith<$Res> implements $MapCanvasStateCopyWith<$Res> {
  factory _$MapCanvasStateCopyWith(_MapCanvasState value, $Res Function(_MapCanvasState) _then) = __$MapCanvasStateCopyWithImpl;
@override @useResult
$Res call({
 MapScene scene, MapRenderStatus renderStatus, PlaceDetails? selected
});


@override $MapSceneCopyWith<$Res> get scene;

}
/// @nodoc
class __$MapCanvasStateCopyWithImpl<$Res>
    implements _$MapCanvasStateCopyWith<$Res> {
  __$MapCanvasStateCopyWithImpl(this._self, this._then);

  final _MapCanvasState _self;
  final $Res Function(_MapCanvasState) _then;

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scene = null,Object? renderStatus = null,Object? selected = freezed,}) {
  return _then(_MapCanvasState(
scene: null == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as MapScene,renderStatus: null == renderStatus ? _self.renderStatus : renderStatus // ignore: cast_nullable_to_non_nullable
as MapRenderStatus,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,
  ));
}

/// Create a copy of MapCanvasState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapSceneCopyWith<$Res> get scene {
  
  return $MapSceneCopyWith<$Res>(_self.scene, (value) {
    return _then(_self.copyWith(scene: value));
  });
}
}

// dart format on
