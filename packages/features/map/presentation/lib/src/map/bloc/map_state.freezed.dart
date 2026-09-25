// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapState {
  MapScene get scene;
  MapRenderStatus get renderStatus;
  PlaceDetails? get selected;
  bool get loadingLayer;
  LocationTrackingStatus get locationStatus;
  Failure? get layerFailure;
  Failure? get locationFailure;
  String? get settingsMessage;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapStateCopyWith<MapState> get copyWith =>
      _$MapStateCopyWithImpl<MapState>(this as MapState, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as MapState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapState &&
            (identical(other.scene, _this.scene) ||
                other.scene == _this.scene) &&
            (identical(other.renderStatus, _this.renderStatus) ||
                other.renderStatus == _this.renderStatus) &&
            (identical(other.selected, _this.selected) ||
                other.selected == _this.selected) &&
            (identical(other.loadingLayer, _this.loadingLayer) ||
                other.loadingLayer == _this.loadingLayer) &&
            (identical(other.locationStatus, _this.locationStatus) ||
                other.locationStatus == _this.locationStatus) &&
            (identical(other.layerFailure, _this.layerFailure) ||
                other.layerFailure == _this.layerFailure) &&
            (identical(other.locationFailure, _this.locationFailure) ||
                other.locationFailure == _this.locationFailure) &&
            (identical(other.settingsMessage, _this.settingsMessage) ||
                other.settingsMessage == _this.settingsMessage));
  }

  @override
  int get hashCode {
    final _this = this as MapState;
    return Object.hash(
      runtimeType,
      _this.scene,
      _this.renderStatus,
      _this.selected,
      _this.loadingLayer,
      _this.locationStatus,
      _this.layerFailure,
      _this.locationFailure,
      _this.settingsMessage,
    );
  }

  @override
  String toString() {
    final _this = this as MapState;
    return 'MapState(scene: ${_this.scene}, renderStatus: ${_this.renderStatus}, selected: ${_this.selected}, loadingLayer: ${_this.loadingLayer}, locationStatus: ${_this.locationStatus}, layerFailure: ${_this.layerFailure}, locationFailure: ${_this.locationFailure}, settingsMessage: ${_this.settingsMessage})';
  }
}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res> {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) =
      _$MapStateCopyWithImpl;
  @useResult
  $Res call({
    MapScene scene,
    MapRenderStatus renderStatus,
    PlaceDetails? selected,
    bool loadingLayer,
    LocationTrackingStatus locationStatus,
    Failure? layerFailure,
    Failure? locationFailure,
    String? settingsMessage,
  });

  $MapSceneCopyWith<$Res> get scene;
}

