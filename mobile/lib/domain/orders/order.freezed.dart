// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderLine {

 String? get menuItemId; String get name; int get unitPriceAgorot; int get quantity; int get lineTotalAgorot;
/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderLineCopyWith<OrderLine> get copyWith => _$OrderLineCopyWithImpl<OrderLine>(this as OrderLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderLine&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.unitPriceAgorot, _this.unitPriceAgorot) || other.unitPriceAgorot == _this.unitPriceAgorot)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.lineTotalAgorot, _this.lineTotalAgorot) || other.lineTotalAgorot == _this.lineTotalAgorot));
}


@override
int get hashCode {
  final _this = this as OrderLine;
  return Object.hash(runtimeType,_this.menuItemId,_this.name,_this.unitPriceAgorot,_this.quantity,_this.lineTotalAgorot);
}

@override
String toString() {
  final _this = this as OrderLine;
  return 'OrderLine(menuItemId: ${_this.menuItemId}, name: ${_this.name}, unitPriceAgorot: ${_this.unitPriceAgorot}, quantity: ${_this.quantity}, lineTotalAgorot: ${_this.lineTotalAgorot})';
}


}

/// @nodoc
abstract mixin class $OrderLineCopyWith<$Res>  {
  factory $OrderLineCopyWith(OrderLine value, $Res Function(OrderLine) _then) = _$OrderLineCopyWithImpl;
@useResult
$Res call({
 String? menuItemId, String name, int unitPriceAgorot, int quantity, int lineTotalAgorot
});




}
/// @nodoc
class _$OrderLineCopyWithImpl<$Res>
    implements $OrderLineCopyWith<$Res> {
  _$OrderLineCopyWithImpl(this._self, this._then);

  final OrderLine _self;
  final $Res Function(OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuItemId = freezed,Object? name = null,Object? unitPriceAgorot = null,Object? quantity = null,Object? lineTotalAgorot = null,}) {
  return _then(OrderLine(
menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitPriceAgorot: null == unitPriceAgorot ? _self.unitPriceAgorot : unitPriceAgorot // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lineTotalAgorot: null == lineTotalAgorot ? _self.lineTotalAgorot : lineTotalAgorot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderLine].
extension OrderLinePatterns on OrderLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderLine value)  $default,){
final _that = this;
switch (_that) {
case _OrderLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderLine value)?  $default,){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? menuItemId,  String name,  int unitPriceAgorot,  int quantity,  int lineTotalAgorot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.menuItemId,_that.name,_that.unitPriceAgorot,_that.quantity,_that.lineTotalAgorot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? menuItemId,  String name,  int unitPriceAgorot,  int quantity,  int lineTotalAgorot)  $default,) {final _that = this;
switch (_that) {
case _OrderLine():
return $default(_that.menuItemId,_that.name,_that.unitPriceAgorot,_that.quantity,_that.lineTotalAgorot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? menuItemId,  String name,  int unitPriceAgorot,  int quantity,  int lineTotalAgorot)?  $default,) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.menuItemId,_that.name,_that.unitPriceAgorot,_that.quantity,_that.lineTotalAgorot);case _:
  return null;

}
}

}

/// @nodoc


class _OrderLine implements OrderLine {
  const _OrderLine({required this.menuItemId, required this.name, required this.unitPriceAgorot, required this.quantity, required this.lineTotalAgorot});
  

@override final  String? menuItemId;
@override final  String name;
@override final  int unitPriceAgorot;
@override final  int quantity;
@override final  int lineTotalAgorot;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderLineCopyWith<_OrderLine> get copyWith => __$OrderLineCopyWithImpl<_OrderLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderLine&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitPriceAgorot, unitPriceAgorot) || other.unitPriceAgorot == unitPriceAgorot)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.lineTotalAgorot, lineTotalAgorot) || other.lineTotalAgorot == lineTotalAgorot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,menuItemId,name,unitPriceAgorot,quantity,lineTotalAgorot);
}

@override
String toString() {
    return 'OrderLine(menuItemId: $menuItemId, name: $name, unitPriceAgorot: $unitPriceAgorot, quantity: $quantity, lineTotalAgorot: $lineTotalAgorot)';
}


}

