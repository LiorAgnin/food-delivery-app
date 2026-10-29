// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckoutState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState()';
}


}

/// @nodoc
class $CheckoutStateCopyWith<$Res>  {
$CheckoutStateCopyWith(CheckoutState _, $Res Function(CheckoutState) __);
}


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CheckoutIdle value)?  idle,TResult Function( CheckoutSubmitting value)?  submitting,TResult Function( CheckoutFailed value)?  failed,TResult Function( CheckoutPlaced value)?  placed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle(_that);case CheckoutSubmitting() when submitting != null:
return submitting(_that);case CheckoutFailed() when failed != null:
return failed(_that);case CheckoutPlaced() when placed != null:
return placed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CheckoutIdle value)  idle,required TResult Function( CheckoutSubmitting value)  submitting,required TResult Function( CheckoutFailed value)  failed,required TResult Function( CheckoutPlaced value)  placed,}){
final _that = this;
switch (_that) {
case CheckoutIdle():
return idle(_that);case CheckoutSubmitting():
return submitting(_that);case CheckoutFailed():
return failed(_that);case CheckoutPlaced():
return placed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CheckoutIdle value)?  idle,TResult? Function( CheckoutSubmitting value)?  submitting,TResult? Function( CheckoutFailed value)?  failed,TResult? Function( CheckoutPlaced value)?  placed,}){
final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle(_that);case CheckoutSubmitting() when submitting != null:
return submitting(_that);case CheckoutFailed() when failed != null:
return failed(_that);case CheckoutPlaced() when placed != null:
return placed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function( ApiError error,  String message,  List<String> unavailableMenuItemIds)?  failed,TResult Function( String orderId)?  placed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle();case CheckoutSubmitting() when submitting != null:
return submitting();case CheckoutFailed() when failed != null:
return failed(_that.error,_that.message,_that.unavailableMenuItemIds);case CheckoutPlaced() when placed != null:
return placed(_that.orderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function( ApiError error,  String message,  List<String> unavailableMenuItemIds)  failed,required TResult Function( String orderId)  placed,}) {final _that = this;
switch (_that) {
case CheckoutIdle():
return idle();case CheckoutSubmitting():
return submitting();case CheckoutFailed():
return failed(_that.error,_that.message,_that.unavailableMenuItemIds);case CheckoutPlaced():
return placed(_that.orderId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function( ApiError error,  String message,  List<String> unavailableMenuItemIds)?  failed,TResult? Function( String orderId)?  placed,}) {final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle();case CheckoutSubmitting() when submitting != null:
return submitting();case CheckoutFailed() when failed != null:
return failed(_that.error,_that.message,_that.unavailableMenuItemIds);case CheckoutPlaced() when placed != null:
return placed(_that.orderId);case _:
  return null;

}
}

}

/// @nodoc


class CheckoutIdle implements CheckoutState {
  const CheckoutIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState.idle()';
}


}




/// @nodoc


class CheckoutSubmitting implements CheckoutState {
  const CheckoutSubmitting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState.submitting()';
}


}




/// @nodoc


class CheckoutFailed implements CheckoutState {
  const CheckoutFailed({required this.error, required this.message,  List<String> unavailableMenuItemIds = const <String>[]}): _unavailableMenuItemIds = unavailableMenuItemIds;
  

 final  ApiError error;
 final  String message;
 final  List<String> _unavailableMenuItemIds;
@JsonKey() List<String> get unavailableMenuItemIds {
  if (_unavailableMenuItemIds is EqualUnmodifiableListView) return _unavailableMenuItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unavailableMenuItemIds);
}


/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutFailedCopyWith<CheckoutFailed> get copyWith => _$CheckoutFailedCopyWithImpl<CheckoutFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutFailed&&(identical(other.error, error) || other.error == error)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.unavailableMenuItemIds, _unavailableMenuItemIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error,message,const DeepCollectionEquality().hash(_unavailableMenuItemIds));
}

@override
String toString() {
    return 'CheckoutState.failed(error: $error, message: $message, unavailableMenuItemIds: $unavailableMenuItemIds)';
}


}

/// @nodoc
abstract mixin class $CheckoutFailedCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutFailedCopyWith(CheckoutFailed value, $Res Function(CheckoutFailed) _then) = _$CheckoutFailedCopyWithImpl;
@useResult
$Res call({
 ApiError error, String message, List<String> unavailableMenuItemIds
});




}
/// @nodoc
class _$CheckoutFailedCopyWithImpl<$Res>
    implements $CheckoutFailedCopyWith<$Res> {
  _$CheckoutFailedCopyWithImpl(this._self, this._then);

  final CheckoutFailed _self;
  final $Res Function(CheckoutFailed) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? message = null,Object? unavailableMenuItemIds = null,}) {
  return _then(CheckoutFailed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiError,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,unavailableMenuItemIds: null == unavailableMenuItemIds ? _self._unavailableMenuItemIds : unavailableMenuItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class CheckoutPlaced implements CheckoutState {
  const CheckoutPlaced({required this.orderId});
  

 final  String orderId;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutPlacedCopyWith<CheckoutPlaced> get copyWith => _$CheckoutPlacedCopyWithImpl<CheckoutPlaced>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutPlaced&&(identical(other.orderId, orderId) || other.orderId == orderId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderId);
}

@override
String toString() {
    return 'CheckoutState.placed(orderId: $orderId)';
}


}

/// @nodoc
abstract mixin class $CheckoutPlacedCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutPlacedCopyWith(CheckoutPlaced value, $Res Function(CheckoutPlaced) _then) = _$CheckoutPlacedCopyWithImpl;
@useResult
$Res call({
 String orderId
});




}
/// @nodoc
class _$CheckoutPlacedCopyWithImpl<$Res>
    implements $CheckoutPlacedCopyWith<$Res> {
  _$CheckoutPlacedCopyWithImpl(this._self, this._then);

  final CheckoutPlaced _self;
  final $Res Function(CheckoutPlaced) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderId = null,}) {
  return _then(CheckoutPlaced(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
