import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'features/authentication/data/datasources/user_local_datasource.dart';
import 'features/authentication/data/models/user_model.dart';
import 'features/authentication/data/repositories/user_repository_impl.dart';
import 'features/authentication/domain/repositories/user_repository.dart';
import 'features/authentication/domain/usecases/create_user.dart';
import 'features/authentication/domain/usecases/get_user.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  
  // Open boxes
  final userBox = await Hive.openBox<UserModel>('users');

  // BLoCs
  sl.registerFactory(() => AuthBloc(
        getUser: sl(),
        createUser: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetUser(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(userBox),
  );
}