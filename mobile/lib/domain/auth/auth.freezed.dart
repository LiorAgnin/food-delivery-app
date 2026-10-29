// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Customer {

 String get id; String get phone;
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCopyWith<Customer> get copyWith => _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Customer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Customer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}


@override
int get hashCode {
  final _this = this as Customer;
  return Object.hash(runtimeType,_this.id,_this.phone);
}

@override
String toString() {
  final _this = this as Customer;
  return 'Customer(id: ${_this.id}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res>  {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) = _$CustomerCopyWithImpl;
@useResult
$Res call({
 String id, String phone
});




}
/// @nodoc
class _$CustomerCopyWithImpl<$Res>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = null,}) {
  return _then(Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Customer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Customer value)  $default,){
final _that = this;
switch (_that) {
case _Customer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Customer value)?  $default,){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String phone)  $default,) {final _that = this;
switch (_that) {
case _Customer():
return $default(_that.id,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String phone)?  $default,) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.phone);case _:
  return null;

}
}

}

/// @nodoc


class _Customer implements Customer {
  const _Customer({required this.id, required this.phone});
  

@override final  String id;
@override final  String phone;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCopyWith<_Customer> get copyWith => __$CustomerCopyWithImpl<_Customer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,phone);
}

@override
String toString() {
    return 'Customer(id: $id, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) = __$CustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, String phone
});




}
/// @nodoc
class __$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = null,}) {
  return _then(_Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$OtpChallenge {

 int get expiresInSeconds; String? get devCode;
/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpChallengeCopyWith<OtpChallenge> get copyWith => _$OtpChallengeCopyWithImpl<OtpChallenge>(this as OtpChallenge, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OtpChallenge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpChallenge&&(identical(other.expiresInSeconds, _this.expiresInSeconds) || other.expiresInSeconds == _this.expiresInSeconds)&&(identical(other.devCode, _this.devCode) || other.devCode == _this.devCode));
}


@override
int get hashCode {
  final _this = this as OtpChallenge;
  return Object.hash(runtimeType,_this.expiresInSeconds,_this.devCode);
}

@override
String toString() {
  final _this = this as OtpChallenge;
  return 'OtpChallenge(expiresInSeconds: ${_this.expiresInSeconds}, devCode: ${_this.devCode})';
}


}

/// @nodoc
abstract mixin class $OtpChallengeCopyWith<$Res>  {
  factory $OtpChallengeCopyWith(OtpChallenge value, $Res Function(OtpChallenge) _then) = _$OtpChallengeCopyWithImpl;
@useResult
$Res call({
 int expiresInSeconds, String? devCode
});




}
/// @nodoc
class _$OtpChallengeCopyWithImpl<$Res>
    implements $OtpChallengeCopyWith<$Res> {
  _$OtpChallengeCopyWithImpl(this._self, this._then);

  final OtpChallenge _self;
  final $Res Function(OtpChallenge) _then;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expiresInSeconds = null,Object? devCode = freezed,}) {
  return _then(OtpChallenge(
expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,devCode: freezed == devCode ? _self.devCode : devCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpChallenge].
extension OtpChallengePatterns on OtpChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpChallenge value)  $default,){
final _that = this;
switch (_that) {
case _OtpChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int expiresInSeconds,  String? devCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
return $default(_that.expiresInSeconds,_that.devCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int expiresInSeconds,  String? devCode)  $default,) {final _that = this;
switch (_that) {
case _OtpChallenge():
return $default(_that.expiresInSeconds,_that.devCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int expiresInSeconds,  String? devCode)?  $default,) {final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
return $default(_that.expiresInSeconds,_that.devCode);case _:
  return null;

}
}

}

/// @nodoc


class _OtpChallenge implements OtpChallenge {
  const _OtpChallenge({required this.expiresInSeconds, this.devCode});
  

@override final  int expiresInSeconds;
@override final  String? devCode;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpChallengeCopyWith<_OtpChallenge> get copyWith => __$OtpChallengeCopyWithImpl<_OtpChallenge>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpChallenge&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds)&&(identical(other.devCode, devCode) || other.devCode == devCode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,expiresInSeconds,devCode);
}

@override
String toString() {
    return 'OtpChallenge(expiresInSeconds: $expiresInSeconds, devCode: $devCode)';
}


}

