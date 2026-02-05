import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/theme/app_colors.dart';
import 'package:health_mate/core/theme/app_text_styles.dart';
import 'package:health_mate/core/widgets/buttons/primary_button.dart';
import 'package:health_mate/core/widgets/cards/timeline_item.dart';
import 'package:health_mate/core/widgets/common/section_header.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';

import 'dart:core';

import 'package:health_mate/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_event.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_state.dart';
import 'package:health_mate/features/activity/presentation/widgets/activity_breakdown_chart.dart';
import 'package:health_mate/features/activity/presentation/widgets/current_status_card.dart';
import 'package:health_mate/features/activity/presentation/widgets/time_period_selector.dart';
import 'package:health_mate/injection_container.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ActivityBloc>()
        ..add(LoadActivitiesEvent(TimePeriod.day))
        ..add(LoadTodayStatsEvent()),
      child: const ActivityView(),
    );
  }
}

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  bool _isMonitoring = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ActivityBloc, ActivityState>(
        listener: (context, state) {
          if (state is ActivityLoaded) {
            setState(() {
              _isMonitoring = state.isMonitoring; 
            });
          }

          if (state is ActivityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ActivityLoading) {
            return _buildLoadingState();
          }

          if (state is ActivityLoaded) {
            return _buildLoadedState(context, state);
          }

          if (state is ActivityError) {
            return _buildErrorState(context, state);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Activity', style: AppTextStyles.heading),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
    );
  }

  // ─── OPTIONS MENU ─────────────────────────────────────────────

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Export option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upload_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Export Data', style: AppTextStyles.body),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to export screen
                },
              ),

              // Settings option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Activity Settings',
                  style: AppTextStyles.body,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),

              // Help option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Help', style: AppTextStyles.body),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show help
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ─── LOADING STATE ────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('Loading activities...', style: AppTextStyles.secondary),
        ],
      ),
    );
  }

  // ─── ERROR STATE ──────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context, ActivityError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.heading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.secondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: () {
                context.read<ActivityBloc>().add(
                  LoadActivitiesEvent(TimePeriod.day),
                );
              },
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOADED STATE ─────────────────────────────────────────────

  Widget _buildLoadedState(BuildContext context, ActivityLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ActivityBloc>().add(RefreshActivityDataEvent());
        // Small delay so the refresh indicator shows
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Current Status Card ──
          CurrentStatusCard(
            activity: state.currentActivity,
            isMonitoring: state.isMonitoring,
          ),
          const SizedBox(height: 16),

          // ── Start/Stop Monitoring Button ──
          PrimaryButton(
            text: state.isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
            icon: state.isMonitoring
                ? Icons.stop_circle_outlined
                : Icons.play_circle_outline,
            onPressed: () {
              if (state.isMonitoring) {
                context.read<ActivityBloc>().add(StopMonitoringEvent());
              } else {
                context.read<ActivityBloc>().add(StartMonitoringEvent());
              }
            },
            backgroundColor: state.isMonitoring
                ? AppColors.error
                : AppColors.success,
          ),
          const SizedBox(height: 24),

          // ── Today's Stats Row ──
          if (state.todayStats != null) ...[
            _buildTodayStatsRow(state.todayStats!),
            const SizedBox(height: 24),
          ],

          // ── Time Period Selector ──
          SectionHeader(title: 'Activity Overview'),
          const SizedBox(height: 12),
          TimePeriodSelector(
            selectedPeriod: state.currentPeriod,
            onPeriodChanged: (period) {
              context.read<ActivityBloc>().add(SwitchTimePeriodEvent(period));
            },
          ),
          const SizedBox(height: 24),

          // ── Activity Breakdown Chart ──
          SectionHeader(title: 'Breakdown'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ActivityBreakdownChart(breakdown: state.breakdown),
          ),
          const SizedBox(height: 24),

          // ── Activity History ──
          SectionHeader(
            title: 'Activity History',
            actionText: 'View All',
            actionIcon: Icons.arrow_forward_ios,
            onActionTap: () {
              // TODO: Navigate to full activity history
            },
          ),
          const SizedBox(height: 12),
          _buildActivityHistory(context, state.activities),
        ],
      ),
    );
  }

  // ─── TODAY'S STATS ────────────────────────────────────────────

  Widget _buildTodayStatsRow(Map<String, dynamic> stats) {
    final totalSteps = stats['totalSteps'] as int;
    final totalCalories = stats['totalCalories'] as double;
    final totalDuration = stats['totalDuration'] as int;

    // Convert duration to hours and minutes
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.directions_walk,
            value: '$totalSteps',
            label: 'Steps',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            icon: Icons.local_fire_department,
            value: totalCalories.toStringAsFixed(0),
            label: 'Calories',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            icon: Icons.access_time_rounded,
            value: durationText,
            label: 'Duration',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  // ─── STAT ITEM ────────────────────────────────────────────────

  Widget _StatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }

  // ─── ACTIVITY HISTORY ─────────────────────────────────────────

  Widget _buildActivityHistory(
    BuildContext context,
    List<Activity> activities,
  ) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.timeline,
                color: AppColors.textDisabled,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'No activities recorded yet',
                style: AppTextStyles.secondary,
              ),
            ],
          ),
        ),
      );
    }

    // Show only latest 10 activities
    final visibleActivities = activities.take(10).toList();

    return Column(
      children: visibleActivities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        final isLast = index == visibleActivities.length - 1;

        // Format time
        final time = DateFormat('HH:mm').format(activity.timestamp);

        // Build subtitle
        final subtitleParts = <String>[];
        final durationMin = activity.duration ~/ 60;
        subtitleParts.add('${durationMin}m');
        if (activity.steps != null) {
          subtitleParts.add('${activity.steps} steps');
        }
        if (activity.calories != null) {
          subtitleParts.add('${activity.calories!.toStringAsFixed(0)} cal');
        }
        final subtitle = subtitleParts.join(' • ');

        return TimelineItem(
          time: time,
          title: activity.type.displayName,
          subtitle: subtitle,
          emoji: activity.type.emoji,
          isLast: isLast,
          onTap: () => _showActivityDetails(context, activity),
        );
      }).toList(),
    );
  }

  // ─── ACTIVITY DETAILS MODAL ───────────────────────────────────

  void _showActivityDetails(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          activity.type.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.type.displayName,
                          style: AppTextStyles.heading,
                        ),
                        Text(
                          'Confidence: ${(activity.confidence * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Details grid
                Row(
                  children: [
                    if (activity.steps != null)
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.directions_walk,
                          label: 'Steps',
                          value: '${activity.steps}',
                          color: AppColors.primary,
                        ),
                      ),
                    if (activity.calories != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.local_fire_department,
                          label: 'Calories',
                          value: activity.calories!.toStringAsFixed(0),
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailItem(
                        icon: Icons.access_time_rounded,
                        label: 'Duration',
                        value: '${activity.duration ~/ 60}m',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Time info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),

                      Text(
                        '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year} '
                        'at ${DateFormat('HH:mm').format(activity.timestamp)}',

                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Close button
                PrimaryButton(
                  text: 'Close',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: AppColors.surface,
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── DETAIL ITEM WIDGET ─────────────────────────────────────────

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(fontSize: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label.copyWith(color: color)),
        ],
      ),
    );
  }
}
