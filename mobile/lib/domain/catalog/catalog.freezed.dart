// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpeningHours {

 int get dayOfWeek; String get opensAt; String get closesAt;
/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpeningHoursCopyWith<OpeningHours> get copyWith => _$OpeningHoursCopyWithImpl<OpeningHours>(this as OpeningHours, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OpeningHours;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpeningHours&&(identical(other.dayOfWeek, _this.dayOfWeek) || other.dayOfWeek == _this.dayOfWeek)&&(identical(other.opensAt, _this.opensAt) || other.opensAt == _this.opensAt)&&(identical(other.closesAt, _this.closesAt) || other.closesAt == _this.closesAt));
}


@override
int get hashCode {
  final _this = this as OpeningHours;
  return Object.hash(runtimeType,_this.dayOfWeek,_this.opensAt,_this.closesAt);
}

@override
String toString() {
  final _this = this as OpeningHours;
  return 'OpeningHours(dayOfWeek: ${_this.dayOfWeek}, opensAt: ${_this.opensAt}, closesAt: ${_this.closesAt})';
}


}

/// @nodoc
abstract mixin class $OpeningHoursCopyWith<$Res>  {
  factory $OpeningHoursCopyWith(OpeningHours value, $Res Function(OpeningHours) _then) = _$OpeningHoursCopyWithImpl;
@useResult
$Res call({
 int dayOfWeek, String opensAt, String closesAt
});




}
/// @nodoc
class _$OpeningHoursCopyWithImpl<$Res>
    implements $OpeningHoursCopyWith<$Res> {
  _$OpeningHoursCopyWithImpl(this._self, this._then);

  final OpeningHours _self;
  final $Res Function(OpeningHours) _then;

/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? opensAt = null,Object? closesAt = null,}) {
  return _then(OpeningHours(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,opensAt: null == opensAt ? _self.opensAt : opensAt // ignore: cast_nullable_to_non_nullable
as String,closesAt: null == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OpeningHours].
extension OpeningHoursPatterns on OpeningHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpeningHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpeningHours value)  $default,){
final _that = this;
switch (_that) {
case _OpeningHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpeningHours value)?  $default,){
final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayOfWeek,  String opensAt,  String closesAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
return $default(_that.dayOfWeek,_that.opensAt,_that.closesAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayOfWeek,  String opensAt,  String closesAt)  $default,) {final _that = this;
switch (_that) {
case _OpeningHours():
return $default(_that.dayOfWeek,_that.opensAt,_that.closesAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayOfWeek,  String opensAt,  String closesAt)?  $default,) {final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
return $default(_that.dayOfWeek,_that.opensAt,_that.closesAt);case _:
  return null;

}
}

}

/// @nodoc


class _OpeningHours implements OpeningHours {
  const _OpeningHours({required this.dayOfWeek, required this.opensAt, required this.closesAt});
  

@override final  int dayOfWeek;
@override final  String opensAt;
@override final  String closesAt;

/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpeningHoursCopyWith<_OpeningHours> get copyWith => __$OpeningHoursCopyWithImpl<_OpeningHours>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpeningHours&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.opensAt, opensAt) || other.opensAt == opensAt)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dayOfWeek,opensAt,closesAt);
}

@override
String toString() {
    return 'OpeningHours(dayOfWeek: $dayOfWeek, opensAt: $opensAt, closesAt: $closesAt)';
}


}

