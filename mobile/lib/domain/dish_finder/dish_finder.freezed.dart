// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dish_finder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessage {

 ChatRole get role; String get content;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.content, _this.content) || other.content == _this.content));
}


@override
int get hashCode {
  final _this = this as ChatMessage;
  return Object.hash(runtimeType,_this.role,_this.content);
}

@override
String toString() {
  final _this = this as ChatMessage;
  return 'ChatMessage(role: ${_this.role}, content: ${_this.content})';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 ChatRole role, String content
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? content = null,}) {
  return _then(ChatMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatRole role,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.role,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatRole role,  String content)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.role,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatRole role,  String content)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.role,_that.content);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.role, required this.content});
  

@override final  ChatRole role;
@override final  String content;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content));
}


@override
int get hashCode {
    return Object.hash(runtimeType,role,content);
}

@override
String toString() {
    return 'ChatMessage(role: $role, content: $content)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 ChatRole role, String content
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? content = null,}) {
  return _then(_ChatMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DishRestaurant {

 String get id; String get name; String get cuisine; bool get isOpen;
/// Create a copy of DishRestaurant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DishRestaurantCopyWith<DishRestaurant> get copyWith => _$DishRestaurantCopyWithImpl<DishRestaurant>(this as DishRestaurant, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DishRestaurant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DishRestaurant&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.cuisine, _this.cuisine) || other.cuisine == _this.cuisine)&&(identical(other.isOpen, _this.isOpen) || other.isOpen == _this.isOpen));
}


@override
int get hashCode {
  final _this = this as DishRestaurant;
  return Object.hash(runtimeType,_this.id,_this.name,_this.cuisine,_this.isOpen);
}

@override
String toString() {
  final _this = this as DishRestaurant;
  return 'DishRestaurant(id: ${_this.id}, name: ${_this.name}, cuisine: ${_this.cuisine}, isOpen: ${_this.isOpen})';
}


}

/// @nodoc
abstract mixin class $DishRestaurantCopyWith<$Res>  {
  factory $DishRestaurantCopyWith(DishRestaurant value, $Res Function(DishRestaurant) _then) = _$DishRestaurantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String cuisine, bool isOpen
});




}
/// @nodoc
class _$DishRestaurantCopyWithImpl<$Res>
    implements $DishRestaurantCopyWith<$Res> {
  _$DishRestaurantCopyWithImpl(this._self, this._then);

  final DishRestaurant _self;
  final $Res Function(DishRestaurant) _then;

/// Create a copy of DishRestaurant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cuisine = null,Object? isOpen = null,}) {
  return _then(DishRestaurant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cuisine: null == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DishRestaurant].
extension DishRestaurantPatterns on DishRestaurant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DishRestaurant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DishRestaurant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DishRestaurant value)  $default,){
final _that = this;
switch (_that) {
case _DishRestaurant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DishRestaurant value)?  $default,){
final _that = this;
switch (_that) {
case _DishRestaurant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String cuisine,  bool isOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DishRestaurant() when $default != null:
return $default(_that.id,_that.name,_that.cuisine,_that.isOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String cuisine,  bool isOpen)  $default,) {final _that = this;
switch (_that) {
case _DishRestaurant():
return $default(_that.id,_that.name,_that.cuisine,_that.isOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String cuisine,  bool isOpen)?  $default,) {final _that = this;
switch (_that) {
case _DishRestaurant() when $default != null:
return $default(_that.id,_that.name,_that.cuisine,_that.isOpen);case _:
  return null;

}
}

}

/// @nodoc


class _DishRestaurant implements DishRestaurant {
  const _DishRestaurant({required this.id, required this.name, required this.cuisine, required this.isOpen});
  

@override final  String id;
@override final  String name;
@override final  String cuisine;
@override final  bool isOpen;

/// Create a copy of DishRestaurant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DishRestaurantCopyWith<_DishRestaurant> get copyWith => __$DishRestaurantCopyWithImpl<_DishRestaurant>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DishRestaurant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,cuisine,isOpen);
}

@override
String toString() {
    return 'DishRestaurant(id: $id, name: $name, cuisine: $cuisine, isOpen: $isOpen)';
}


}

