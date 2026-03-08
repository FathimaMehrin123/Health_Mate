import 'package:get_it/get_it.dart';
import 'package:health_mate/features/sleep/models/sleep_record_model.dart';
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

// ===== Sleep Feature imports =====
import 'features/sleep/data/datasources/microphone_datasource.dart';
import 'features/sleep/data/datasources/sleep_local_datasource.dart';
import 'features/sleep/data/repositories/sleep_repository_impl.dart';
import 'features/sleep/domain/repositories/sleep_repository.dart';
import 'features/sleep/domain/usecases/get_sleep_records.dart';
import 'features/sleep/domain/usecases/get_last_night_sleep.dart';
import 'features/sleep/domain/usecases/save_sleep_record.dart';
import 'features/sleep/domain/usecases/analyze_sleep_quality.dart';
import 'features/sleep/presentation/bloc/sleep_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =========================
  // Hive initialization
  // =========================
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(SleepRecordModelAdapter());

  // Open all boxes and store references
  final userBox = await Hive.openBox<UserModel>('users');
  final activityBox = await Hive.openBox<ActivityModel>('activities');
  final sleepBox = await Hive.openBox<SleepRecordModel>('sleep_records');

  // Register boxes in GetIt for dependency injection
  sl.registerSingleton<Box<UserModel>>(userBox);
  sl.registerSingleton<Box<ActivityModel>>(activityBox);
  sl.registerSingleton<Box<SleepRecordModel>>(sleepBox);

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
  // Sleep Feature
  // =========================

  // Data Sources
  sl.registerLazySingleton<SleepLocalDataSource>(
    () => SleepLocalDataSourceImpl(sleepBox),
  );

  sl.registerLazySingleton<MicrophoneDataSource>(
    () => MicrophoneDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<SleepRepository>(
    () => SleepRepositoryImpl(
      localDataSource: sl<SleepLocalDataSource>(),
      microphoneDataSource: sl<MicrophoneDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetSleepRecords>(
    () => GetSleepRecords(sl<SleepRepository>()),
  );

  sl.registerLazySingleton<GetLastNightSleep>(
    () => GetLastNightSleep(sl<SleepRepository>()),
  );

  sl.registerLazySingleton<SaveSleepRecord>(
    () => SaveSleepRecord(sl<SleepRepository>()),
  );

  sl.registerLazySingleton<AnalyzeSleepQuality>(
    () => AnalyzeSleepQuality(sl<SleepRepository>()),
  );

  // BLoC
  sl.registerLazySingleton<SleepBloc>(
    () => SleepBloc(
      getSleepRecords: sl<GetSleepRecords>(),
      getLastNightSleep: sl<GetLastNightSleep>(),
      saveSleepRecord: sl<SaveSleepRecord>(),
      analyzeSleepQuality: sl<AnalyzeSleepQuality>(),
      repository: sl<SleepRepository>(),
    ),
  );

  // =========================
  // Services
  // =========================

  sl.registerLazySingleton(() => MLService());
}