/// @nodoc
abstract mixin class _$OtpChallengeCopyWith<$Res> implements $OtpChallengeCopyWith<$Res> {
  factory _$OtpChallengeCopyWith(_OtpChallenge value, $Res Function(_OtpChallenge) _then) = __$OtpChallengeCopyWithImpl;
@override @useResult
$Res call({
 int expiresInSeconds, String? devCode
});




}
/// @nodoc
class __$OtpChallengeCopyWithImpl<$Res>
    implements _$OtpChallengeCopyWith<$Res> {
  __$OtpChallengeCopyWithImpl(this._self, this._then);

  final _OtpChallenge _self;
  final $Res Function(_OtpChallenge) _then;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expiresInSeconds = null,Object? devCode = freezed,}) {
  return _then(_OtpChallenge(
expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,devCode: freezed == devCode ? _self.devCode : devCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$VerifiedAuth {

 String get accessToken; Customer get customer;
/// Create a copy of VerifiedAuth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifiedAuthCopyWith<VerifiedAuth> get copyWith => _$VerifiedAuthCopyWithImpl<VerifiedAuth>(this as VerifiedAuth, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VerifiedAuth;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifiedAuth&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.customer, _this.customer) || other.customer == _this.customer));
}


@override
int get hashCode {
  final _this = this as VerifiedAuth;
  return Object.hash(runtimeType,_this.accessToken,_this.customer);
}

@override
String toString() {
  final _this = this as VerifiedAuth;
  return 'VerifiedAuth(accessToken: ${_this.accessToken}, customer: ${_this.customer})';
}


}

/// @nodoc
abstract mixin class $VerifiedAuthCopyWith<$Res>  {
  factory $VerifiedAuthCopyWith(VerifiedAuth value, $Res Function(VerifiedAuth) _then) = _$VerifiedAuthCopyWithImpl;
@useResult
$Res call({
 String accessToken, Customer customer
});


$CustomerCopyWith<$Res> get customer;

}
/// @nodoc
class _$VerifiedAuthCopyWithImpl<$Res>
    implements $VerifiedAuthCopyWith<$Res> {
  _$VerifiedAuthCopyWithImpl(this._self, this._then);

  final VerifiedAuth _self;
  final $Res Function(VerifiedAuth) _then;

/// Create a copy of VerifiedAuth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? customer = null,}) {
  return _then(VerifiedAuth(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,
  ));
}
/// Create a copy of VerifiedAuth
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res> get customer {
  
  return $CustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [VerifiedAuth].
extension VerifiedAuthPatterns on VerifiedAuth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifiedAuth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifiedAuth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifiedAuth value)  $default,){
final _that = this;
switch (_that) {
case _VerifiedAuth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifiedAuth value)?  $default,){
final _that = this;
switch (_that) {
case _VerifiedAuth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  Customer customer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifiedAuth() when $default != null:
return $default(_that.accessToken,_that.customer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  Customer customer)  $default,) {final _that = this;
switch (_that) {
case _VerifiedAuth():
return $default(_that.accessToken,_that.customer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  Customer customer)?  $default,) {final _that = this;
switch (_that) {
case _VerifiedAuth() when $default != null:
return $default(_that.accessToken,_that.customer);case _:
  return null;

}
}

}

/// @nodoc


class _VerifiedAuth implements VerifiedAuth {
  const _VerifiedAuth({required this.accessToken, required this.customer});
  

@override final  String accessToken;
@override final  Customer customer;

/// Create a copy of VerifiedAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifiedAuthCopyWith<_VerifiedAuth> get copyWith => __$VerifiedAuthCopyWithImpl<_VerifiedAuth>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifiedAuth&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.customer, customer) || other.customer == customer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,customer);
}

@override
String toString() {
    return 'VerifiedAuth(accessToken: $accessToken, customer: $customer)';
}


}

/// @nodoc
abstract mixin class _$VerifiedAuthCopyWith<$Res> implements $VerifiedAuthCopyWith<$Res> {
  factory _$VerifiedAuthCopyWith(_VerifiedAuth value, $Res Function(_VerifiedAuth) _then) = __$VerifiedAuthCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, Customer customer
});


@override $CustomerCopyWith<$Res> get customer;

}
/// @nodoc
class __$VerifiedAuthCopyWithImpl<$Res>
    implements _$VerifiedAuthCopyWith<$Res> {
  __$VerifiedAuthCopyWithImpl(this._self, this._then);

  final _VerifiedAuth _self;
  final $Res Function(_VerifiedAuth) _then;

/// Create a copy of VerifiedAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? customer = null,}) {
  return _then(_VerifiedAuth(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,
  ));
}

/// Create a copy of VerifiedAuth
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res> get customer {
  
  return $CustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on
