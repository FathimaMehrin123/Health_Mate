import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/app_colors.dart';
import 'package:health_mate/core/theme/app_text_styles.dart';
import 'package:health_mate/core/widgets/cards/stat_card.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("EEEE,MMM d,yyyy").format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, color: AppColors.textPrimary, size: 24),
        ),
        title: Text("Dashboard", style: AppTextStyles.heading),
        actions: [Icon(Icons.notifications), Icon(Icons.settings)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Good Morning, User ! 👋",
            style: AppTextStyles.heading.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(date,style: AppTextStyles.secondary),

       Container(
        padding: EdgeInsets.all(26),
        
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        //  color: AppColors.primaryGradient,
        //  boxShadow: BoxShadow()
        ),
       ),
      Text('Quick Stats',style: AppTextStyles.sectionTitle),
      Row(children: [
       StatCard(icon: "",value: "8.5k" ,label: "Steps"),StatCard(icon: "",value: "7h",label: "Sleep"),StatCard(icon: "",value: "4h",label: "Sit ")
      ],),
      Text("Recent Activity",style: AppTextStyles.sectionTitle),
      Text("Achievements:",style: AppTextStyles.sectionTitle)
        ],
      ),
    );
  }
}
