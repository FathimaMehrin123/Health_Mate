import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:mocktail/mocktail.dart';

import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/features/activity/data/datasources/sensor_datasource.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';
import 'package:health_mate/features/activity/domain/usecases/classify_current_activity.dart';
import 'package:health_mate/features/activity/domain/usecases/get_activities.dart';
import 'package:health_mate/features/activity/domain/usecases/get_today_stats.dart';
import 'package:health_mate/features/activity/domain/usecases/save_activity.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_event.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_state.dart';

/// ───── MOCKS ─────
class MockGetActivities extends Mock implements GetActivities {}

class MockClassifyCurrentActivity extends Mock
    implements ClassifyCurrentActivity {}

class MockSaveActivity extends Mock implements SaveActivity {}

class MockGetTodayStats extends Mock implements GetTodayStats {}

class MockSensorDataSource extends Mock implements SensorDataSource {}

/// ✅ REQUIRED FAKES FOR MOCKTAIL
class FakeGetActivitiesParams extends Fake implements GetActivitiesParams {}

class FakeSaveActivityParams extends Fake implements SaveActivityParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  /// ✅ MUST BE BEFORE ANY TESTS RUN
  setUpAll(() {
    registerFallbackValue(FakeGetActivitiesParams());
    registerFallbackValue(FakeSaveActivityParams());
    registerFallbackValue(FakeNoParams());
  });

  late ActivityBloc bloc;
  late MockGetActivities mockGetActivities;
  late MockClassifyCurrentActivity mockClassifyCurrentActivity;
  late MockSaveActivity mockSaveActivity;
  late MockGetTodayStats mockGetTodayStats;
  late MockSensorDataSource mockSensorDataSource;

  final testDate = DateTime(2026, 1, 13, 10);

  final testActivities = [
    Activity(
      id: '1',
      timestamp: testDate,
      type: ActivityType.walking,
      confidence: 0.94,
      duration: 900,
      steps: 1200,
      calories: 45.0,
    ),
    Activity(
      id: '2',
      timestamp: testDate.subtract(const Duration(hours: 1)),
      type: ActivityType.sitting,
      confidence: 0.90,
      duration: 1800,
    ),
  ];

  final testStats = {
    'totalSteps': 1200,
    'totalCalories': 45.0,
    'totalDuration': 2700,
    'activityCount': 2,
  };

  setUp(() {
    mockGetActivities = MockGetActivities();
    mockClassifyCurrentActivity = MockClassifyCurrentActivity();
    mockSaveActivity = MockSaveActivity();
    mockGetTodayStats = MockGetTodayStats();
    mockSensorDataSource = MockSensorDataSource();

    /// ───── DEFAULT STUBS (CAN BE OVERRIDDEN IN TESTS) ─────

    // GetActivities - default success
    when(() => mockGetActivities(any()))
        .thenAnswer((_) async => Right(testActivities));

    // GetTodayStats - default success
    // ✅ FIX: Use `any()` instead of `NoParams()`
    when(() => mockGetTodayStats(any()))
        .thenAnswer((_) async => Right(testStats));

    // SensorDataSource
    when(() => mockSensorDataSource.startMonitoring())
        .thenAnswer((_) async {});

    when(() => mockSensorDataSource.stopMonitoring()).thenAnswer((_) async {});

    // ClassifyCurrentActivity - default success
    when(() => mockClassifyCurrentActivity(any()))
        .thenAnswer((_) async => Right(testActivities[0]));

    // SaveActivity - default success
    when(() => mockSaveActivity(any()))
        .thenAnswer((_) async => const Right(null));

    // Create bloc AFTER setting up mocks
    bloc = ActivityBloc(
      getActivities: mockGetActivities,
      classifyCurrentActivity: mockClassifyCurrentActivity,
      saveActivity: mockSaveActivity,
      getTodayStats: mockGetTodayStats,
      sensorDataSource: mockSensorDataSource,
    );
  });

  tearDown(() {
    bloc.close();
  });

  /// ───── INITIAL STATE ─────
  test('initial state is ActivityInitial', () {
    expect(bloc.state, isA<ActivityInitial>());
  });

  /// ───── LOAD ACTIVITIES ─────
  group('LoadActivitiesEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'emits [ActivityLoading, ActivityLoaded] when loading succeeds',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadActivitiesEvent(TimePeriod.day)),
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>().having(
          (state) => state.activities.length,
          'activities count',
          2,
        ),
      ],
      verify: (_) {
        verify(() => mockGetActivities(any())).called(1);
        verify(() => mockGetTodayStats(any())).called(1);
      },
    );

    blocTest<ActivityBloc, ActivityState>(
      'emits [ActivityLoading, ActivityError] when loading fails',
      build: () {
        // Override the default stub for this test
        when(() => mockGetActivities(any())).thenAnswer(
          (_) async => Left(DatabaseFailure('Database error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadActivitiesEvent(TimePeriod.day)),
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityError>().having(
          (state) => state.message,
          'error message',
          'Database error',
        ),
      ],
    );

    blocTest<ActivityBloc, ActivityState>(
      'calculates correct activity breakdown',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadActivitiesEvent(TimePeriod.day)),
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ActivityLoaded;
        expect(state.breakdown.containsKey(ActivityType.walking), true);
        expect(state.breakdown.containsKey(ActivityType.sitting), true);
      },
    );
  });

  /// ───── SWITCH TIME PERIOD ─────
  group('SwitchTimePeriodEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'switches from Day to Week period',
      build: () => bloc,
      act: (bloc) {
        bloc.add(LoadActivitiesEvent(TimePeriod.day));
        bloc.add(SwitchTimePeriodEvent(TimePeriod.week));
      },
      expect: () => [
        isA<ActivityLoading>(), // Initial load
        isA<ActivityLoaded>(), // Loaded Day
        isA<ActivityLoading>(), // Loading Week
        isA<ActivityLoaded>(), // Loaded Week
      ],
      verify: (_) {
        verify(() => mockGetActivities(any())).called(2); // Called twice
      },
    );
  });

  /// ───── START MONITORING ─────
  group('StartMonitoringEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'sets isMonitoring = true and starts sensor',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(LoadActivitiesEvent(TimePeriod.day));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(StartMonitoringEvent());
      },
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>().having(
          (state) => state.isMonitoring,
          'isMonitoring before start',
          false,
        ),
        isA<ActivityLoaded>().having(
          (state) => state.isMonitoring,
          'isMonitoring after start',
          true,
        ),
      ],
      verify: (_) {
        verify(() => mockSensorDataSource.startMonitoring()).called(1);
      },
    );
  });

  /// ───── STOP MONITORING ─────
  group('StopMonitoringEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'sets isMonitoring = false and stops sensor',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(LoadActivitiesEvent(TimePeriod.day));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(StartMonitoringEvent());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(StopMonitoringEvent());
      },
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>(), // isMonitoring = false (initial)
        isA<ActivityLoaded>(), // isMonitoring = true (started)
        isA<ActivityLoaded>(), // isMonitoring = false (stopped)
      ],
      verify: (_) {
        verify(() => mockSensorDataSource.startMonitoring()).called(1);
        verify(() => mockSensorDataSource.stopMonitoring()).called(1);
      },
    );
  });

  /// ───── CLASSIFICATION ─────
  group('ClassifyCurrentActivityEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'updates currentActivity when classification succeeds',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(LoadActivitiesEvent(TimePeriod.day));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(ClassifyCurrentActivityEvent());
        // Give time for classification to complete
        await Future.delayed(const Duration(milliseconds: 100));
      },
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>(),
        isA<ActivityLoaded>(), // currentActivity updated
        isA<ActivityLoading>(), // Refresh triggered
        isA<ActivityLoaded>(), // Refreshed
      ],
      verify: (_) {
        verify(() => mockClassifyCurrentActivity(any())).called(1);
        verify(() => mockSaveActivity(any())).called(1);
      },
    );

    blocTest<ActivityBloc, ActivityState>(
      'continues monitoring when classification fails',
      build: () {
        when(() => mockClassifyCurrentActivity(any())).thenAnswer(
          (_) async => Left(SensorFailure('Sensor error')),
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadActivitiesEvent(TimePeriod.day));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(ClassifyCurrentActivityEvent());
      },
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>(),
        // Should NOT emit error, just continue
      ],
      verify: (_) {
        verify(() => mockClassifyCurrentActivity(any())).called(1);
        verifyNever(() => mockSaveActivity(any()));
      },
    );
  });

  /// ───── REFRESH DATA ─────
  group('RefreshActivityDataEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'reloads activities with current period',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(LoadActivitiesEvent(TimePeriod.week));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(RefreshActivityDataEvent());
      },
      expect: () => [
        isA<ActivityLoading>(), // Initial load
        isA<ActivityLoaded>(), // Loaded Week
        isA<ActivityLoading>(), // Refresh
        isA<ActivityLoaded>(), // Refreshed Week
      ],
    );
  });

  /// ───── TODAY STATS ─────
  group('LoadTodayStatsEvent', () {
    blocTest<ActivityBloc, ActivityState>(
      'updates todayStats in state',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(LoadActivitiesEvent(TimePeriod.day));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(LoadTodayStatsEvent());
      },
      expect: () => [
        isA<ActivityLoading>(),
        isA<ActivityLoaded>(),
        isA<ActivityLoaded>(), // Stats updated
      ],
      verify: (_) {
        verify(() => mockGetTodayStats(any())).called(greaterThan(0));
      },
    );
  });
}