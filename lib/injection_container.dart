import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

// ===== Authentication feature imports =====
import 'features/authentication/data/datasources/user_local_datasource.dart';
import 'features/authentication/data/models/user_model.dart';
import 'features/authentication/data/repositories/user_repository_impl.dart';
import 'features/authentication/domain/repositories/user_repository.dart';
import 'features/authentication/domain/usecases/create_user.dart';
import 'features/authentication/domain/usecases/get_user.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

// ===== Activity feature imports =====
import 'features/activity/data/datasources/activity_local_datasource.dart';
import 'features/activity/data/datasources/sensor_datasource.dart';
import 'features/activity/data/models/activity_model.dart';
import 'features/activity/data/repositories/activity_repository_impl.dart';
import 'features/activity/domain/repositories/activity_repository.dart';
import 'features/activity/domain/usecases/classify_current_activity.dart';
import 'features/activity/domain/usecases/get_activities.dart';
import 'features/activity/domain/usecases/get_today_stats.dart';
import 'features/activity/domain/usecases/save_activity.dart';
import 'features/activity/presentation/bloc/activity_bloc.dart';
import 'services/ml_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =========================
  // Hive initialization
  // =========================
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ActivityModelAdapter());

  // Open boxes
  final userBox = await Hive.openBox<UserModel>('users');
  final activityBox = await Hive.openBox<ActivityModel>('activities');

  // =========================
  // Authentication Feature
  // =========================

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      getUser: sl(),
      createUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUser(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );

  // Data source
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(userBox),
  );

  // =========================
  // Activity Feature
  // =========================

  // BLoC
  sl.registerFactory(
    () => ActivityBloc(
      getActivities: sl(),
      classifyCurrentActivity: sl(),
      saveActivity: sl(),
      getTodayStats: sl(),
      sensorDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetActivities(sl()));
  sl.registerLazySingleton(() => ClassifyCurrentActivity(sl()));
  sl.registerLazySingleton(() => SaveActivity(sl()));
  sl.registerLazySingleton(() => GetTodayStats(sl()));

  // Repository
  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(
      localDataSource: sl(),
      sensorDataSource: sl(),
      mlService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ActivityLocalDataSource>(
    () => ActivityLocalDataSourceImpl(activityBox),
  );

  sl.registerLazySingleton<SensorDataSource>(
    () => SensorDataSourceImpl(),
  );

  // =========================
  // Services
  // =========================

  sl.registerLazySingleton(() => MLService());
}