/// @nodoc
class _$MapStateCopyWithImpl<$Res> implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._self, this._then);

  final MapState _self;
  final $Res Function(MapState) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scene = null,
    Object? renderStatus = null,
    Object? selected = freezed,
    Object? loadingLayer = null,
    Object? locationStatus = null,
    Object? layerFailure = freezed,
    Object? locationFailure = freezed,
    Object? settingsMessage = freezed,
  }) {
    return _then(
      MapState(
        scene: null == scene
            ? _self.scene
            : scene // ignore: cast_nullable_to_non_nullable
                  as MapScene,
        renderStatus: null == renderStatus
            ? _self.renderStatus
            : renderStatus // ignore: cast_nullable_to_non_nullable
                  as MapRenderStatus,
        selected: freezed == selected
            ? _self.selected
            : selected // ignore: cast_nullable_to_non_nullable
                  as PlaceDetails?,
        loadingLayer: null == loadingLayer
            ? _self.loadingLayer
            : loadingLayer // ignore: cast_nullable_to_non_nullable
                  as bool,
        locationStatus: null == locationStatus
            ? _self.locationStatus
            : locationStatus // ignore: cast_nullable_to_non_nullable
                  as LocationTrackingStatus,
        layerFailure: freezed == layerFailure
            ? _self.layerFailure
            : layerFailure // ignore: cast_nullable_to_non_nullable
                  as Failure?,
        locationFailure: freezed == locationFailure
            ? _self.locationFailure
            : locationFailure // ignore: cast_nullable_to_non_nullable
                  as Failure?,
        settingsMessage: freezed == settingsMessage
            ? _self.settingsMessage
            : settingsMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MapSceneCopyWith<$Res> get scene {
    return $MapSceneCopyWith<$Res>(_self.scene, (value) {
      return _then(_self.copyWith(scene: value));
    });
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MapState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapState() when $default != null:
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
    TResult Function(_MapState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapState():
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
    TResult? Function(_MapState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapState() when $default != null:
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
      MapScene scene,
      MapRenderStatus renderStatus,
      PlaceDetails? selected,
      bool loadingLayer,
      LocationTrackingStatus locationStatus,
      Failure? layerFailure,
      Failure? locationFailure,
      String? settingsMessage,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapState() when $default != null:
        return $default(
          _that.scene,
          _that.renderStatus,
          _that.selected,
          _that.loadingLayer,
          _that.locationStatus,
          _that.layerFailure,
          _that.locationFailure,
          _that.settingsMessage,
        );
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
      MapScene scene,
      MapRenderStatus renderStatus,
      PlaceDetails? selected,
      bool loadingLayer,
      LocationTrackingStatus locationStatus,
      Failure? layerFailure,
      Failure? locationFailure,
      String? settingsMessage,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapState():
        return $default(
          _that.scene,
          _that.renderStatus,
          _that.selected,
          _that.loadingLayer,
          _that.locationStatus,
          _that.layerFailure,
          _that.locationFailure,
          _that.settingsMessage,
        );
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
      MapScene scene,
      MapRenderStatus renderStatus,
      PlaceDetails? selected,
      bool loadingLayer,
      LocationTrackingStatus locationStatus,
      Failure? layerFailure,
      Failure? locationFailure,
      String? settingsMessage,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapState() when $default != null:
        return $default(
          _that.scene,
          _that.renderStatus,
          _that.selected,
          _that.loadingLayer,
          _that.locationStatus,
          _that.layerFailure,
          _that.locationFailure,
          _that.settingsMessage,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MapState extends MapState {
  const _MapState({
    this.scene = const MapScene(),
    this.renderStatus = MapRenderStatus.waitingForMap,
    this.selected,
    this.loadingLayer = true,
    this.locationStatus = LocationTrackingStatus.idle,
    this.layerFailure,
    this.locationFailure,
    this.settingsMessage,
  }) : super._();

  @override
  @JsonKey()
  final MapScene scene;
  @override
  @JsonKey()
  final MapRenderStatus renderStatus;
  @override
  final PlaceDetails? selected;
  @override
  @JsonKey()
  final bool loadingLayer;
  @override
  @JsonKey()
  final LocationTrackingStatus locationStatus;
  @override
  final Failure? layerFailure;
  @override
  final Failure? locationFailure;
  @override
  final String? settingsMessage;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MapStateCopyWith<_MapState> get copyWith =>
      __$MapStateCopyWithImpl<_MapState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MapState &&
            (identical(other.scene, scene) || other.scene == scene) &&
            (identical(other.renderStatus, renderStatus) ||
                other.renderStatus == renderStatus) &&
            (identical(other.selected, selected) ||
                other.selected == selected) &&
            (identical(other.loadingLayer, loadingLayer) ||
                other.loadingLayer == loadingLayer) &&
            (identical(other.locationStatus, locationStatus) ||
                other.locationStatus == locationStatus) &&
            (identical(other.layerFailure, layerFailure) ||
                other.layerFailure == layerFailure) &&
            (identical(other.locationFailure, locationFailure) ||
                other.locationFailure == locationFailure) &&
            (identical(other.settingsMessage, settingsMessage) ||
                other.settingsMessage == settingsMessage));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      scene,
      renderStatus,
      selected,
      loadingLayer,
      locationStatus,
      layerFailure,
      locationFailure,
      settingsMessage,
    );
  }

  @override
  String toString() {
    return 'MapState(scene: $scene, renderStatus: $renderStatus, selected: $selected, loadingLayer: $loadingLayer, locationStatus: $locationStatus, layerFailure: $layerFailure, locationFailure: $locationFailure, settingsMessage: $settingsMessage)';
  }
}

/// @nodoc
abstract mixin class _$MapStateCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory _$MapStateCopyWith(_MapState value, $Res Function(_MapState) _then) =
      __$MapStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    MapScene scene,
    MapRenderStatus renderStatus,
    PlaceDetails? selected,
    bool loadingLayer,
    LocationTrackingStatus locationStatus,
    Failure? layerFailure,
    Failure? locationFailure,
    String? settingsMessage,
  });

  @override
  $MapSceneCopyWith<$Res> get scene;
}

/// @nodoc
class __$MapStateCopyWithImpl<$Res> implements _$MapStateCopyWith<$Res> {
  __$MapStateCopyWithImpl(this._self, this._then);

  final _MapState _self;
  final $Res Function(_MapState) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? scene = null,
    Object? renderStatus = null,
    Object? selected = freezed,
    Object? loadingLayer = null,
    Object? locationStatus = null,
    Object? layerFailure = freezed,
    Object? locationFailure = freezed,
    Object? settingsMessage = freezed,
  }) {
    return _then(
      _MapState(
        scene: null == scene
            ? _self.scene
            : scene // ignore: cast_nullable_to_non_nullable
                  as MapScene,
        renderStatus: null == renderStatus
            ? _self.renderStatus
            : renderStatus // ignore: cast_nullable_to_non_nullable
                  as MapRenderStatus,
        selected: freezed == selected
            ? _self.selected
            : selected // ignore: cast_nullable_to_non_nullable
                  as PlaceDetails?,
        loadingLayer: null == loadingLayer
            ? _self.loadingLayer
            : loadingLayer // ignore: cast_nullable_to_non_nullable
                  as bool,
        locationStatus: null == locationStatus
            ? _self.locationStatus
            : locationStatus // ignore: cast_nullable_to_non_nullable
                  as LocationTrackingStatus,
        layerFailure: freezed == layerFailure
            ? _self.layerFailure
            : layerFailure // ignore: cast_nullable_to_non_nullable
                  as Failure?,
        locationFailure: freezed == locationFailure
            ? _self.locationFailure
            : locationFailure // ignore: cast_nullable_to_non_nullable
                  as Failure?,
        settingsMessage: freezed == settingsMessage
            ? _self.settingsMessage
            : settingsMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MapSceneCopyWith<$Res> get scene {
    return $MapSceneCopyWith<$Res>(_self.scene, (value) {
      return _then(_self.copyWith(scene: value));
    });
  }
}