/// @nodoc
abstract mixin class _$DishRestaurantCopyWith<$Res> implements $DishRestaurantCopyWith<$Res> {
  factory _$DishRestaurantCopyWith(_DishRestaurant value, $Res Function(_DishRestaurant) _then) = __$DishRestaurantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String cuisine, bool isOpen
});




}
/// @nodoc
class __$DishRestaurantCopyWithImpl<$Res>
    implements _$DishRestaurantCopyWith<$Res> {
  __$DishRestaurantCopyWithImpl(this._self, this._then);

  final _DishRestaurant _self;
  final $Res Function(_DishRestaurant) _then;

/// Create a copy of DishRestaurant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cuisine = null,Object? isOpen = null,}) {
  return _then(_DishRestaurant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cuisine: null == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$DishResult {

 MenuItem get menuItem; DishRestaurant get restaurant; bool get orderable;
/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DishResultCopyWith<DishResult> get copyWith => _$DishResultCopyWithImpl<DishResult>(this as DishResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DishResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DishResult&&(identical(other.menuItem, _this.menuItem) || other.menuItem == _this.menuItem)&&(identical(other.restaurant, _this.restaurant) || other.restaurant == _this.restaurant)&&(identical(other.orderable, _this.orderable) || other.orderable == _this.orderable));
}


@override
int get hashCode {
  final _this = this as DishResult;
  return Object.hash(runtimeType,_this.menuItem,_this.restaurant,_this.orderable);
}

@override
String toString() {
  final _this = this as DishResult;
  return 'DishResult(menuItem: ${_this.menuItem}, restaurant: ${_this.restaurant}, orderable: ${_this.orderable})';
}


}

/// @nodoc
abstract mixin class $DishResultCopyWith<$Res>  {
  factory $DishResultCopyWith(DishResult value, $Res Function(DishResult) _then) = _$DishResultCopyWithImpl;
@useResult
$Res call({
 MenuItem menuItem, DishRestaurant restaurant, bool orderable
});


$MenuItemCopyWith<$Res> get menuItem;$DishRestaurantCopyWith<$Res> get restaurant;

}
/// @nodoc
class _$DishResultCopyWithImpl<$Res>
    implements $DishResultCopyWith<$Res> {
  _$DishResultCopyWithImpl(this._self, this._then);

  final DishResult _self;
  final $Res Function(DishResult) _then;

/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuItem = null,Object? restaurant = null,Object? orderable = null,}) {
  return _then(DishResult(
menuItem: null == menuItem ? _self.menuItem : menuItem // ignore: cast_nullable_to_non_nullable
as MenuItem,restaurant: null == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as DishRestaurant,orderable: null == orderable ? _self.orderable : orderable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuItemCopyWith<$Res> get menuItem {
  
  return $MenuItemCopyWith<$Res>(_self.menuItem, (value) {
    return _then(_self.copyWith(menuItem: value));
  });
}/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DishRestaurantCopyWith<$Res> get restaurant {
  
  return $DishRestaurantCopyWith<$Res>(_self.restaurant, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}
}


/// Adds pattern-matching-related methods to [DishResult].
extension DishResultPatterns on DishResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DishResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DishResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DishResult value)  $default,){
final _that = this;
switch (_that) {
case _DishResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DishResult value)?  $default,){
final _that = this;
switch (_that) {
case _DishResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MenuItem menuItem,  DishRestaurant restaurant,  bool orderable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DishResult() when $default != null:
return $default(_that.menuItem,_that.restaurant,_that.orderable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MenuItem menuItem,  DishRestaurant restaurant,  bool orderable)  $default,) {final _that = this;
switch (_that) {
case _DishResult():
return $default(_that.menuItem,_that.restaurant,_that.orderable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MenuItem menuItem,  DishRestaurant restaurant,  bool orderable)?  $default,) {final _that = this;
switch (_that) {
case _DishResult() when $default != null:
return $default(_that.menuItem,_that.restaurant,_that.orderable);case _:
  return null;

}
}

}

/// @nodoc


class _DishResult implements DishResult {
  const _DishResult({required this.menuItem, required this.restaurant, required this.orderable});
  

@override final  MenuItem menuItem;
@override final  DishRestaurant restaurant;
@override final  bool orderable;

/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DishResultCopyWith<_DishResult> get copyWith => __$DishResultCopyWithImpl<_DishResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DishResult&&(identical(other.menuItem, menuItem) || other.menuItem == menuItem)&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.orderable, orderable) || other.orderable == orderable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,menuItem,restaurant,orderable);
}

