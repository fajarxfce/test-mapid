// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 String get environment; bool get isDemo; List<LoginProvider> get providers; LoginProvider? get activeProvider; EmailInput get email; PasswordInput get password; FormzSubmissionStatus get status; String? get error;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.environment, _this.environment) || other.environment == _this.environment)&&(identical(other.isDemo, _this.isDemo) || other.isDemo == _this.isDemo)&&const DeepCollectionEquality().equals(other.providers, _this.providers)&&(identical(other.activeProvider, _this.activeProvider) || other.activeProvider == _this.activeProvider)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as LoginState;
  return Object.hash(runtimeType,_this.environment,_this.isDemo,const DeepCollectionEquality().hash(_this.providers),_this.activeProvider,_this.email,_this.password,_this.status,_this.error);
}

@override
String toString() {
  final _this = this as LoginState;
  return 'LoginState(environment: ${_this.environment}, isDemo: ${_this.isDemo}, providers: ${_this.providers}, activeProvider: ${_this.activeProvider}, email: ${_this.email}, password: ${_this.password}, status: ${_this.status}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 String environment, bool isDemo, List<LoginProvider> providers, LoginProvider? activeProvider, EmailInput email, PasswordInput password, FormzSubmissionStatus status, String? error
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? environment = null,Object? isDemo = null,Object? providers = null,Object? activeProvider = freezed,Object? email = null,Object? password = null,Object? status = null,Object? error = freezed,}) {
  return _then(LoginState(
environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<LoginProvider>,activeProvider: freezed == activeProvider ? _self.activeProvider : activeProvider // ignore: cast_nullable_to_non_nullable
as LoginProvider?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as EmailInput,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as PasswordInput,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormzSubmissionStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String environment,  bool isDemo,  List<LoginProvider> providers,  LoginProvider? activeProvider,  EmailInput email,  PasswordInput password,  FormzSubmissionStatus status,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.environment,_that.isDemo,_that.providers,_that.activeProvider,_that.email,_that.password,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String environment,  bool isDemo,  List<LoginProvider> providers,  LoginProvider? activeProvider,  EmailInput email,  PasswordInput password,  FormzSubmissionStatus status,  String? error)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.environment,_that.isDemo,_that.providers,_that.activeProvider,_that.email,_that.password,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String environment,  bool isDemo,  List<LoginProvider> providers,  LoginProvider? activeProvider,  EmailInput email,  PasswordInput password,  FormzSubmissionStatus status,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.environment,_that.isDemo,_that.providers,_that.activeProvider,_that.email,_that.password,_that.status,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState extends LoginState {
  const _LoginState({this.environment = '', this.isDemo = false,  List<LoginProvider> providers = const [], this.activeProvider, this.email = const EmailInput.pure(), this.password = const PasswordInput.pure(), this.status = FormzSubmissionStatus.initial, this.error}): _providers = providers,super._();
  

@override@JsonKey() final  String environment;
@override@JsonKey() final  bool isDemo;
 final  List<LoginProvider> _providers;
@override@JsonKey() List<LoginProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

@override final  LoginProvider? activeProvider;
@override@JsonKey() final  EmailInput email;
@override@JsonKey() final  PasswordInput password;
@override@JsonKey() final  FormzSubmissionStatus status;
@override final  String? error;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&const DeepCollectionEquality().equals(other.providers, _providers)&&(identical(other.activeProvider, activeProvider) || other.activeProvider == activeProvider)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,environment,isDemo,const DeepCollectionEquality().hash(_providers),activeProvider,email,password,status,error);
}

@override
String toString() {
    return 'LoginState(environment: $environment, isDemo: $isDemo, providers: $providers, activeProvider: $activeProvider, email: $email, password: $password, status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 String environment, bool isDemo, List<LoginProvider> providers, LoginProvider? activeProvider, EmailInput email, PasswordInput password, FormzSubmissionStatus status, String? error
});




}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? environment = null,Object? isDemo = null,Object? providers = null,Object? activeProvider = freezed,Object? email = null,Object? password = null,Object? status = null,Object? error = freezed,}) {
  return _then(_LoginState(
environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<LoginProvider>,activeProvider: freezed == activeProvider ? _self.activeProvider : activeProvider // ignore: cast_nullable_to_non_nullable
as LoginProvider?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as EmailInput,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as PasswordInput,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormzSubmissionStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
