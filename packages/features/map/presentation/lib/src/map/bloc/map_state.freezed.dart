// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapState {

 MapLayer? get layer; LocationFix? get location; bool get loadingLayer; bool get locating; Failure? get layerFailure; Failure? get locationFailure; String? get settingsMessage;
/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapStateCopyWith<MapState> get copyWith => _$MapStateCopyWithImpl<MapState>(this as MapState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapState&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.loadingLayer, _this.loadingLayer) || other.loadingLayer == _this.loadingLayer)&&(identical(other.locating, _this.locating) || other.locating == _this.locating)&&(identical(other.layerFailure, _this.layerFailure) || other.layerFailure == _this.layerFailure)&&(identical(other.locationFailure, _this.locationFailure) || other.locationFailure == _this.locationFailure)&&(identical(other.settingsMessage, _this.settingsMessage) || other.settingsMessage == _this.settingsMessage));
}


@override
int get hashCode {
  final _this = this as MapState;
  return Object.hash(runtimeType,_this.layer,_this.location,_this.loadingLayer,_this.locating,_this.layerFailure,_this.locationFailure,_this.settingsMessage);
}

@override
String toString() {
  final _this = this as MapState;
  return 'MapState(layer: ${_this.layer}, location: ${_this.location}, loadingLayer: ${_this.loadingLayer}, locating: ${_this.locating}, layerFailure: ${_this.layerFailure}, locationFailure: ${_this.locationFailure}, settingsMessage: ${_this.settingsMessage})';
}


}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res>  {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) = _$MapStateCopyWithImpl;
@useResult
$Res call({
 MapLayer? layer, LocationFix? location, bool loadingLayer, bool locating, Failure? layerFailure, Failure? locationFailure, String? settingsMessage
});




}
/// @nodoc
class _$MapStateCopyWithImpl<$Res>
    implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._self, this._then);

  final MapState _self;
  final $Res Function(MapState) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layer = freezed,Object? location = freezed,Object? loadingLayer = null,Object? locating = null,Object? layerFailure = freezed,Object? locationFailure = freezed,Object? settingsMessage = freezed,}) {
  return _then(MapState(
layer: freezed == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as MapLayer?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationFix?,loadingLayer: null == loadingLayer ? _self.loadingLayer : loadingLayer // ignore: cast_nullable_to_non_nullable
as bool,locating: null == locating ? _self.locating : locating // ignore: cast_nullable_to_non_nullable
as bool,layerFailure: freezed == layerFailure ? _self.layerFailure : layerFailure // ignore: cast_nullable_to_non_nullable
as Failure?,locationFailure: freezed == locationFailure ? _self.locationFailure : locationFailure // ignore: cast_nullable_to_non_nullable
as Failure?,settingsMessage: freezed == settingsMessage ? _self.settingsMessage : settingsMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MapState].
extension MapStatePatterns on MapState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapState value)  $default,){
final _that = this;
switch (_that) {
case _MapState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapState value)?  $default,){
final _that = this;
switch (_that) {
case _MapState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapLayer? layer,  LocationFix? location,  bool loadingLayer,  bool locating,  Failure? layerFailure,  Failure? locationFailure,  String? settingsMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that.layer,_that.location,_that.loadingLayer,_that.locating,_that.layerFailure,_that.locationFailure,_that.settingsMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapLayer? layer,  LocationFix? location,  bool loadingLayer,  bool locating,  Failure? layerFailure,  Failure? locationFailure,  String? settingsMessage)  $default,) {final _that = this;
switch (_that) {
case _MapState():
return $default(_that.layer,_that.location,_that.loadingLayer,_that.locating,_that.layerFailure,_that.locationFailure,_that.settingsMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapLayer? layer,  LocationFix? location,  bool loadingLayer,  bool locating,  Failure? layerFailure,  Failure? locationFailure,  String? settingsMessage)?  $default,) {final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that.layer,_that.location,_that.loadingLayer,_that.locating,_that.layerFailure,_that.locationFailure,_that.settingsMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MapState extends MapState {
  const _MapState({this.layer, this.location, this.loadingLayer = true, this.locating = false, this.layerFailure, this.locationFailure, this.settingsMessage}): super._();
  

@override final  MapLayer? layer;
@override final  LocationFix? location;
@override@JsonKey() final  bool loadingLayer;
@override@JsonKey() final  bool locating;
@override final  Failure? layerFailure;
@override final  Failure? locationFailure;
@override final  String? settingsMessage;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapStateCopyWith<_MapState> get copyWith => __$MapStateCopyWithImpl<_MapState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapState&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.location, location) || other.location == location)&&(identical(other.loadingLayer, loadingLayer) || other.loadingLayer == loadingLayer)&&(identical(other.locating, locating) || other.locating == locating)&&(identical(other.layerFailure, layerFailure) || other.layerFailure == layerFailure)&&(identical(other.locationFailure, locationFailure) || other.locationFailure == locationFailure)&&(identical(other.settingsMessage, settingsMessage) || other.settingsMessage == settingsMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,layer,location,loadingLayer,locating,layerFailure,locationFailure,settingsMessage);
}

@override
String toString() {
    return 'MapState(layer: $layer, location: $location, loadingLayer: $loadingLayer, locating: $locating, layerFailure: $layerFailure, locationFailure: $locationFailure, settingsMessage: $settingsMessage)';
}


}

/// @nodoc
abstract mixin class _$MapStateCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory _$MapStateCopyWith(_MapState value, $Res Function(_MapState) _then) = __$MapStateCopyWithImpl;
@override @useResult
$Res call({
 MapLayer? layer, LocationFix? location, bool loadingLayer, bool locating, Failure? layerFailure, Failure? locationFailure, String? settingsMessage
});




}
/// @nodoc
class __$MapStateCopyWithImpl<$Res>
    implements _$MapStateCopyWith<$Res> {
  __$MapStateCopyWithImpl(this._self, this._then);

  final _MapState _self;
  final $Res Function(_MapState) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layer = freezed,Object? location = freezed,Object? loadingLayer = null,Object? locating = null,Object? layerFailure = freezed,Object? locationFailure = freezed,Object? settingsMessage = freezed,}) {
  return _then(_MapState(
layer: freezed == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as MapLayer?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationFix?,loadingLayer: null == loadingLayer ? _self.loadingLayer : loadingLayer // ignore: cast_nullable_to_non_nullable
as bool,locating: null == locating ? _self.locating : locating // ignore: cast_nullable_to_non_nullable
as bool,layerFailure: freezed == layerFailure ? _self.layerFailure : layerFailure // ignore: cast_nullable_to_non_nullable
as Failure?,locationFailure: freezed == locationFailure ? _self.locationFailure : locationFailure // ignore: cast_nullable_to_non_nullable
as Failure?,settingsMessage: freezed == settingsMessage ? _self.settingsMessage : settingsMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