@override
String toString() {
    return 'DishResult(menuItem: $menuItem, restaurant: $restaurant, orderable: $orderable)';
}


}

/// @nodoc
abstract mixin class _$DishResultCopyWith<$Res> implements $DishResultCopyWith<$Res> {
  factory _$DishResultCopyWith(_DishResult value, $Res Function(_DishResult) _then) = __$DishResultCopyWithImpl;
@override @useResult
$Res call({
 MenuItem menuItem, DishRestaurant restaurant, bool orderable
});


@override $MenuItemCopyWith<$Res> get menuItem;@override $DishRestaurantCopyWith<$Res> get restaurant;

}
/// @nodoc
class __$DishResultCopyWithImpl<$Res>
    implements _$DishResultCopyWith<$Res> {
  __$DishResultCopyWithImpl(this._self, this._then);

  final _DishResult _self;
  final $Res Function(_DishResult) _then;

/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuItem = null,Object? restaurant = null,Object? orderable = null,}) {
  return _then(_DishResult(
menuItem: null == menuItem ? _self.menuItem : menuItem // ignore: cast_nullable_to_non_nullable
as MenuItem,restaurant: null == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as DishRestaurant,orderable: null == orderable ? _self.orderable : orderable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuItemCopyWith<$Res> get menuItem {
  
  return $MenuItemCopyWith<$Res>(_self.menuItem, (value) {
    return _then(_self.copyWith(menuItem: value));
  });
}/// Create a copy of DishResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DishRestaurantCopyWith<$Res> get restaurant {
  
  return $DishRestaurantCopyWith<$Res>(_self.restaurant, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}
}

/// @nodoc
mixin _$SearchIntent {

 List<String> get keywords; List<String> get excludeKeywords; List<String> get cuisines; List<DietaryTag> get includeTags; List<DietaryTag> get excludeTags; int? get maxPriceAgorot; bool get openNowOnly; SearchSort get sort;
/// Create a copy of SearchIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchIntentCopyWith<SearchIntent> get copyWith => _$SearchIntentCopyWithImpl<SearchIntent>(this as SearchIntent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchIntent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIntent&&const DeepCollectionEquality().equals(other.keywords, _this.keywords)&&const DeepCollectionEquality().equals(other.excludeKeywords, _this.excludeKeywords)&&const DeepCollectionEquality().equals(other.cuisines, _this.cuisines)&&const DeepCollectionEquality().equals(other.includeTags, _this.includeTags)&&const DeepCollectionEquality().equals(other.excludeTags, _this.excludeTags)&&(identical(other.maxPriceAgorot, _this.maxPriceAgorot) || other.maxPriceAgorot == _this.maxPriceAgorot)&&(identical(other.openNowOnly, _this.openNowOnly) || other.openNowOnly == _this.openNowOnly)&&(identical(other.sort, _this.sort) || other.sort == _this.sort));
}


@override
int get hashCode {
  final _this = this as SearchIntent;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.keywords),const DeepCollectionEquality().hash(_this.excludeKeywords),const DeepCollectionEquality().hash(_this.cuisines),const DeepCollectionEquality().hash(_this.includeTags),const DeepCollectionEquality().hash(_this.excludeTags),_this.maxPriceAgorot,_this.openNowOnly,_this.sort);
}

@override
String toString() {
  final _this = this as SearchIntent;
  return 'SearchIntent(keywords: ${_this.keywords}, excludeKeywords: ${_this.excludeKeywords}, cuisines: ${_this.cuisines}, includeTags: ${_this.includeTags}, excludeTags: ${_this.excludeTags}, maxPriceAgorot: ${_this.maxPriceAgorot}, openNowOnly: ${_this.openNowOnly}, sort: ${_this.sort})';
}


}

