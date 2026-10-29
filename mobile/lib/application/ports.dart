import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/ports/auth_repository.dart';
import '../domain/ports/catalog_repository.dart';
import '../domain/ports/dish_finder_repository.dart';
import '../domain/ports/orders_repository.dart';
import '../domain/ports/session_store.dart';

part 'ports.g.dart';

/// Ports throw until [bootstrapApp] overrides them. Tests override the same
/// providers with fakes.
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) =>
    throw UnimplementedError('bound in app/bootstrap.dart');

@Riverpod(keepAlive: true)
OrdersRepository ordersRepository(Ref ref) =>
    throw UnimplementedError('bound in app/bootstrap.dart');

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    throw UnimplementedError('bound in app/bootstrap.dart');

@Riverpod(keepAlive: true)
DishFinderRepository dishFinderRepository(Ref ref) =>
    throw UnimplementedError('bound in app/bootstrap.dart');

@Riverpod(keepAlive: true)
SessionStore sessionStore(Ref ref) =>
    throw UnimplementedError('bound in app/bootstrap.dart');