/// @nodoc
abstract mixin class _$OrderLineCopyWith<$Res> implements $OrderLineCopyWith<$Res> {
  factory _$OrderLineCopyWith(_OrderLine value, $Res Function(_OrderLine) _then) = __$OrderLineCopyWithImpl;
@override @useResult
$Res call({
 String? menuItemId, String name, int unitPriceAgorot, int quantity, int lineTotalAgorot
});




}
/// @nodoc
class __$OrderLineCopyWithImpl<$Res>
    implements _$OrderLineCopyWith<$Res> {
  __$OrderLineCopyWithImpl(this._self, this._then);

  final _OrderLine _self;
  final $Res Function(_OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuItemId = freezed,Object? name = null,Object? unitPriceAgorot = null,Object? quantity = null,Object? lineTotalAgorot = null,}) {
  return _then(_OrderLine(
menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitPriceAgorot: null == unitPriceAgorot ? _self.unitPriceAgorot : unitPriceAgorot // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lineTotalAgorot: null == lineTotalAgorot ? _self.lineTotalAgorot : lineTotalAgorot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StatusEvent {

 OrderStatus? get from; OrderStatus get to; Actor get actor; DateTime get at;
/// Create a copy of StatusEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusEventCopyWith<StatusEvent> get copyWith => _$StatusEventCopyWithImpl<StatusEvent>(this as StatusEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StatusEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusEvent&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.actor, _this.actor) || other.actor == _this.actor)&&(identical(other.at, _this.at) || other.at == _this.at));
}


@override
int get hashCode {
  final _this = this as StatusEvent;
  return Object.hash(runtimeType,_this.from,_this.to,_this.actor,_this.at);
}

@override
String toString() {
  final _this = this as StatusEvent;
  return 'StatusEvent(from: ${_this.from}, to: ${_this.to}, actor: ${_this.actor}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $StatusEventCopyWith<$Res>  {
  factory $StatusEventCopyWith(StatusEvent value, $Res Function(StatusEvent) _then) = _$StatusEventCopyWithImpl;
@useResult
$Res call({
 OrderStatus? from, OrderStatus to, Actor actor, DateTime at
});




}
/// @nodoc
class _$StatusEventCopyWithImpl<$Res>
    implements $StatusEventCopyWith<$Res> {
  _$StatusEventCopyWithImpl(this._self, this._then);

  final StatusEvent _self;
  final $Res Function(StatusEvent) _then;

/// Create a copy of StatusEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = freezed,Object? to = null,Object? actor = null,Object? at = null,}) {
  return _then(StatusEvent(
from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as OrderStatus?,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as OrderStatus,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Actor,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusEvent].
extension StatusEventPatterns on StatusEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusEvent value)  $default,){
final _that = this;
switch (_that) {
case _StatusEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusEvent value)?  $default,){
final _that = this;
switch (_that) {
case _StatusEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderStatus? from,  OrderStatus to,  Actor actor,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusEvent() when $default != null:
return $default(_that.from,_that.to,_that.actor,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderStatus? from,  OrderStatus to,  Actor actor,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _StatusEvent():
return $default(_that.from,_that.to,_that.actor,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderStatus? from,  OrderStatus to,  Actor actor,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _StatusEvent() when $default != null:
return $default(_that.from,_that.to,_that.actor,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _StatusEvent implements StatusEvent {
  const _StatusEvent({required this.from, required this.to, required this.actor, required this.at});
  

@override final  OrderStatus? from;
@override final  OrderStatus to;
@override final  Actor actor;
@override final  DateTime at;

/// Create a copy of StatusEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusEventCopyWith<_StatusEvent> get copyWith => __$StatusEventCopyWithImpl<_StatusEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusEvent&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode {
    return Object.hash(runtimeType,from,to,actor,at);
}

@override
String toString() {
    return 'StatusEvent(from: $from, to: $to, actor: $actor, at: $at)';
}


}

/// @nodoc
abstract mixin class _$StatusEventCopyWith<$Res> implements $StatusEventCopyWith<$Res> {
  factory _$StatusEventCopyWith(_StatusEvent value, $Res Function(_StatusEvent) _then) = __$StatusEventCopyWithImpl;
@override @useResult
$Res call({
 OrderStatus? from, OrderStatus to, Actor actor, DateTime at
});




}
/// @nodoc
class __$StatusEventCopyWithImpl<$Res>
    implements _$StatusEventCopyWith<$Res> {
  __$StatusEventCopyWithImpl(this._self, this._then);

  final _StatusEvent _self;
  final $Res Function(_StatusEvent) _then;

/// Create a copy of StatusEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = freezed,Object? to = null,Object? actor = null,Object? at = null,}) {
  return _then(_StatusEvent(
from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as OrderStatus?,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as OrderStatus,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Actor,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$Order {

 String get id; OrderStatus get status; String get restaurantId; String get restaurantName; List<OrderLine> get items; int get subtotalAgorot; int get deliveryFeeAgorot; int get totalAgorot; List<StatusEvent> get statusHistory; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.restaurantId, _this.restaurantId) || other.restaurantId == _this.restaurantId)&&(identical(other.restaurantName, _this.restaurantName) || other.restaurantName == _this.restaurantName)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.subtotalAgorot, _this.subtotalAgorot) || other.subtotalAgorot == _this.subtotalAgorot)&&(identical(other.deliveryFeeAgorot, _this.deliveryFeeAgorot) || other.deliveryFeeAgorot == _this.deliveryFeeAgorot)&&(identical(other.totalAgorot, _this.totalAgorot) || other.totalAgorot == _this.totalAgorot)&&const DeepCollectionEquality().equals(other.statusHistory, _this.statusHistory)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as Order;
  return Object.hash(runtimeType,_this.id,_this.status,_this.restaurantId,_this.restaurantName,const DeepCollectionEquality().hash(_this.items),_this.subtotalAgorot,_this.deliveryFeeAgorot,_this.totalAgorot,const DeepCollectionEquality().hash(_this.statusHistory),_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, status: ${_this.status}, restaurantId: ${_this.restaurantId}, restaurantName: ${_this.restaurantName}, items: ${_this.items}, subtotalAgorot: ${_this.subtotalAgorot}, deliveryFeeAgorot: ${_this.deliveryFeeAgorot}, totalAgorot: ${_this.totalAgorot}, statusHistory: ${_this.statusHistory}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, OrderStatus status, String restaurantId, String restaurantName, List<OrderLine> items, int subtotalAgorot, int deliveryFeeAgorot, int totalAgorot, List<StatusEvent> statusHistory, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? restaurantId = null,Object? restaurantName = null,Object? items = null,Object? subtotalAgorot = null,Object? deliveryFeeAgorot = null,Object? totalAgorot = null,Object? statusHistory = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,restaurantName: null == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,subtotalAgorot: null == subtotalAgorot ? _self.subtotalAgorot : subtotalAgorot // ignore: cast_nullable_to_non_nullable
as int,deliveryFeeAgorot: null == deliveryFeeAgorot ? _self.deliveryFeeAgorot : deliveryFeeAgorot // ignore: cast_nullable_to_non_nullable
as int,totalAgorot: null == totalAgorot ? _self.totalAgorot : totalAgorot // ignore: cast_nullable_to_non_nullable
as int,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusEvent>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  OrderStatus status,  String restaurantId,  String restaurantName,  List<OrderLine> items,  int subtotalAgorot,  int deliveryFeeAgorot,  int totalAgorot,  List<StatusEvent> statusHistory,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.status,_that.restaurantId,_that.restaurantName,_that.items,_that.subtotalAgorot,_that.deliveryFeeAgorot,_that.totalAgorot,_that.statusHistory,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  OrderStatus status,  String restaurantId,  String restaurantName,  List<OrderLine> items,  int subtotalAgorot,  int deliveryFeeAgorot,  int totalAgorot,  List<StatusEvent> statusHistory,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.status,_that.restaurantId,_that.restaurantName,_that.items,_that.subtotalAgorot,_that.deliveryFeeAgorot,_that.totalAgorot,_that.statusHistory,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  OrderStatus status,  String restaurantId,  String restaurantName,  List<OrderLine> items,  int subtotalAgorot,  int deliveryFeeAgorot,  int totalAgorot,  List<StatusEvent> statusHistory,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.status,_that.restaurantId,_that.restaurantName,_that.items,_that.subtotalAgorot,_that.deliveryFeeAgorot,_that.totalAgorot,_that.statusHistory,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Order implements Order {
  const _Order({required this.id, required this.status, required this.restaurantId, required this.restaurantName, required  List<OrderLine> items, required this.subtotalAgorot, required this.deliveryFeeAgorot, required this.totalAgorot, required  List<StatusEvent> statusHistory, required this.createdAt, required this.updatedAt}): _items = items,_statusHistory = statusHistory;
  

@override final  String id;
@override final  OrderStatus status;
@override final  String restaurantId;
@override final  String restaurantName;
 final  List<OrderLine> _items;
@override List<OrderLine> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int subtotalAgorot;
@override final  int deliveryFeeAgorot;
@override final  int totalAgorot;
 final  List<StatusEvent> _statusHistory;
@override List<StatusEvent> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.subtotalAgorot, subtotalAgorot) || other.subtotalAgorot == subtotalAgorot)&&(identical(other.deliveryFeeAgorot, deliveryFeeAgorot) || other.deliveryFeeAgorot == deliveryFeeAgorot)&&(identical(other.totalAgorot, totalAgorot) || other.totalAgorot == totalAgorot)&&const DeepCollectionEquality().equals(other.statusHistory, _statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,status,restaurantId,restaurantName,const DeepCollectionEquality().hash(_items),subtotalAgorot,deliveryFeeAgorot,totalAgorot,const DeepCollectionEquality().hash(_statusHistory),createdAt,updatedAt);
}

@override
String toString() {
    return 'Order(id: $id, status: $status, restaurantId: $restaurantId, restaurantName: $restaurantName, items: $items, subtotalAgorot: $subtotalAgorot, deliveryFeeAgorot: $deliveryFeeAgorot, totalAgorot: $totalAgorot, statusHistory: $statusHistory, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, OrderStatus status, String restaurantId, String restaurantName, List<OrderLine> items, int subtotalAgorot, int deliveryFeeAgorot, int totalAgorot, List<StatusEvent> statusHistory, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? restaurantId = null,Object? restaurantName = null,Object? items = null,Object? subtotalAgorot = null,Object? deliveryFeeAgorot = null,Object? totalAgorot = null,Object? statusHistory = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,restaurantName: null == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,subtotalAgorot: null == subtotalAgorot ? _self.subtotalAgorot : subtotalAgorot // ignore: cast_nullable_to_non_nullable
as int,deliveryFeeAgorot: null == deliveryFeeAgorot ? _self.deliveryFeeAgorot : deliveryFeeAgorot // ignore: cast_nullable_to_non_nullable
as int,totalAgorot: null == totalAgorot ? _self.totalAgorot : totalAgorot // ignore: cast_nullable_to_non_nullable
as int,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusEvent>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