/// @nodoc
abstract mixin class $SearchIntentCopyWith<$Res>  {
  factory $SearchIntentCopyWith(SearchIntent value, $Res Function(SearchIntent) _then) = _$SearchIntentCopyWithImpl;
@useResult
$Res call({
 List<String> keywords, List<String> excludeKeywords, List<String> cuisines, List<DietaryTag> includeTags, List<DietaryTag> excludeTags, int? maxPriceAgorot, bool openNowOnly, SearchSort sort
});




}
/// @nodoc
class _$SearchIntentCopyWithImpl<$Res>
    implements $SearchIntentCopyWith<$Res> {
  _$SearchIntentCopyWithImpl(this._self, this._then);

  final SearchIntent _self;
  final $Res Function(SearchIntent) _then;

/// Create a copy of SearchIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keywords = null,Object? excludeKeywords = null,Object? cuisines = null,Object? includeTags = null,Object? excludeTags = null,Object? maxPriceAgorot = freezed,Object? openNowOnly = null,Object? sort = null,}) {
  return _then(SearchIntent(
keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,excludeKeywords: null == excludeKeywords ? _self.excludeKeywords : excludeKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,cuisines: null == cuisines ? _self.cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<String>,includeTags: null == includeTags ? _self.includeTags : includeTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,excludeTags: null == excludeTags ? _self.excludeTags : excludeTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,maxPriceAgorot: freezed == maxPriceAgorot ? _self.maxPriceAgorot : maxPriceAgorot // ignore: cast_nullable_to_non_nullable
as int?,openNowOnly: null == openNowOnly ? _self.openNowOnly : openNowOnly // ignore: cast_nullable_to_non_nullable
as bool,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SearchSort,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchIntent].
extension SearchIntentPatterns on SearchIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchIntent value)  $default,){
final _that = this;
switch (_that) {
case _SearchIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchIntent value)?  $default,){
final _that = this;
switch (_that) {
case _SearchIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> keywords,  List<String> excludeKeywords,  List<String> cuisines,  List<DietaryTag> includeTags,  List<DietaryTag> excludeTags,  int? maxPriceAgorot,  bool openNowOnly,  SearchSort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchIntent() when $default != null:
return $default(_that.keywords,_that.excludeKeywords,_that.cuisines,_that.includeTags,_that.excludeTags,_that.maxPriceAgorot,_that.openNowOnly,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> keywords,  List<String> excludeKeywords,  List<String> cuisines,  List<DietaryTag> includeTags,  List<DietaryTag> excludeTags,  int? maxPriceAgorot,  bool openNowOnly,  SearchSort sort)  $default,) {final _that = this;
switch (_that) {
case _SearchIntent():
return $default(_that.keywords,_that.excludeKeywords,_that.cuisines,_that.includeTags,_that.excludeTags,_that.maxPriceAgorot,_that.openNowOnly,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> keywords,  List<String> excludeKeywords,  List<String> cuisines,  List<DietaryTag> includeTags,  List<DietaryTag> excludeTags,  int? maxPriceAgorot,  bool openNowOnly,  SearchSort sort)?  $default,) {final _that = this;
switch (_that) {
case _SearchIntent() when $default != null:
return $default(_that.keywords,_that.excludeKeywords,_that.cuisines,_that.includeTags,_that.excludeTags,_that.maxPriceAgorot,_that.openNowOnly,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _SearchIntent implements SearchIntent {
  const _SearchIntent({required  List<String> keywords, required  List<String> excludeKeywords, required  List<String> cuisines, required  List<DietaryTag> includeTags, required  List<DietaryTag> excludeTags, required this.maxPriceAgorot, required this.openNowOnly, required this.sort}): _keywords = keywords,_excludeKeywords = excludeKeywords,_cuisines = cuisines,_includeTags = includeTags,_excludeTags = excludeTags;
  

 final  List<String> _keywords;
@override List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

 final  List<String> _excludeKeywords;
@override List<String> get excludeKeywords {
  if (_excludeKeywords is EqualUnmodifiableListView) return _excludeKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludeKeywords);
}

 final  List<String> _cuisines;
@override List<String> get cuisines {
  if (_cuisines is EqualUnmodifiableListView) return _cuisines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuisines);
}

 final  List<DietaryTag> _includeTags;
@override List<DietaryTag> get includeTags {
  if (_includeTags is EqualUnmodifiableListView) return _includeTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_includeTags);
}

 final  List<DietaryTag> _excludeTags;
@override List<DietaryTag> get excludeTags {
  if (_excludeTags is EqualUnmodifiableListView) return _excludeTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludeTags);
}

@override final  int? maxPriceAgorot;
@override final  bool openNowOnly;
@override final  SearchSort sort;

/// Create a copy of SearchIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchIntentCopyWith<_SearchIntent> get copyWith => __$SearchIntentCopyWithImpl<_SearchIntent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchIntent&&const DeepCollectionEquality().equals(other.keywords, _keywords)&&const DeepCollectionEquality().equals(other.excludeKeywords, _excludeKeywords)&&const DeepCollectionEquality().equals(other.cuisines, _cuisines)&&const DeepCollectionEquality().equals(other.includeTags, _includeTags)&&const DeepCollectionEquality().equals(other.excludeTags, _excludeTags)&&(identical(other.maxPriceAgorot, maxPriceAgorot) || other.maxPriceAgorot == maxPriceAgorot)&&(identical(other.openNowOnly, openNowOnly) || other.openNowOnly == openNowOnly)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_keywords),const DeepCollectionEquality().hash(_excludeKeywords),const DeepCollectionEquality().hash(_cuisines),const DeepCollectionEquality().hash(_includeTags),const DeepCollectionEquality().hash(_excludeTags),maxPriceAgorot,openNowOnly,sort);
}

@override
String toString() {
    return 'SearchIntent(keywords: $keywords, excludeKeywords: $excludeKeywords, cuisines: $cuisines, includeTags: $includeTags, excludeTags: $excludeTags, maxPriceAgorot: $maxPriceAgorot, openNowOnly: $openNowOnly, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$SearchIntentCopyWith<$Res> implements $SearchIntentCopyWith<$Res> {
  factory _$SearchIntentCopyWith(_SearchIntent value, $Res Function(_SearchIntent) _then) = __$SearchIntentCopyWithImpl;
@override @useResult
$Res call({
 List<String> keywords, List<String> excludeKeywords, List<String> cuisines, List<DietaryTag> includeTags, List<DietaryTag> excludeTags, int? maxPriceAgorot, bool openNowOnly, SearchSort sort
});




}
/// @nodoc
class __$SearchIntentCopyWithImpl<$Res>
    implements _$SearchIntentCopyWith<$Res> {
  __$SearchIntentCopyWithImpl(this._self, this._then);

  final _SearchIntent _self;
  final $Res Function(_SearchIntent) _then;

/// Create a copy of SearchIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keywords = null,Object? excludeKeywords = null,Object? cuisines = null,Object? includeTags = null,Object? excludeTags = null,Object? maxPriceAgorot = freezed,Object? openNowOnly = null,Object? sort = null,}) {
  return _then(_SearchIntent(
keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,excludeKeywords: null == excludeKeywords ? _self._excludeKeywords : excludeKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,cuisines: null == cuisines ? _self._cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<String>,includeTags: null == includeTags ? _self._includeTags : includeTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,excludeTags: null == excludeTags ? _self._excludeTags : excludeTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,maxPriceAgorot: freezed == maxPriceAgorot ? _self.maxPriceAgorot : maxPriceAgorot // ignore: cast_nullable_to_non_nullable
as int?,openNowOnly: null == openNowOnly ? _self.openNowOnly : openNowOnly // ignore: cast_nullable_to_non_nullable
as bool,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SearchSort,
  ));
}


}