/// @nodoc
abstract mixin class _$OpeningHoursCopyWith<$Res> implements $OpeningHoursCopyWith<$Res> {
  factory _$OpeningHoursCopyWith(_OpeningHours value, $Res Function(_OpeningHours) _then) = __$OpeningHoursCopyWithImpl;
@override @useResult
$Res call({
 int dayOfWeek, String opensAt, String closesAt
});




}
/// @nodoc
class __$OpeningHoursCopyWithImpl<$Res>
    implements _$OpeningHoursCopyWith<$Res> {
  __$OpeningHoursCopyWithImpl(this._self, this._then);

  final _OpeningHours _self;
  final $Res Function(_OpeningHours) _then;

/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? opensAt = null,Object? closesAt = null,}) {
  return _then(_OpeningHours(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,opensAt: null == opensAt ? _self.opensAt : opensAt // ignore: cast_nullable_to_non_nullable
as String,closesAt: null == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MenuItem {

 String get id; String get restaurantId; String get categoryId; String get name; String get description; int get priceAgorot; List<DietaryTag> get dietaryTags; bool get isAvailable;
/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemCopyWith<MenuItem> get copyWith => _$MenuItemCopyWithImpl<MenuItem>(this as MenuItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MenuItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.restaurantId, _this.restaurantId) || other.restaurantId == _this.restaurantId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.priceAgorot, _this.priceAgorot) || other.priceAgorot == _this.priceAgorot)&&const DeepCollectionEquality().equals(other.dietaryTags, _this.dietaryTags)&&(identical(other.isAvailable, _this.isAvailable) || other.isAvailable == _this.isAvailable));
}


@override
int get hashCode {
  final _this = this as MenuItem;
  return Object.hash(runtimeType,_this.id,_this.restaurantId,_this.categoryId,_this.name,_this.description,_this.priceAgorot,const DeepCollectionEquality().hash(_this.dietaryTags),_this.isAvailable);
}

@override
String toString() {
  final _this = this as MenuItem;
  return 'MenuItem(id: ${_this.id}, restaurantId: ${_this.restaurantId}, categoryId: ${_this.categoryId}, name: ${_this.name}, description: ${_this.description}, priceAgorot: ${_this.priceAgorot}, dietaryTags: ${_this.dietaryTags}, isAvailable: ${_this.isAvailable})';
}


}

/// @nodoc
abstract mixin class $MenuItemCopyWith<$Res>  {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) _then) = _$MenuItemCopyWithImpl;
@useResult
$Res call({
 String id, String restaurantId, String categoryId, String name, String description, int priceAgorot, List<DietaryTag> dietaryTags, bool isAvailable
});




}
/// @nodoc
class _$MenuItemCopyWithImpl<$Res>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._self, this._then);

  final MenuItem _self;
  final $Res Function(MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? restaurantId = null,Object? categoryId = null,Object? name = null,Object? description = null,Object? priceAgorot = null,Object? dietaryTags = null,Object? isAvailable = null,}) {
  return _then(MenuItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceAgorot: null == priceAgorot ? _self.priceAgorot : priceAgorot // ignore: cast_nullable_to_non_nullable
as int,dietaryTags: null == dietaryTags ? _self.dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItem].
extension MenuItemPatterns on MenuItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuItem value)  $default,){
final _that = this;
switch (_that) {
case _MenuItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuItem value)?  $default,){
final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String restaurantId,  String categoryId,  String name,  String description,  int priceAgorot,  List<DietaryTag> dietaryTags,  bool isAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that.id,_that.restaurantId,_that.categoryId,_that.name,_that.description,_that.priceAgorot,_that.dietaryTags,_that.isAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String restaurantId,  String categoryId,  String name,  String description,  int priceAgorot,  List<DietaryTag> dietaryTags,  bool isAvailable)  $default,) {final _that = this;
switch (_that) {
case _MenuItem():
return $default(_that.id,_that.restaurantId,_that.categoryId,_that.name,_that.description,_that.priceAgorot,_that.dietaryTags,_that.isAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String restaurantId,  String categoryId,  String name,  String description,  int priceAgorot,  List<DietaryTag> dietaryTags,  bool isAvailable)?  $default,) {final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that.id,_that.restaurantId,_that.categoryId,_that.name,_that.description,_that.priceAgorot,_that.dietaryTags,_that.isAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _MenuItem implements MenuItem {
  const _MenuItem({required this.id, required this.restaurantId, required this.categoryId, required this.name, required this.description, required this.priceAgorot, required  List<DietaryTag> dietaryTags, required this.isAvailable}): _dietaryTags = dietaryTags;
  

@override final  String id;
@override final  String restaurantId;
@override final  String categoryId;
@override final  String name;
@override final  String description;
@override final  int priceAgorot;
 final  List<DietaryTag> _dietaryTags;
@override List<DietaryTag> get dietaryTags {
  if (_dietaryTags is EqualUnmodifiableListView) return _dietaryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryTags);
}

@override final  bool isAvailable;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuItemCopyWith<_MenuItem> get copyWith => __$MenuItemCopyWithImpl<_MenuItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuItem&&(identical(other.id, id) || other.id == id)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceAgorot, priceAgorot) || other.priceAgorot == priceAgorot)&&const DeepCollectionEquality().equals(other.dietaryTags, _dietaryTags)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,restaurantId,categoryId,name,description,priceAgorot,const DeepCollectionEquality().hash(_dietaryTags),isAvailable);
}

