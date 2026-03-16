// lib/features/onboarding/screens/quick_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../widgets/app_button.dart';

class QuickSetupScreen extends StatelessWidget {
  const QuickSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quick Setup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator (first step)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Let\'s get you set up',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose your preferences to get started',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Appearance Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette, color: Colors.purple, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'APPEARANCE',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                title: 'Light',
                                icon: Icons.sunny,
                                isSelected: !themeProvider.isDarkMode,
                                onTap: () {
                                  if (themeProvider.isDarkMode) {
                                    themeProvider.toggleTheme(false);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                title: 'Dark',
                                icon: Icons.nightlight_round,
                                isSelected: themeProvider.isDarkMode,
                                onTap: () {
                                  if (!themeProvider.isDarkMode) {
                                    themeProvider.toggleTheme(true);
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Units Section
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, color: Colors.blue, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'UNITS',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Weight Unit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weight',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                _buildUnitChip(
                                  context,
                                  'kg',
                                  settingsProvider.weightUnit == 'kg',
                                  () => settingsProvider.setWeightUnit('kg'),
                                ),
                                const SizedBox(width: 8),
                                _buildUnitChip(
                                  context,
                                  'lb',
                                  settingsProvider.weightUnit == 'lb',
                                  () => settingsProvider.setWeightUnit('lb'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        
                        // Height Unit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Height',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                _buildUnitChip(
                                  context,
                                  'cm',
                                  settingsProvider.heightUnit == 'cm',
                                  () => settingsProvider.setHeightUnit('cm'),
                                ),
                                const SizedBox(width: 8),
                                _buildUnitChip(
                                  context,
                                  'in',
                                  settingsProvider.heightUnit == 'in',
                                  () => settingsProvider.setHeightUnit('in'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // Continue Button
              AppButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.pushNamed(context, '/name');
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : theme.textTheme.bodyMedium?.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : theme.textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}