/// @nodoc
mixin _$DishFinderReply {

 String get reply; List<DishResult> get results; SearchIntent get intent; List<String> get relaxed;
/// Create a copy of DishFinderReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DishFinderReplyCopyWith<DishFinderReply> get copyWith => _$DishFinderReplyCopyWithImpl<DishFinderReply>(this as DishFinderReply, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DishFinderReply;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DishFinderReply&&(identical(other.reply, _this.reply) || other.reply == _this.reply)&&const DeepCollectionEquality().equals(other.results, _this.results)&&(identical(other.intent, _this.intent) || other.intent == _this.intent)&&const DeepCollectionEquality().equals(other.relaxed, _this.relaxed));
}


@override
int get hashCode {
  final _this = this as DishFinderReply;
  return Object.hash(runtimeType,_this.reply,const DeepCollectionEquality().hash(_this.results),_this.intent,const DeepCollectionEquality().hash(_this.relaxed));
}

@override
String toString() {
  final _this = this as DishFinderReply;
  return 'DishFinderReply(reply: ${_this.reply}, results: ${_this.results}, intent: ${_this.intent}, relaxed: ${_this.relaxed})';
}


}

/// @nodoc
abstract mixin class $DishFinderReplyCopyWith<$Res>  {
  factory $DishFinderReplyCopyWith(DishFinderReply value, $Res Function(DishFinderReply) _then) = _$DishFinderReplyCopyWithImpl;
@useResult
$Res call({
 String reply, List<DishResult> results, SearchIntent intent, List<String> relaxed
});


$SearchIntentCopyWith<$Res> get intent;

}
/// @nodoc
class _$DishFinderReplyCopyWithImpl<$Res>
    implements $DishFinderReplyCopyWith<$Res> {
  _$DishFinderReplyCopyWithImpl(this._self, this._then);

  final DishFinderReply _self;
  final $Res Function(DishFinderReply) _then;

/// Create a copy of DishFinderReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reply = null,Object? results = null,Object? intent = null,Object? relaxed = null,}) {
  return _then(DishFinderReply(
reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<DishResult>,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as SearchIntent,relaxed: null == relaxed ? _self.relaxed : relaxed // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of DishFinderReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchIntentCopyWith<$Res> get intent {
  
  return $SearchIntentCopyWith<$Res>(_self.intent, (value) {
    return _then(_self.copyWith(intent: value));
  });
}
}


/// Adds pattern-matching-related methods to [DishFinderReply].
extension DishFinderReplyPatterns on DishFinderReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DishFinderReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DishFinderReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DishFinderReply value)  $default,){
final _that = this;
switch (_that) {
case _DishFinderReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DishFinderReply value)?  $default,){
final _that = this;
switch (_that) {
case _DishFinderReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reply,  List<DishResult> results,  SearchIntent intent,  List<String> relaxed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DishFinderReply() when $default != null:
return $default(_that.reply,_that.results,_that.intent,_that.relaxed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reply,  List<DishResult> results,  SearchIntent intent,  List<String> relaxed)  $default,) {final _that = this;
switch (_that) {
case _DishFinderReply():
return $default(_that.reply,_that.results,_that.intent,_that.relaxed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reply,  List<DishResult> results,  SearchIntent intent,  List<String> relaxed)?  $default,) {final _that = this;
switch (_that) {
case _DishFinderReply() when $default != null:
return $default(_that.reply,_that.results,_that.intent,_that.relaxed);case _:
  return null;

}
}

}

/// @nodoc


class _DishFinderReply implements DishFinderReply {
  const _DishFinderReply({required this.reply, required  List<DishResult> results, required this.intent, required  List<String> relaxed}): _results = results,_relaxed = relaxed;
  

@override final  String reply;
 final  List<DishResult> _results;
@override List<DishResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override final  SearchIntent intent;
 final  List<String> _relaxed;
@override List<String> get relaxed {
  if (_relaxed is EqualUnmodifiableListView) return _relaxed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relaxed);
}


/// Create a copy of DishFinderReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DishFinderReplyCopyWith<_DishFinderReply> get copyWith => __$DishFinderReplyCopyWithImpl<_DishFinderReply>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DishFinderReply&&(identical(other.reply, reply) || other.reply == reply)&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.intent, intent) || other.intent == intent)&&const DeepCollectionEquality().equals(other.relaxed, _relaxed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reply,const DeepCollectionEquality().hash(_results),intent,const DeepCollectionEquality().hash(_relaxed));
}