@override
String toString() {
    return 'MenuItem(id: $id, restaurantId: $restaurantId, categoryId: $categoryId, name: $name, description: $description, priceAgorot: $priceAgorot, dietaryTags: $dietaryTags, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class _$MenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory _$MenuItemCopyWith(_MenuItem value, $Res Function(_MenuItem) _then) = __$MenuItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String restaurantId, String categoryId, String name, String description, int priceAgorot, List<DietaryTag> dietaryTags, bool isAvailable
});




}
/// @nodoc
class __$MenuItemCopyWithImpl<$Res>
    implements _$MenuItemCopyWith<$Res> {
  __$MenuItemCopyWithImpl(this._self, this._then);

  final _MenuItem _self;
  final $Res Function(_MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? restaurantId = null,Object? categoryId = null,Object? name = null,Object? description = null,Object? priceAgorot = null,Object? dietaryTags = null,Object? isAvailable = null,}) {
  return _then(_MenuItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceAgorot: null == priceAgorot ? _self.priceAgorot : priceAgorot // ignore: cast_nullable_to_non_nullable
as int,dietaryTags: null == dietaryTags ? _self._dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$MenuCategory {

 String get id; String get name; List<MenuItem> get items;
/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuCategoryCopyWith<MenuCategory> get copyWith => _$MenuCategoryCopyWithImpl<MenuCategory>(this as MenuCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MenuCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as MenuCategory;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as MenuCategory;
  return 'MenuCategory(id: ${_this.id}, name: ${_this.name}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $MenuCategoryCopyWith<$Res>  {
  factory $MenuCategoryCopyWith(MenuCategory value, $Res Function(MenuCategory) _then) = _$MenuCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<MenuItem> items
});




}
/// @nodoc
class _$MenuCategoryCopyWithImpl<$Res>
    implements $MenuCategoryCopyWith<$Res> {
  _$MenuCategoryCopyWithImpl(this._self, this._then);

  final MenuCategory _self;
  final $Res Function(MenuCategory) _then;

/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? items = null,}) {
  return _then(MenuCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuCategory].
extension MenuCategoryPatterns on MenuCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuCategory value)  $default,){
final _that = this;
switch (_that) {
case _MenuCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuCategory value)?  $default,){
final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<MenuItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
return $default(_that.id,_that.name,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<MenuItem> items)  $default,) {final _that = this;
switch (_that) {
case _MenuCategory():
return $default(_that.id,_that.name,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<MenuItem> items)?  $default,) {final _that = this;
switch (_that) {
case _MenuCategory() when $default != null:
return $default(_that.id,_that.name,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _MenuCategory implements MenuCategory {
  const _MenuCategory({required this.id, required this.name, required  List<MenuItem> items}): _items = items;
  

@override final  String id;
@override final  String name;
 final  List<MenuItem> _items;
@override List<MenuItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuCategoryCopyWith<_MenuCategory> get copyWith => __$MenuCategoryCopyWithImpl<_MenuCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'MenuCategory(id: $id, name: $name, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MenuCategoryCopyWith<$Res> implements $MenuCategoryCopyWith<$Res> {
  factory _$MenuCategoryCopyWith(_MenuCategory value, $Res Function(_MenuCategory) _then) = __$MenuCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<MenuItem> items
});




}
/// @nodoc
class __$MenuCategoryCopyWithImpl<$Res>
    implements _$MenuCategoryCopyWith<$Res> {
  __$MenuCategoryCopyWithImpl(this._self, this._then);

  final _MenuCategory _self;
  final $Res Function(_MenuCategory) _then;

/// Create a copy of MenuCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? items = null,}) {
  return _then(_MenuCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,
  ));
}


}

