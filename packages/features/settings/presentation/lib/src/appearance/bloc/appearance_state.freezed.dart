// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appearance_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppearanceState {

 ThemeMode get mode; bool get initialized; bool get saving; String? get error;
/// Create a copy of AppearanceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppearanceStateCopyWith<AppearanceState> get copyWith => _$AppearanceStateCopyWithImpl<AppearanceState>(this as AppearanceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppearanceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppearanceState&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.initialized, _this.initialized) || other.initialized == _this.initialized)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as AppearanceState;
  return Object.hash(runtimeType,_this.mode,_this.initialized,_this.saving,_this.error);
}

@override
String toString() {
  final _this = this as AppearanceState;
  return 'AppearanceState(mode: ${_this.mode}, initialized: ${_this.initialized}, saving: ${_this.saving}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $AppearanceStateCopyWith<$Res>  {
  factory $AppearanceStateCopyWith(AppearanceState value, $Res Function(AppearanceState) _then) = _$AppearanceStateCopyWithImpl;
@useResult
$Res call({
 ThemeMode mode, bool initialized, bool saving, String? error
});




}
/// @nodoc
class _$AppearanceStateCopyWithImpl<$Res>
    implements $AppearanceStateCopyWith<$Res> {
  _$AppearanceStateCopyWithImpl(this._self, this._then);

  final AppearanceState _self;
  final $Res Function(AppearanceState) _then;

/// Create a copy of AppearanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? initialized = null,Object? saving = null,Object? error = freezed,}) {
  return _then(AppearanceState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ThemeMode,initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppearanceState].
extension AppearanceStatePatterns on AppearanceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppearanceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppearanceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppearanceState value)  $default,){
final _that = this;
switch (_that) {
case _AppearanceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppearanceState value)?  $default,){
final _that = this;
switch (_that) {
case _AppearanceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode mode,  bool initialized,  bool saving,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppearanceState() when $default != null:
return $default(_that.mode,_that.initialized,_that.saving,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode mode,  bool initialized,  bool saving,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AppearanceState():
return $default(_that.mode,_that.initialized,_that.saving,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode mode,  bool initialized,  bool saving,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AppearanceState() when $default != null:
return $default(_that.mode,_that.initialized,_that.saving,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AppearanceState implements AppearanceState {
  const _AppearanceState({this.mode = ThemeMode.system, this.initialized = false, this.saving = false, this.error});
  

@override@JsonKey() final  ThemeMode mode;
@override@JsonKey() final  bool initialized;
@override@JsonKey() final  bool saving;
@override final  String? error;

/// Create a copy of AppearanceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppearanceStateCopyWith<_AppearanceState> get copyWith => __$AppearanceStateCopyWithImpl<_AppearanceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppearanceState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.initialized, initialized) || other.initialized == initialized)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,initialized,saving,error);
}

@override
String toString() {
    return 'AppearanceState(mode: $mode, initialized: $initialized, saving: $saving, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AppearanceStateCopyWith<$Res> implements $AppearanceStateCopyWith<$Res> {
  factory _$AppearanceStateCopyWith(_AppearanceState value, $Res Function(_AppearanceState) _then) = __$AppearanceStateCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode mode, bool initialized, bool saving, String? error
});




}
/// @nodoc
class __$AppearanceStateCopyWithImpl<$Res>
    implements _$AppearanceStateCopyWith<$Res> {
  __$AppearanceStateCopyWithImpl(this._self, this._then);

  final _AppearanceState _self;
  final $Res Function(_AppearanceState) _then;

/// Create a copy of AppearanceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? initialized = null,Object? saving = null,Object? error = freezed,}) {
  return _then(_AppearanceState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ThemeMode,initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
