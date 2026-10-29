// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderTrackerState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderTrackerState()';
}


}

/// @nodoc
class $OrderTrackerStateCopyWith<$Res>  {
$OrderTrackerStateCopyWith(OrderTrackerState _, $Res Function(OrderTrackerState) __);
}


/// Adds pattern-matching-related methods to [OrderTrackerState].
extension OrderTrackerStatePatterns on OrderTrackerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OrderTrackerLoading value)?  loading,TResult Function( OrderTrackerReady value)?  ready,TResult Function( OrderTrackerFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OrderTrackerLoading() when loading != null:
return loading(_that);case OrderTrackerReady() when ready != null:
return ready(_that);case OrderTrackerFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OrderTrackerLoading value)  loading,required TResult Function( OrderTrackerReady value)  ready,required TResult Function( OrderTrackerFailed value)  failed,}){
final _that = this;
switch (_that) {
case OrderTrackerLoading():
return loading(_that);case OrderTrackerReady():
return ready(_that);case OrderTrackerFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OrderTrackerLoading value)?  loading,TResult? Function( OrderTrackerReady value)?  ready,TResult? Function( OrderTrackerFailed value)?  failed,}){
final _that = this;
switch (_that) {
case OrderTrackerLoading() when loading != null:
return loading(_that);case OrderTrackerReady() when ready != null:
return ready(_that);case OrderTrackerFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Order order,  bool reconnecting)?  ready,TResult Function( ApiError error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OrderTrackerLoading() when loading != null:
return loading();case OrderTrackerReady() when ready != null:
return ready(_that.order,_that.reconnecting);case OrderTrackerFailed() when failed != null:
return failed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Order order,  bool reconnecting)  ready,required TResult Function( ApiError error)  failed,}) {final _that = this;
switch (_that) {
case OrderTrackerLoading():
return loading();case OrderTrackerReady():
return ready(_that.order,_that.reconnecting);case OrderTrackerFailed():
return failed(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Order order,  bool reconnecting)?  ready,TResult? Function( ApiError error)?  failed,}) {final _that = this;
switch (_that) {
case OrderTrackerLoading() when loading != null:
return loading();case OrderTrackerReady() when ready != null:
return ready(_that.order,_that.reconnecting);case OrderTrackerFailed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class OrderTrackerLoading implements OrderTrackerState {
  const OrderTrackerLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackerLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderTrackerState.loading()';
}


}




/// @nodoc


class OrderTrackerReady implements OrderTrackerState {
  const OrderTrackerReady({required this.order, this.reconnecting = false});
  

 final  Order order;
@JsonKey() final  bool reconnecting;

/// Create a copy of OrderTrackerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackerReadyCopyWith<OrderTrackerReady> get copyWith => _$OrderTrackerReadyCopyWithImpl<OrderTrackerReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackerReady&&(identical(other.order, order) || other.order == order)&&(identical(other.reconnecting, reconnecting) || other.reconnecting == reconnecting));
}


@override
int get hashCode {
    return Object.hash(runtimeType,order,reconnecting);
}

@override
String toString() {
    return 'OrderTrackerState.ready(order: $order, reconnecting: $reconnecting)';
}


}

/// @nodoc
abstract mixin class $OrderTrackerReadyCopyWith<$Res> implements $OrderTrackerStateCopyWith<$Res> {
  factory $OrderTrackerReadyCopyWith(OrderTrackerReady value, $Res Function(OrderTrackerReady) _then) = _$OrderTrackerReadyCopyWithImpl;
@useResult
$Res call({
 Order order, bool reconnecting
});


$OrderCopyWith<$Res> get order;

}
/// @nodoc
class _$OrderTrackerReadyCopyWithImpl<$Res>
    implements $OrderTrackerReadyCopyWith<$Res> {
  _$OrderTrackerReadyCopyWithImpl(this._self, this._then);

  final OrderTrackerReady _self;
  final $Res Function(OrderTrackerReady) _then;

/// Create a copy of OrderTrackerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? order = null,Object? reconnecting = null,}) {
  return _then(OrderTrackerReady(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order,reconnecting: null == reconnecting ? _self.reconnecting : reconnecting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OrderTrackerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res> get order {
  
  return $OrderCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}

/// @nodoc


class OrderTrackerFailed implements OrderTrackerState {
  const OrderTrackerFailed(this.error);
  

 final  ApiError error;

/// Create a copy of OrderTrackerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackerFailedCopyWith<OrderTrackerFailed> get copyWith => _$OrderTrackerFailedCopyWithImpl<OrderTrackerFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackerFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error);
}

@override
String toString() {
    return 'OrderTrackerState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $OrderTrackerFailedCopyWith<$Res> implements $OrderTrackerStateCopyWith<$Res> {
  factory $OrderTrackerFailedCopyWith(OrderTrackerFailed value, $Res Function(OrderTrackerFailed) _then) = _$OrderTrackerFailedCopyWithImpl;
@useResult
$Res call({
 ApiError error
});




}
/// @nodoc
class _$OrderTrackerFailedCopyWithImpl<$Res>
    implements $OrderTrackerFailedCopyWith<$Res> {
  _$OrderTrackerFailedCopyWithImpl(this._self, this._then);

  final OrderTrackerFailed _self;
  final $Res Function(OrderTrackerFailed) _then;

/// Create a copy of OrderTrackerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(OrderTrackerFailed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiError,
  ));
}


}

// dart format on