/// @nodoc
mixin _$Restaurant {

 String get id; String get name; String get cuisine; String get address; bool get isOpen; List<OpeningHours> get openingHours; int get minOrderAgorot; int get deliveryFeeAgorot;
/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantCopyWith<Restaurant> get copyWith => _$RestaurantCopyWithImpl<Restaurant>(this as Restaurant, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Restaurant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Restaurant&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.cuisine, _this.cuisine) || other.cuisine == _this.cuisine)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.isOpen, _this.isOpen) || other.isOpen == _this.isOpen)&&const DeepCollectionEquality().equals(other.openingHours, _this.openingHours)&&(identical(other.minOrderAgorot, _this.minOrderAgorot) || other.minOrderAgorot == _this.minOrderAgorot)&&(identical(other.deliveryFeeAgorot, _this.deliveryFeeAgorot) || other.deliveryFeeAgorot == _this.deliveryFeeAgorot));
}


@override
int get hashCode {
  final _this = this as Restaurant;
  return Object.hash(runtimeType,_this.id,_this.name,_this.cuisine,_this.address,_this.isOpen,const DeepCollectionEquality().hash(_this.openingHours),_this.minOrderAgorot,_this.deliveryFeeAgorot);
}

@override
String toString() {
  final _this = this as Restaurant;
  return 'Restaurant(id: ${_this.id}, name: ${_this.name}, cuisine: ${_this.cuisine}, address: ${_this.address}, isOpen: ${_this.isOpen}, openingHours: ${_this.openingHours}, minOrderAgorot: ${_this.minOrderAgorot}, deliveryFeeAgorot: ${_this.deliveryFeeAgorot})';
}


}

/// @nodoc
abstract mixin class $RestaurantCopyWith<$Res>  {
  factory $RestaurantCopyWith(Restaurant value, $Res Function(Restaurant) _then) = _$RestaurantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String cuisine, String address, bool isOpen, List<OpeningHours> openingHours, int minOrderAgorot, int deliveryFeeAgorot
});




}
/// @nodoc
class _$RestaurantCopyWithImpl<$Res>
    implements $RestaurantCopyWith<$Res> {
  _$RestaurantCopyWithImpl(this._self, this._then);

  final Restaurant _self;
  final $Res Function(Restaurant) _then;

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cuisine = null,Object? address = null,Object? isOpen = null,Object? openingHours = null,Object? minOrderAgorot = null,Object? deliveryFeeAgorot = null,}) {
  return _then(Restaurant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cuisine: null == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,openingHours: null == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as List<OpeningHours>,minOrderAgorot: null == minOrderAgorot ? _self.minOrderAgorot : minOrderAgorot // ignore: cast_nullable_to_non_nullable
as int,deliveryFeeAgorot: null == deliveryFeeAgorot ? _self.deliveryFeeAgorot : deliveryFeeAgorot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Restaurant].
extension RestaurantPatterns on Restaurant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Restaurant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Restaurant value)  $default,){
final _that = this;
switch (_that) {
case _Restaurant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Restaurant value)?  $default,){
final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String cuisine,  String address,  bool isOpen,  List<OpeningHours> openingHours,  int minOrderAgorot,  int deliveryFeeAgorot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
return $default(_that.id,_that.name,_that.cuisine,_that.address,_that.isOpen,_that.openingHours,_that.minOrderAgorot,_that.deliveryFeeAgorot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String cuisine,  String address,  bool isOpen,  List<OpeningHours> openingHours,  int minOrderAgorot,  int deliveryFeeAgorot)  $default,) {final _that = this;
switch (_that) {
case _Restaurant():
return $default(_that.id,_that.name,_that.cuisine,_that.address,_that.isOpen,_that.openingHours,_that.minOrderAgorot,_that.deliveryFeeAgorot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String cuisine,  String address,  bool isOpen,  List<OpeningHours> openingHours,  int minOrderAgorot,  int deliveryFeeAgorot)?  $default,) {final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
return $default(_that.id,_that.name,_that.cuisine,_that.address,_that.isOpen,_that.openingHours,_that.minOrderAgorot,_that.deliveryFeeAgorot);case _:
  return null;

}
}

}

