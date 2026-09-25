// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapScene {
  MapLayer? get layer;
  LocationFix? get location;
  MapCameraFocus get focus;

  /// Create a copy of MapScene
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapSceneCopyWith<MapScene> get copyWith =>
      _$MapSceneCopyWithImpl<MapScene>(this as MapScene, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as MapScene;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapScene &&
            (identical(other.layer, _this.layer) ||
                other.layer == _this.layer) &&
            (identical(other.location, _this.location) ||
                other.location == _this.location) &&
            (identical(other.focus, _this.focus) ||
                other.focus == _this.focus));
  }

  @override
  int get hashCode {
    final _this = this as MapScene;
    return Object.hash(runtimeType, _this.layer, _this.location, _this.focus);
  }

  @override
  String toString() {
    final _this = this as MapScene;
    return 'MapScene(layer: ${_this.layer}, location: ${_this.location}, focus: ${_this.focus})';
  }
}

/// @nodoc
abstract mixin class $MapSceneCopyWith<$Res> {
  factory $MapSceneCopyWith(MapScene value, $Res Function(MapScene) _then) =
      _$MapSceneCopyWithImpl;
  @useResult
  $Res call({MapLayer? layer, LocationFix? location, MapCameraFocus focus});
}

/// @nodoc
class _$MapSceneCopyWithImpl<$Res> implements $MapSceneCopyWith<$Res> {
  _$MapSceneCopyWithImpl(this._self, this._then);

  final MapScene _self;
  final $Res Function(MapScene) _then;

  /// Create a copy of MapScene
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? layer = freezed,
    Object? location = freezed,
    Object? focus = null,
  }) {
    return _then(
      MapScene(
        layer: freezed == layer
            ? _self.layer
            : layer // ignore: cast_nullable_to_non_nullable
                  as MapLayer?,
        location: freezed == location
            ? _self.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LocationFix?,
        focus: null == focus
            ? _self.focus
            : focus // ignore: cast_nullable_to_non_nullable
                  as MapCameraFocus,
      ),
    );
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MapScene value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapScene() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MapScene value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapScene():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MapScene value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapScene() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      MapLayer? layer,
      LocationFix? location,
      MapCameraFocus focus,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapScene() when $default != null:
        return $default(_that.layer, _that.location, _that.focus);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      MapLayer? layer,
      LocationFix? location,
      MapCameraFocus focus,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapScene():
        return $default(_that.layer, _that.location, _that.focus);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      MapLayer? layer,
      LocationFix? location,
      MapCameraFocus focus,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapScene() when $default != null:
        return $default(_that.layer, _that.location, _that.focus);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MapScene implements MapScene {
  const _MapScene({
    this.layer,
    this.location,
    this.focus = MapCameraFocus.places,
  });

  @override
  final MapLayer? layer;
  @override
  final LocationFix? location;
  @override
  @JsonKey()
  final MapCameraFocus focus;

  /// Create a copy of MapScene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MapSceneCopyWith<_MapScene> get copyWith =>
      __$MapSceneCopyWithImpl<_MapScene>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MapScene &&
            (identical(other.layer, layer) || other.layer == layer) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.focus, focus) || other.focus == focus));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, layer, location, focus);
  }

  @override
  String toString() {
    return 'MapScene(layer: $layer, location: $location, focus: $focus)';
  }
}

/// @nodoc
abstract mixin class _$MapSceneCopyWith<$Res>
    implements $MapSceneCopyWith<$Res> {
  factory _$MapSceneCopyWith(_MapScene value, $Res Function(_MapScene) _then) =
      __$MapSceneCopyWithImpl;
  @override
  @useResult
  $Res call({MapLayer? layer, LocationFix? location, MapCameraFocus focus});
}

/// @nodoc
class __$MapSceneCopyWithImpl<$Res> implements _$MapSceneCopyWith<$Res> {
  __$MapSceneCopyWithImpl(this._self, this._then);

  final _MapScene _self;
  final $Res Function(_MapScene) _then;

  /// Create a copy of MapScene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? layer = freezed,
    Object? location = freezed,
    Object? focus = null,
  }) {
    return _then(
      _MapScene(
        layer: freezed == layer
            ? _self.layer
            : layer // ignore: cast_nullable_to_non_nullable
                  as MapLayer?,
        location: freezed == location
            ? _self.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LocationFix?,
        focus: null == focus
            ? _self.focus
            : focus // ignore: cast_nullable_to_non_nullable
                  as MapCameraFocus,
      ),
    );
  }
}
