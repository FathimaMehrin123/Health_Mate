import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/theme/app_colors.dart';
import 'package:health_mate/core/theme/app_text_styles.dart';
import 'package:health_mate/core/widgets/buttons/primary_button.dart';
import 'package:health_mate/core/widgets/inputs/custom_dropdown.dart';
import 'package:health_mate/core/widgets/inputs/custom_text_field.dart';
import 'package:health_mate/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:health_mate/features/authentication/presentation/bloc/auth_event.dart';
import 'package:health_mate/features/authentication/presentation/bloc/auth_state.dart';
import 'package:health_mate/injection_container.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using service locator (GetIt) to inject AuthBloc with all its dependencies.
    // Without sl it would look something like:
    // BlocProvider(create: (_) => AuthBloc(AuthRepositoryImpl(AuthRemoteDataSource())))
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: ProfileSetupView(),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

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
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_rounded),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Skip",
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        title: Text('Profile Setup'),
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
            Future.delayed(Duration(milliseconds: 500), () {
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
                  "Create Your Profile",
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Help us personalize your health journey',
                  style: AppTextStyles.secondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Profile Picture
                Center(child: _ProfilePictureUpload(enabled: true)),
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
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (kg)',
                        hint: "70",
                        controller: _weightController,
                        keyboardType: TextInputType.numberWithOptions(
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
                CustomDropdown(
                  selectedValue: _selectedGoal,
                  items: [
                    DropdownItems(
                      label: 'Sedentary',
                      subtitle: "Little to no exercise (<5,000 steps/day)",
                    ),
                    DropdownItems(
                      label: 'Moderately Active',
                      subtitle:
                          'Moderate exercise 3-5 days/week (7,500-10,000 steps)',
                    ),
                    DropdownItems(
                      label: 'Very Active',
                      subtitle:
                          'Hard exercise 6-7 days/week (10,000-12,500 steps)',
                    ),
                    DropdownItems(
                      label: 'Extremely Active',
                      subtitle:
                          'Very hard exercise & physical job (12,500+ steps)',
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
                  isLoading: isLoading,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: isLoading ? null : () => _handleSubmit(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfilePictureUpload extends StatefulWidget {
  final bool enabled;
  const _ProfilePictureUpload({required this.enabled});

  @override
  State<_ProfilePictureUpload> createState() => _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<_ProfilePictureUpload> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  void _pickImage() async {
    if (!widget.enabled) {
      return;
    }
    // Show options: Camera or Gallery
    final source = await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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
                Navigator.pop(context, ImageSource.camera);
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
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image == null) return;
    setState(() {
      _imagePath = image.path;
    });
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
              gradient: _imagePath == null ? AppColors.primaryGradient : null,
              border: Border.all(color: AppColors.border, width: 4),

              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: _imagePath == null
                ? Icon(Icons.person_rounded, size: 60, color: Colors.white)
                : ClipOval(
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: Icon(
                Icons.add_a_photo_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