/// @nodoc


class _Restaurant implements Restaurant {
  const _Restaurant({required this.id, required this.name, required this.cuisine, required this.address, required this.isOpen, required  List<OpeningHours> openingHours, required this.minOrderAgorot, required this.deliveryFeeAgorot}): _openingHours = openingHours;
  

@override final  String id;
@override final  String name;
@override final  String cuisine;
@override final  String address;
@override final  bool isOpen;
 final  List<OpeningHours> _openingHours;
@override List<OpeningHours> get openingHours {
  if (_openingHours is EqualUnmodifiableListView) return _openingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openingHours);
}

@override final  int minOrderAgorot;
@override final  int deliveryFeeAgorot;

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantCopyWith<_Restaurant> get copyWith => __$RestaurantCopyWithImpl<_Restaurant>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Restaurant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.address, address) || other.address == address)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&const DeepCollectionEquality().equals(other.openingHours, _openingHours)&&(identical(other.minOrderAgorot, minOrderAgorot) || other.minOrderAgorot == minOrderAgorot)&&(identical(other.deliveryFeeAgorot, deliveryFeeAgorot) || other.deliveryFeeAgorot == deliveryFeeAgorot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,cuisine,address,isOpen,const DeepCollectionEquality().hash(_openingHours),minOrderAgorot,deliveryFeeAgorot);
}

@override
String toString() {
    return 'Restaurant(id: $id, name: $name, cuisine: $cuisine, address: $address, isOpen: $isOpen, openingHours: $openingHours, minOrderAgorot: $minOrderAgorot, deliveryFeeAgorot: $deliveryFeeAgorot)';
}


}

/// @nodoc
abstract mixin class _$RestaurantCopyWith<$Res> implements $RestaurantCopyWith<$Res> {
  factory _$RestaurantCopyWith(_Restaurant value, $Res Function(_Restaurant) _then) = __$RestaurantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String cuisine, String address, bool isOpen, List<OpeningHours> openingHours, int minOrderAgorot, int deliveryFeeAgorot
});




}
/// @nodoc
class __$RestaurantCopyWithImpl<$Res>
    implements _$RestaurantCopyWith<$Res> {
  __$RestaurantCopyWithImpl(this._self, this._then);

  final _Restaurant _self;
  final $Res Function(_Restaurant) _then;

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cuisine = null,Object? address = null,Object? isOpen = null,Object? openingHours = null,Object? minOrderAgorot = null,Object? deliveryFeeAgorot = null,}) {
  return _then(_Restaurant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cuisine: null == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,openingHours: null == openingHours ? _self._openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as List<OpeningHours>,minOrderAgorot: null == minOrderAgorot ? _self.minOrderAgorot : minOrderAgorot // ignore: cast_nullable_to_non_nullable
as int,deliveryFeeAgorot: null == deliveryFeeAgorot ? _self.deliveryFeeAgorot : deliveryFeeAgorot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RestaurantMenu {

 Restaurant get restaurant; List<MenuCategory> get categories;
/// Create a copy of RestaurantMenu
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantMenuCopyWith<RestaurantMenu> get copyWith => _$RestaurantMenuCopyWithImpl<RestaurantMenu>(this as RestaurantMenu, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RestaurantMenu;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantMenu&&(identical(other.restaurant, _this.restaurant) || other.restaurant == _this.restaurant)&&const DeepCollectionEquality().equals(other.categories, _this.categories));
}


@override
int get hashCode {
  final _this = this as RestaurantMenu;
  return Object.hash(runtimeType,_this.restaurant,const DeepCollectionEquality().hash(_this.categories));
}

@override
String toString() {
  final _this = this as RestaurantMenu;
  return 'RestaurantMenu(restaurant: ${_this.restaurant}, categories: ${_this.categories})';
}


}

/// @nodoc
abstract mixin class $RestaurantMenuCopyWith<$Res>  {
  factory $RestaurantMenuCopyWith(RestaurantMenu value, $Res Function(RestaurantMenu) _then) = _$RestaurantMenuCopyWithImpl;
@useResult
$Res call({
 Restaurant restaurant, List<MenuCategory> categories
});


$RestaurantCopyWith<$Res> get restaurant;

}
/// @nodoc
class _$RestaurantMenuCopyWithImpl<$Res>
    implements $RestaurantMenuCopyWith<$Res> {
  _$RestaurantMenuCopyWithImpl(this._self, this._then);

  final RestaurantMenu _self;
  final $Res Function(RestaurantMenu) _then;

/// Create a copy of RestaurantMenu
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? restaurant = null,Object? categories = null,}) {
  return _then(RestaurantMenu(
restaurant: null == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as Restaurant,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<MenuCategory>,
  ));
}
/// Create a copy of RestaurantMenu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantCopyWith<$Res> get restaurant {
  
  return $RestaurantCopyWith<$Res>(_self.restaurant, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}
}


