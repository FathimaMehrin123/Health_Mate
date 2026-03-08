import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/widgets/buttons/icon_button_custom.dart';
import 'package:health_mate/core/widgets/buttons/primary_button.dart';
import 'package:health_mate/core/widgets/cards/alert_banner.dart';
import 'package:health_mate/core/widgets/cards/stat_card.dart';
import 'package:health_mate/core/widgets/common/loading_indicator.dart';
import 'package:health_mate/core/widgets/common/section_header.dart';
import 'package:health_mate/core/widgets/indicators/health_score_ring.dart';
import 'package:health_mate/features/sleep/domain/entities/sleep_record.dart';
import 'package:health_mate/features/sleep/presentation/bloc/sleep_bloc.dart';
import 'package:health_mate/features/sleep/presentation/bloc/sleep_event.dart';
import 'package:health_mate/features/sleep/presentation/bloc/sleep_state.dart';


class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  late SleepBloc _sleepBloc;
  SleepRecord? _lastNightRecord;
  double _dailyScore = 0.0;

  @override
  void initState() {
    super.initState();
    _sleepBloc = context.read<SleepBloc>();
    _loadSleepData();
  }

  void _loadSleepData() {
    _sleepBloc.add(const GetLastNightSleepEvent());
    _sleepBloc.add(const GetDailyPostureScoreEvent());
    _sleepBloc.add(const GetWeeklyAverageEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButtonCustom(
          icon: Icons.arrow_back_ios_new_rounded,
          color: const Color(0xFF2C3E50),
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sleep',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        actions: [
          IconButtonCustom(
            icon: Icons.more_vert,
            color: const Color(0xFF2C3E50),
            onTap: _showOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadSleepData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocListener<SleepBloc, SleepState>(
          listener: (context, state) {
            if (state is LastNightSleepLoaded) {
              setState(() => _lastNightRecord = state.record);
            }
            if (state is DailyPostureScoreLoaded) {
              setState(() => _dailyScore = state.score);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== Last Night Section =====
              SectionHeader(
                title: 'Last Night',
              ),
              const SizedBox(height: 12),
              BlocBuilder<SleepBloc, SleepState>(
                builder: (context, state) {
                  if (state is SleepLoading) {
                    return SizedBox(
                      height: 200,
                      child: LoadingIndicator(),
                    );
                  } else if (state is LastNightSleepLoaded && state.record != null) {
                    return _buildLastNightCard(state.record);
                  } else if (_lastNightRecord != null) {
                    return _buildLastNightCard(_lastNightRecord);
                  } else {
                    return AlertBanner(
                      message: 'No sleep data available',
                      type: AlertType.info,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // ===== Daily Score Section =====
              SectionHeader(
                title: 'Today\'s Sleep Score',
              ),
              const SizedBox(height: 12),
              Center(
                child: HealthScoreRing(
                  score: _dailyScore.toInt(),
                  label: 'Sleep Quality',
                  size: 140,
                ),
              ),
              const SizedBox(height: 24),

              // ===== Sleep Phases Section =====
              if (_lastNightRecord != null) ...[
                SectionHeader(
                  title: 'Sleep Phases',
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: '💤',
                  value: '150m',
                  label: 'Deep Sleep',
                  progress: 0.31,
                  onTap: () => _showPhaseDetail('Deep Sleep', 31),
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: '😴',
                  value: '255m',
                  label: 'Light Sleep',
                  progress: 0.53,
                  onTap: () => _showPhaseDetail('Light Sleep', 53),
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: '💭',
                  value: '135m',
                  label: 'REM Sleep',
                  progress: 0.28,
                  onTap: () => _showPhaseDetail('REM Sleep', 28),
                ),
                const SizedBox(height: 24),
              ],

              // ===== Weekly Average Section =====
              SectionHeader(
                title: 'Weekly Average',
                actionText: 'View All',
                onActionTap: () => _showWeeklyDetails(),
              ),
              const SizedBox(height: 12),
              BlocBuilder<SleepBloc, SleepState>(
                builder: (context, state) {
                  if (state is WeeklyAverageLoaded) {
                    return _buildWeeklyChart();
                  } else {
                    return SizedBox(
                      height: 150,
                      child: LoadingIndicator(),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // ===== Action Buttons =====
              PrimaryButton(
                text: '📊 Sleep Report',
                onPressed: _showSleepReport,
                backgroundColor: const Color(0xFF6B73FF),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: '🎯 Set Sleep Goal',
                onPressed: _showSetSleepGoal,
                backgroundColor: const Color(0xFF4ECDC4),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastNightCard(SleepRecord? record) {
    if (record == null) {
      return AlertBanner(
        message: 'No sleep data recorded',
        type: AlertType.info,
      );
    }

    return GestureDetector(
      onTap: () => _showScoreBreakdown(record),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6B73FF).withOpacity(0.1),
              const Color(0xFF6B73FF).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF6B73FF).withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            HealthScoreRing(
              score: record.qualityScore.toInt(),
              label: 'Quality Score',
              size: 120,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '🌙',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '10:30 PM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bedtime',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '☀️',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6:30 AM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wake time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '⏱️',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '8h 0m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Duration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final hours = 7.0 + (index * 0.5 % 2);
              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 30,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[200],
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 30,
                          height: 80 * (hours / 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFF6B73FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hours.toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('Export Sleep Data'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep data exported')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Sleep Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening sleep settings')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showScoreBreakdown(SleepRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Score Breakdown'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HealthScoreRing(
                score: record.qualityScore.toInt(),
                size: 100,
              ),
              const SizedBox(height: 20),
              AlertBanner(
                message: 'Great sleep quality!',
                subtitle: 'You had a balanced sleep cycle',
                type: AlertType.success,
              ),
            ],
          ),
        ),
        actions: [
          PrimaryButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showPhaseDetail(String phase, int percentage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$phase Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HealthScoreRing(
              score: percentage,
              label: 'Percentage',
              size: 100,
            ),
            const SizedBox(height: 16),
            AlertBanner(
              message: '$phase is important for health',
              type: AlertType.info,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'Got It',
            onPressed: () => Navigator.pop(context),
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showSleepReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              _reportRow('Average Sleep:', '7h 20m'),
              _reportRow('Best Night:', 'Jan 11 (9h)'),
              _reportRow('Worst Night:', 'Jan 3 (5h)'),
              const SizedBox(height: 16),
              AlertBanner(
                message: 'Excellent consistency!',
                subtitle: 'You\'re maintaining a regular sleep schedule',
                type: AlertType.success,
              ),
            ],
          ),
        ),
        actions: [
          PrimaryButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetSleepGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Sleep Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many hours do you want to sleep?'),
            const SizedBox(height: 20),
            Slider(
              value: 8,
              min: 6,
              max: 10,
              divisions: 8,
              label: '8h',
              activeColor: const Color(0xFF6B73FF),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Text(
              'Target: 8 hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'Set Goal',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sleep goal set to 8 hours')),
              );
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showWeeklyDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viewing detailed weekly sleep data'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Tracking Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use Sleep Tracking:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Text('1. Start tracking before bed', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('2. Keep your phone nearby', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('3. Stop tracking after waking up', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            AlertBanner(
              message: 'Better sleep = Better health',
              type: AlertType.info,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'Got It',
            onPressed: () => Navigator.pop(context),
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}