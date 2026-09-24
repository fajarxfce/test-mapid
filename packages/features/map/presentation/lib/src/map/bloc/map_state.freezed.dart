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

 bool get loadingLayer; bool get locating; bool get styleReady; int get placeCount; String get layerName; String? get layerError; String? get mapError; String? get locationMessage; LocationAction get locationAction; PlaceDetails? get selected;
/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapStateCopyWith<MapState> get copyWith => _$MapStateCopyWithImpl<MapState>(this as MapState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapState&&(identical(other.loadingLayer, _this.loadingLayer) || other.loadingLayer == _this.loadingLayer)&&(identical(other.locating, _this.locating) || other.locating == _this.locating)&&(identical(other.styleReady, _this.styleReady) || other.styleReady == _this.styleReady)&&(identical(other.placeCount, _this.placeCount) || other.placeCount == _this.placeCount)&&(identical(other.layerName, _this.layerName) || other.layerName == _this.layerName)&&(identical(other.layerError, _this.layerError) || other.layerError == _this.layerError)&&(identical(other.mapError, _this.mapError) || other.mapError == _this.mapError)&&(identical(other.locationMessage, _this.locationMessage) || other.locationMessage == _this.locationMessage)&&(identical(other.locationAction, _this.locationAction) || other.locationAction == _this.locationAction)&&(identical(other.selected, _this.selected) || other.selected == _this.selected));
}


@override
int get hashCode {
  final _this = this as MapState;
  return Object.hash(runtimeType,_this.loadingLayer,_this.locating,_this.styleReady,_this.placeCount,_this.layerName,_this.layerError,_this.mapError,_this.locationMessage,_this.locationAction,_this.selected);
}

@override
String toString() {
  final _this = this as MapState;
  return 'MapState(loadingLayer: ${_this.loadingLayer}, locating: ${_this.locating}, styleReady: ${_this.styleReady}, placeCount: ${_this.placeCount}, layerName: ${_this.layerName}, layerError: ${_this.layerError}, mapError: ${_this.mapError}, locationMessage: ${_this.locationMessage}, locationAction: ${_this.locationAction}, selected: ${_this.selected})';
}


}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res>  {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) = _$MapStateCopyWithImpl;
@useResult
$Res call({
 bool loadingLayer, bool locating, bool styleReady, int placeCount, String layerName, String? layerError, String? mapError, String? locationMessage, LocationAction locationAction, PlaceDetails? selected
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
@pragma('vm:prefer-inline') @override $Res call({Object? loadingLayer = null,Object? locating = null,Object? styleReady = null,Object? placeCount = null,Object? layerName = null,Object? layerError = freezed,Object? mapError = freezed,Object? locationMessage = freezed,Object? locationAction = null,Object? selected = freezed,}) {
  return _then(MapState(
loadingLayer: null == loadingLayer ? _self.loadingLayer : loadingLayer // ignore: cast_nullable_to_non_nullable
as bool,locating: null == locating ? _self.locating : locating // ignore: cast_nullable_to_non_nullable
as bool,styleReady: null == styleReady ? _self.styleReady : styleReady // ignore: cast_nullable_to_non_nullable
as bool,placeCount: null == placeCount ? _self.placeCount : placeCount // ignore: cast_nullable_to_non_nullable
as int,layerName: null == layerName ? _self.layerName : layerName // ignore: cast_nullable_to_non_nullable
as String,layerError: freezed == layerError ? _self.layerError : layerError // ignore: cast_nullable_to_non_nullable
as String?,mapError: freezed == mapError ? _self.mapError : mapError // ignore: cast_nullable_to_non_nullable
as String?,locationMessage: freezed == locationMessage ? _self.locationMessage : locationMessage // ignore: cast_nullable_to_non_nullable
as String?,locationAction: null == locationAction ? _self.locationAction : locationAction // ignore: cast_nullable_to_non_nullable
as LocationAction,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loadingLayer,  bool locating,  bool styleReady,  int placeCount,  String layerName,  String? layerError,  String? mapError,  String? locationMessage,  LocationAction locationAction,  PlaceDetails? selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that.loadingLayer,_that.locating,_that.styleReady,_that.placeCount,_that.layerName,_that.layerError,_that.mapError,_that.locationMessage,_that.locationAction,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loadingLayer,  bool locating,  bool styleReady,  int placeCount,  String layerName,  String? layerError,  String? mapError,  String? locationMessage,  LocationAction locationAction,  PlaceDetails? selected)  $default,) {final _that = this;
switch (_that) {
case _MapState():
return $default(_that.loadingLayer,_that.locating,_that.styleReady,_that.placeCount,_that.layerName,_that.layerError,_that.mapError,_that.locationMessage,_that.locationAction,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loadingLayer,  bool locating,  bool styleReady,  int placeCount,  String layerName,  String? layerError,  String? mapError,  String? locationMessage,  LocationAction locationAction,  PlaceDetails? selected)?  $default,) {final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that.loadingLayer,_that.locating,_that.styleReady,_that.placeCount,_that.layerName,_that.layerError,_that.mapError,_that.locationMessage,_that.locationAction,_that.selected);case _:
  return null;

}
}

}

/// @nodoc


class _MapState extends MapState {
  const _MapState({this.loadingLayer = true, this.locating = false, this.styleReady = false, this.placeCount = 0, this.layerName = 'Pariwisata Jogja', this.layerError, this.mapError, this.locationMessage, this.locationAction = LocationAction.locate, this.selected}): super._();
  

@override@JsonKey() final  bool loadingLayer;
@override@JsonKey() final  bool locating;
@override@JsonKey() final  bool styleReady;
@override@JsonKey() final  int placeCount;
@override@JsonKey() final  String layerName;
@override final  String? layerError;
@override final  String? mapError;
@override final  String? locationMessage;
@override@JsonKey() final  LocationAction locationAction;
@override final  PlaceDetails? selected;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapStateCopyWith<_MapState> get copyWith => __$MapStateCopyWithImpl<_MapState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapState&&(identical(other.loadingLayer, loadingLayer) || other.loadingLayer == loadingLayer)&&(identical(other.locating, locating) || other.locating == locating)&&(identical(other.styleReady, styleReady) || other.styleReady == styleReady)&&(identical(other.placeCount, placeCount) || other.placeCount == placeCount)&&(identical(other.layerName, layerName) || other.layerName == layerName)&&(identical(other.layerError, layerError) || other.layerError == layerError)&&(identical(other.mapError, mapError) || other.mapError == mapError)&&(identical(other.locationMessage, locationMessage) || other.locationMessage == locationMessage)&&(identical(other.locationAction, locationAction) || other.locationAction == locationAction)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,loadingLayer,locating,styleReady,placeCount,layerName,layerError,mapError,locationMessage,locationAction,selected);
}