/// Adds pattern-matching-related methods to [RestaurantMenu].
extension RestaurantMenuPatterns on RestaurantMenu {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantMenu value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantMenu() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantMenu value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantMenu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantMenu value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantMenu() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Restaurant restaurant,  List<MenuCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantMenu() when $default != null:
return $default(_that.restaurant,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Restaurant restaurant,  List<MenuCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _RestaurantMenu():
return $default(_that.restaurant,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Restaurant restaurant,  List<MenuCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantMenu() when $default != null:
return $default(_that.restaurant,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantMenu implements RestaurantMenu {
  const _RestaurantMenu({required this.restaurant, required  List<MenuCategory> categories}): _categories = categories;
  

@override final  Restaurant restaurant;
 final  List<MenuCategory> _categories;
@override List<MenuCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of RestaurantMenu
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantMenuCopyWith<_RestaurantMenu> get copyWith => __$RestaurantMenuCopyWithImpl<_RestaurantMenu>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantMenu&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&const DeepCollectionEquality().equals(other.categories, _categories));
}


@override
int get hashCode {
    return Object.hash(runtimeType,restaurant,const DeepCollectionEquality().hash(_categories));
}

@override
String toString() {
    return 'RestaurantMenu(restaurant: $restaurant, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$RestaurantMenuCopyWith<$Res> implements $RestaurantMenuCopyWith<$Res> {
  factory _$RestaurantMenuCopyWith(_RestaurantMenu value, $Res Function(_RestaurantMenu) _then) = __$RestaurantMenuCopyWithImpl;
@override @useResult
$Res call({
 Restaurant restaurant, List<MenuCategory> categories
});


@override $RestaurantCopyWith<$Res> get restaurant;

}
/// @nodoc
class __$RestaurantMenuCopyWithImpl<$Res>
    implements _$RestaurantMenuCopyWith<$Res> {
  __$RestaurantMenuCopyWithImpl(this._self, this._then);

  final _RestaurantMenu _self;
  final $Res Function(_RestaurantMenu) _then;

/// Create a copy of RestaurantMenu
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? restaurant = null,Object? categories = null,}) {
  return _then(_RestaurantMenu(
restaurant: null == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as Restaurant,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<MenuCategory>,
  ));
}

/// Create a copy of RestaurantMenu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantCopyWith<$Res> get restaurant {
  
  return $RestaurantCopyWith<$Res>(_self.restaurant, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}
}

// dart format on