@override
String toString() {
    return 'DishFinderReply(reply: $reply, results: $results, intent: $intent, relaxed: $relaxed)';
}


}

/// @nodoc
abstract mixin class _$DishFinderReplyCopyWith<$Res> implements $DishFinderReplyCopyWith<$Res> {
  factory _$DishFinderReplyCopyWith(_DishFinderReply value, $Res Function(_DishFinderReply) _then) = __$DishFinderReplyCopyWithImpl;
@override @useResult
$Res call({
 String reply, List<DishResult> results, SearchIntent intent, List<String> relaxed
});


@override $SearchIntentCopyWith<$Res> get intent;

}
/// @nodoc
class __$DishFinderReplyCopyWithImpl<$Res>
    implements _$DishFinderReplyCopyWith<$Res> {
  __$DishFinderReplyCopyWithImpl(this._self, this._then);

  final _DishFinderReply _self;
  final $Res Function(_DishFinderReply) _then;

/// Create a copy of DishFinderReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reply = null,Object? results = null,Object? intent = null,Object? relaxed = null,}) {
  return _then(_DishFinderReply(
reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<DishResult>,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as SearchIntent,relaxed: null == relaxed ? _self._relaxed : relaxed // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of DishFinderReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchIntentCopyWith<$Res> get intent {
  
  return $SearchIntentCopyWith<$Res>(_self.intent, (value) {
    return _then(_self.copyWith(intent: value));
  });
}
}

// dart format on
