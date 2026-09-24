// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapContent {

 MapLayer? get layer; LocationFix? get location;
/// Create a copy of MapContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapContentCopyWith<MapContent> get copyWith => _$MapContentCopyWithImpl<MapContent>(this as MapContent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapContent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapContent&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.location, _this.location) || other.location == _this.location));
}


@override
int get hashCode {
  final _this = this as MapContent;
  return Object.hash(runtimeType,_this.layer,_this.location);
}

@override
String toString() {
  final _this = this as MapContent;
  return 'MapContent(layer: ${_this.layer}, location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $MapContentCopyWith<$Res>  {
  factory $MapContentCopyWith(MapContent value, $Res Function(MapContent) _then) = _$MapContentCopyWithImpl;
@useResult
$Res call({
 MapLayer? layer, LocationFix? location
});




}
/// @nodoc
class _$MapContentCopyWithImpl<$Res>
    implements $MapContentCopyWith<$Res> {
  _$MapContentCopyWithImpl(this._self, this._then);

  final MapContent _self;
  final $Res Function(MapContent) _then;

/// Create a copy of MapContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layer = freezed,Object? location = freezed,}) {
  return _then(MapContent(
layer: freezed == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as MapLayer?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationFix?,
  ));
}

}


/// Adds pattern-matching-related methods to [MapContent].
extension MapContentPatterns on MapContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapContent value)  $default,){
final _that = this;
switch (_that) {
case _MapContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapContent value)?  $default,){
final _that = this;
switch (_that) {
case _MapContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapLayer? layer,  LocationFix? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapContent() when $default != null:
return $default(_that.layer,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapLayer? layer,  LocationFix? location)  $default,) {final _that = this;
switch (_that) {
case _MapContent():
return $default(_that.layer,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapLayer? layer,  LocationFix? location)?  $default,) {final _that = this;
switch (_that) {
case _MapContent() when $default != null:
return $default(_that.layer,_that.location);case _:
  return null;

}
}

}

/// @nodoc


class _MapContent implements MapContent {
  const _MapContent({this.layer, this.location});
  

@override final  MapLayer? layer;
@override final  LocationFix? location;

/// Create a copy of MapContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapContentCopyWith<_MapContent> get copyWith => __$MapContentCopyWithImpl<_MapContent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapContent&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,layer,location);
}

@override
String toString() {
    return 'MapContent(layer: $layer, location: $location)';
}


}

/// @nodoc
abstract mixin class _$MapContentCopyWith<$Res> implements $MapContentCopyWith<$Res> {
  factory _$MapContentCopyWith(_MapContent value, $Res Function(_MapContent) _then) = __$MapContentCopyWithImpl;
@override @useResult
$Res call({
 MapLayer? layer, LocationFix? location
});




}
/// @nodoc
class __$MapContentCopyWithImpl<$Res>
    implements _$MapContentCopyWith<$Res> {
  __$MapContentCopyWithImpl(this._self, this._then);

  final _MapContent _self;
  final $Res Function(_MapContent) _then;

/// Create a copy of MapContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layer = freezed,Object? location = freezed,}) {
  return _then(_MapContent(
layer: freezed == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as MapLayer?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationFix?,
  ));
}


}

// dart format on