@override
String toString() {
    return 'MapState(loadingLayer: $loadingLayer, locating: $locating, styleReady: $styleReady, placeCount: $placeCount, layerName: $layerName, layerError: $layerError, mapError: $mapError, locationMessage: $locationMessage, locationAction: $locationAction, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$MapStateCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory _$MapStateCopyWith(_MapState value, $Res Function(_MapState) _then) = __$MapStateCopyWithImpl;
@override @useResult
$Res call({
 bool loadingLayer, bool locating, bool styleReady, int placeCount, String layerName, String? layerError, String? mapError, String? locationMessage, LocationAction locationAction, PlaceDetails? selected
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
@override @pragma('vm:prefer-inline') $Res call({Object? loadingLayer = null,Object? locating = null,Object? styleReady = null,Object? placeCount = null,Object? layerName = null,Object? layerError = freezed,Object? mapError = freezed,Object? locationMessage = freezed,Object? locationAction = null,Object? selected = freezed,}) {
  return _then(_MapState(
loadingLayer: null == loadingLayer ? _self.loadingLayer : loadingLayer // ignore: cast_nullable_to_non_nullable
as bool,locating: null == locating ? _self.locating : locating // ignore: cast_nullable_to_non_nullable
as bool,styleReady: null == styleReady ? _self.styleReady : styleReady // ignore: cast_nullable_to_non_nullable
as bool,placeCount: null == placeCount ? _self.placeCount : placeCount // ignore: cast_nullable_to_non_nullable
as int,layerName: null == layerName ? _self.layerName : layerName // ignore: cast_nullable_to_non_nullable
as String,layerError: freezed == layerError ? _self.layerError : layerError // ignore: cast_nullable_to_non_nullable
as String?,mapError: freezed == mapError ? _self.mapError : mapError // ignore: cast_nullable_to_non_nullable
as String?,locationMessage: freezed == locationMessage ? _self.locationMessage : locationMessage // ignore: cast_nullable_to_non_nullable
as String?,locationAction: null == locationAction ? _self.locationAction : locationAction // ignore: cast_nullable_to_non_nullable
as LocationAction,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as PlaceDetails?,
  ));
}


}

// dart format on
