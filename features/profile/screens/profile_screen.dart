// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../health/providers/health_provider.dart';
import '/core/providers/settings_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  // REAL DATA GETTERS - from HealthProvider
  String get _totalTime {
    final healthProvider = context.read<HealthProvider>();
    final totalMinutes = healthProvider.totalMinutes;
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = (totalMinutes / 60).floor();
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get _caloriesBurned {
    final healthProvider = context.read<HealthProvider>();
    final totalCalories = healthProvider.workoutLogs.fold<int>(0, (sum, log) => 
        sum + (log['calories_burned'] as int? ?? 0));
    if (totalCalories >= 1000) {
      return '${(totalCalories / 1000).toStringAsFixed(1)}k';
    }
    return '$totalCalories';
  }

  String get _workoutsDone => '${context.read<HealthProvider>().totalWorkouts}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Load user data from database
      context.read<OnboardingProvider>().loadUserData(context);
      context.read<AchievementProvider>().loadAchievements();
      context.read<HealthProvider>().loadHealthData();
    });
  }

  void _editGender(String currentValue) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          'Edit Gender',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEditOption('Male', currentValue == 'male'),
            const SizedBox(height: 8),
            _buildEditOption('Female', currentValue == 'female'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditOption(String option, bool isSelected) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        context.read<OnboardingProvider>().setGender(option.toLowerCase());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gender updated'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor.withOpacity(0.2) 
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.primaryColor 
                : theme.dividerColor,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected 
                ? theme.primaryColor 
                : theme.textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _editNumberField(String title, int? currentValue, Function(int) onSave) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentValue?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Edit $title', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Enter $title',
            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(int.parse(controller.text));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title updated'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('SAVE', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _editTextField(String title, String? currentValue, Function(String) onSave) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentValue ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Edit $title', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Enter $title',
            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title updated'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('SAVE', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _editSelectionField(String title, String? currentValue, List<String> options, Function(String) onSave) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Edit $title', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == currentValue;
              return GestureDetector(
                onTap: () {
                  onSave(option);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title updated'), backgroundColor: Colors.green),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.2) : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.blue : theme.dividerColor),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final achievementProvider = context.watch<AchievementProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
    final userName = onboardingProvider.name ?? 
                    authProvider.userEmail?.split('@')[0] ?? 
                    'User';
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.blue),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      // ✅ Added RefreshIndicator for manual refresh
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OnboardingProvider>().loadUserData(context);
          await context.read<AchievementProvider>().loadAchievements();
          await context.read<HealthProvider>().loadHealthData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile Header with Avatar
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isEditing ? () {} : null,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade800, Colors.purple.shade800],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade400, width: 3),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  userName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_isEditing)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isEditing)
                        GestureDetector(
                          onTap: () => _editTextField('Name', onboardingProvider.name, 
                            (value) => context.read<OnboardingProvider>().setName(value)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userName, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, color: Colors.blue, size: 20),
                            ],
                          ),
                        )
                      else
                        Text(userName, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(
                        authProvider.userEmail ?? 'No email',
                        style: TextStyle(color: secondaryTextColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Workout Stats Row
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, Icons.timer, _totalTime, 'Total time', Colors.orange),
                      Container(height: 40, width: 1, color: theme.dividerColor),
                      _buildStatItem(context, Icons.local_fire_department, _caloriesBurned, 'Burned', Colors.red),
                      Container(height: 40, width: 1, color: theme.dividerColor),
                      _buildStatItem(context, Icons.fitness_center, _workoutsDone, 'Done', Colors.green),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Achievement Summary Card
                GestureDetector(
                  onTap: () {
                    context.read<AchievementProvider>().loadAchievements();
                    Navigator.pushNamed(context, '/achievements');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACHIEVEMENTS',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${achievementProvider.userAchievements.length} Unlocked',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${achievementProvider.totalPoints} pts',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Cards Row (Age/Weight/Height)
                Row(
                  children: [
                    _buildEditableStatCard(context,
                      label: 'Age',
                      value: onboardingProvider.age?.toString() ?? '-',
                      icon: Icons.cake,
                      color: Colors.orange,
                      onTap: _isEditing ? () {
                        _editNumberField('Age', onboardingProvider.age, 
                          (value) => context.read<OnboardingProvider>().setAge(value));
                      } : null,
                    ),
                    const SizedBox(width: 12),
                    _buildEditableStatCard(context,
                      label: 'Weight',
                      value: onboardingProvider.weight != null 
                          ? settingsProvider.formatWeight(onboardingProvider.weight!) 
                          : '-',
                      icon: Icons.monitor_weight,
                      color: Colors.green,
                      onTap: _isEditing ? () {
                        _editNumberField('Weight', onboardingProvider.weight?.toInt(), (value) {
                          context.read<OnboardingProvider>().setWeight(value.toDouble());
                        });
                      } : null,
                    ),
                    const SizedBox(width: 12),
                    _buildEditableStatCard(context,
                      label: 'Height',
                      value: onboardingProvider.height != null 
                          ? settingsProvider.formatHeight(onboardingProvider.height!) 
                          : '-',
                      icon: Icons.height,
                      color: Colors.blue,
                      onTap: _isEditing ? () {
                        _editNumberField('Height', onboardingProvider.height, 
                          (value) => context.read<OnboardingProvider>().setHeight(value));
                      } : null,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Personal Information Section
                _buildSectionTitle(context, 'Personal Information'),
                const SizedBox(height: 12),
                _buildEditableInfoCard(context,
                  icon: Icons.person_outline,
                  label: 'Gender',
                  value: onboardingProvider.gender != null 
                      ? onboardingProvider.gender![0].toUpperCase() + onboardingProvider.gender!.substring(1) : 'Not set',
                  color: Colors.purple,
                  onTap: _isEditing ? () => _editGender(onboardingProvider.gender ?? '') : null,
                ),
                _buildEditableInfoCard(context,
                  icon: Icons.fitness_center,
                  label: 'Fitness Level',
                  value: onboardingProvider.fitnessLevel ?? 'Not set',
                  color: Colors.green,
                  onTap: _isEditing ? () {
                    _editSelectionField('Fitness Level', onboardingProvider.fitnessLevel,
                      ['Beginner (no experience)', 'Beginner (some experience)', 'Intermediate',
                       'Upper-intermediate', 'Advanced', 'Athlete level', 'Returning after a long break'],
                      (value) => context.read<OnboardingProvider>().setFitnessLevel(value));
                  } : null,
                ),
                _buildEditableInfoCard(context,
                  icon: Icons.flag,
                  label: 'Primary Goal',
                  value: onboardingProvider.fitnessGoal ?? 'Not set',
                  color: Colors.orange,
                  onTap: _isEditing ? () {
                    _editSelectionField('Primary Goal', onboardingProvider.fitnessGoal,
                      ['Lose weight', 'Build muscle', 'Increase strength', 'Improve endurance',
                       'Stay healthy', 'Rehab / injury recovery', 'Prepare for competition'],
                      (value) => context.read<OnboardingProvider>().setFitnessGoal(value));
                  } : null,
                ),
                
                const SizedBox(height: 16),
                
                // Workout Preferences Section
                _buildSectionTitle(context, 'Workout Preferences'),
                const SizedBox(height: 12),
                _buildEditableInfoCard(context,
                  icon: Icons.calendar_today,
                  label: 'Workout Frequency',
                  value: onboardingProvider.workoutFrequency != null 
                      ? '${onboardingProvider.workoutFrequency} days/week' : 'Not set',
                  color: Colors.blue,
                  onTap: _isEditing ? () {
                    _editNumberField('Workout Frequency', onboardingProvider.workoutFrequency, 
                      (value) => context.read<OnboardingProvider>().setWorkoutFrequency(value));
                  } : null,
                ),
                _buildEditableInfoCard(context,
                  icon: Icons.timer,
                  label: 'Workout Duration',
                  value: onboardingProvider.workoutDuration ?? 'Not set',
                  color: Colors.orange,
                  onTap: _isEditing ? () {
                    _editSelectionField('Workout Duration', onboardingProvider.workoutDuration,
                      ['Less than 20 minutes', '20–30 minutes', '30–45 minutes', '45–60 minutes',
                       '60–75 minutes', '75–90 minutes', 'More than 90 minutes'],
                      (value) => context.read<OnboardingProvider>().setWorkoutDuration(value));
                  } : null,
                ),
                _buildEditableInfoCard(context,
                  icon: Icons.favorite,
                  label: 'Preferred Workout',
                  value: onboardingProvider.workoutPreference ?? 'Not set',
                  color: Colors.red,
                  onTap: _isEditing ? () {
                    _editSelectionField('Preferred Workout', onboardingProvider.workoutPreference,
                      ['Weight training', 'Cardio', 'HIIT', 'Bodyweight exercises',
                       'Cross-training', 'Yoga / stretching', 'Mixed workouts'],
                      (value) => context.read<OnboardingProvider>().setWorkoutPreference(value));
                  } : null,
                ),
                _buildEditableInfoCard(context,
                  icon: Icons.location_on,
                  label: 'Workout Location',
                  value: onboardingProvider.workoutLocation ?? 'Not set',
                  color: Colors.teal,
                  onTap: _isEditing ? () {
                    _editSelectionField('Workout Location', onboardingProvider.workoutLocation,
                      ['Commercial gym', 'Home gym', 'Outdoors', 'Fitness studio',
                       'Hotel / travel gym', 'University / school gym', 'Multiple locations'],
                      (value) => context.read<OnboardingProvider>().setWorkoutLocation(value));
                  } : null,
                ),
                
                const SizedBox(height: 16),
                
                // Equipment Section
                _buildSectionTitle(context, 'Available Equipment'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: onboardingProvider.availableEquipment.isNotEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: onboardingProvider.availableEquipment.map((equipment) {
                            return GestureDetector(
                              onTap: _isEditing ? () {
                                final newList = List<String>.from(onboardingProvider.availableEquipment)..remove(equipment);
                                context.read<OnboardingProvider>().setEquipment(newList);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed $equipment'), backgroundColor: Colors.orange),
                                );
                              } : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isEditing ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _isEditing ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(equipment, style: TextStyle(color: _isEditing ? Colors.red : Colors.blue, fontSize: 12)),
                                    if (_isEditing) const SizedBox(width: 4),
                                    if (_isEditing) const Icon(Icons.close, color: Colors.red, size: 12),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : Center(
                          child: Text(
                            _isEditing ? 'Tap + to add equipment' : 'No equipment selected',
                            style: TextStyle(color: secondaryTextColor, fontStyle: FontStyle.italic),
                          ),
                        ),
                ),
                
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        _editSelectionField('Add Equipment', '',
                          ['No equipment', 'Dumbbells only', 'Barbell & plates', 'Machines',
                           'Resistance bands', 'Full gym access', 'Limited / mixed equipment'],
                          (value) {
                            final currentList = List<String>.from(onboardingProvider.availableEquipment);
                            if (!currentList.contains(value)) {
                              currentList.add(value);
                              context.read<OnboardingProvider>().setEquipment(currentList);
                            }
                          },
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text('ADD EQUIPMENT', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Achievements Button
                Container(
                  width: double.infinity,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AchievementProvider>().loadAchievements();
                      Navigator.pushNamed(context, '/achievements');
                    },
                    icon: const Icon(Icons.emoji_events, color: Colors.amber),
                    label: const Text(
                      'VIEW ACHIEVEMENTS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      foregroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                
                // Logout Button
                Container(
                  width: double.infinity,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900.withOpacity(0.3),
                      foregroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade400.withOpacity(0.5)),
                      ),
                    ),
                    child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEditableStatCard(BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: onTap != null ? color.withOpacity(0.5) : theme.dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12)),
                  if (onTap != null) const SizedBox(width: 4),
                  if (onTap != null) const Icon(Icons.edit, color: Colors.blue, size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onTap != null ? color.withOpacity(0.5) : theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12)),
                  Text(value, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.edit, color: theme.textTheme.bodyMedium?.color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut(context);
              Navigator.pop(ctx);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}