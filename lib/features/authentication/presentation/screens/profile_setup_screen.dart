import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../../../../core/widgets/inputs/custom_dropdown.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const ProfileSetupView(),
    );
  }
}

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedGoal = 'Moderately Active';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            CreateUserEvent(
              name: _nameController.text.trim(),
              age: int.parse(_ageController.text),
              height: double.parse(_heightController.text),
              weight: double.parse(_weightController.text),
              activityGoal: _selectedGoal,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile Setup'),
        actions: [
          TextButton(
            onPressed: () {
              // Skip to dashboard with default values
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
            child: Text(
              'Skip',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UserCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile created successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            // Navigate to dashboard
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            });
          } else if (state is AuthError) {
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
          final isLoading = state is AuthLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Header
                Text(
                  'Create Your Profile',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us personalize your health journey',
                  style: AppTextStyles.secondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Profile Picture
                Center(
                  child: _ProfilePictureUpload(
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(height: 40),

                // Name Field
                CustomTextField(
                  label: 'Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.name,
                  prefix: const Icon(Icons.person_outline_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Age Field
                CustomTextField(
                  label: 'Age',
                  hint: 'Enter your age',
                  controller: _ageController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.cake_outlined),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Please enter a valid age';
                    }
                    if (age < 13 || age > 120) {
                      return 'Age must be between 13 and 120';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Height and Weight Row
                Row(
                  children: [
                    // Height Field
                    Expanded(
                      child: CustomTextField(
                        label: 'Height (cm)',
                        hint: '170',
                        controller: _heightController,
                        enabled: !isLoading,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefix: const Icon(Icons.height_rounded),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,1}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final height = double.tryParse(value);
                          if (height == null) {
                            return 'Invalid';
                          }
                          if (height < 50 || height > 300) {
                            return '50-300cm';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Weight Field
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (kg)',
                        hint: '70',
                        controller: _weightController,
                        enabled: !isLoading,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefix: const Icon(Icons.monitor_weight_outlined),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,1}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null) {
                            return 'Invalid';
                          }
                          if (weight < 20 || weight > 500) {
                            return '20-500kg';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Activity Goal Dropdown
                CustomDropdown<String>(
                  label: 'Activity Goal',
                  value: _selectedGoal,
                  items: [
                    DropdownItem(
                      value: 'Sedentary',
                      label: 'Sedentary',
                      subtitle: 'Little to no exercise (<5,000 steps/day)',
                    ),
                    DropdownItem(
                      value: 'Light Active',
                      label: 'Light Active',
                      subtitle: 'Light exercise 1-3 days/week (5,000-7,500 steps)',
                    ),
                    DropdownItem(
                      value: 'Moderately Active',
                      label: 'Moderately Active',
                      subtitle: 'Moderate exercise 3-5 days/week (7,500-10,000 steps)',
                    ),
                    DropdownItem(
                      value: 'Very Active',
                      label: 'Very Active',
                      subtitle: 'Hard exercise 6-7 days/week (10,000-12,500 steps)',
                    ),
                    DropdownItem(
                      value: 'Extremely Active',
                      label: 'Extremely Active',
                      subtitle: 'Very hard exercise & physical job (12,500+ steps)',
                    ),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGoal = value;
                            });
                          }
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your activity goal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                PrimaryButton(
                  text: 'Save & Continue',
                  onPressed: isLoading ? null : () => _handleSubmit(context),
                  isLoading: isLoading,
                  icon: Icons.arrow_forward_rounded,
                ),
                const SizedBox(height: 24),

                // Privacy Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your data is stored locally on your device and never shared.',
                          style: AppTextStyles.secondary.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Profile Picture Upload Widget
class _ProfilePictureUpload extends StatefulWidget {
  final bool enabled;

  const _ProfilePictureUpload({
    required this.enabled,
  });

  @override
  State<_ProfilePictureUpload> createState() => _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<_ProfilePictureUpload> {
  String? _imagePath;

  void _pickImage() async {
    if (!widget.enabled) return;

    // Show options: Camera or Gallery
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context, 'camera');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context, 'gallery');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (result != null) {
      // TODO: Implement image picker
      // For now, just show a placeholder
      setState(() {
        _imagePath = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: $result'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _imagePath == null
                  ? AppColors.primaryGradient
                  : null,
              color: _imagePath != null ? AppColors.surface : null,
              border: Border.all(
                color: AppColors.border,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _imagePath == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: Colors.white,
                  )
                : ClipOval(
                    child: Image.asset(
                      'assets/images/default_avatar.png', // Placeholder
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: AppColors.textSecondary,
                        );
                      },
                    ),
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          if (!widget.enabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}