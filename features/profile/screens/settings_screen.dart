// lib/features/profile/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/l10n/app_localizations.dart'; // ✅ import
import '../../auth/providers/auth_provider.dart';
import '/core/providers/theme_provider.dart';
import '/core/providers/settings_provider.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // ✅ shortcut
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
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
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
        ),
        title: Text(
          t.settings, // ✅
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Info Header (no translation needed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade800, Colors.purple.shade800],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          authProvider.userEmail?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.userEmail?.split('@')[0] ?? 'User',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authProvider.userEmail ?? 'No email',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionTitle(context, t.appearance.toUpperCase()), // ✅
              const SizedBox(height: 8),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSwitchTile(
                    context,
                    icon: Icons.dark_mode,
                    iconColor: Colors.purple,
                    title: t.darkMode, // ✅
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Units Section
              _buildSectionTitle(context, t.units.toUpperCase()), // ✅
              const SizedBox(height: 8),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        // Weight Unit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.monitor_weight, color: Colors.green, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  t.weight, // ✅
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildUnitChip(
                                  context, 
                                  t.kg, // ✅
                                  settingsProvider.weightUnit == 'kg', 
                                  () => settingsProvider.setWeightUnit('kg')
                                ),
                                const SizedBox(width: 8),
                                _buildUnitChip(
                                  context, 
                                  t.lb, // ✅
                                  settingsProvider.weightUnit == 'lb', 
                                  () => settingsProvider.setWeightUnit('lb')
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        // Height Unit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.height, color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  t.height, // ✅
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildUnitChip(
                                  context, 
                                  t.cm, // ✅
                                  settingsProvider.heightUnit == 'cm', 
                                  () => settingsProvider.setHeightUnit('cm')
                                ),
                                const SizedBox(width: 8),
                                _buildUnitChip(
                                  context, 
                                  t.inches, // ✅ now using "inches"
                                  settingsProvider.heightUnit == 'in', 
                                  () => settingsProvider.setHeightUnit('in')
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

              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionTitle(context, t.notifications.toUpperCase()), // ✅
              const SizedBox(height: 8),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Column(
                    children: [
                      _buildSwitchTile(
                        context,
                        icon: Icons.fitness_center,
                        iconColor: Colors.orange,
                        title: t.workoutReminders, // ✅
                        value: settingsProvider.workoutReminders,
                        onChanged: (value) {
                          settingsProvider.setWorkoutReminders(value);
                        },
                      ),
                      _buildSwitchTile(
                        context,
                        icon: Icons.restaurant,
                        iconColor: Colors.red,
                        title: t.mealReminders, // ✅
                        value: settingsProvider.mealReminders,
                        onChanged: (value) {
                          settingsProvider.setMealReminders(value);
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Language Section
              _buildSectionTitle(context, t.language.toUpperCase()), // ✅
              const SizedBox(height: 8),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: DropdownButton<String>(
                      value: settingsProvider.language,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor, fontSize: 16),
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                        DropdownMenuItem(value: 'French', child: Text('French')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          settingsProvider.setLanguage(value);
                        }
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Privacy Section
              _buildSectionTitle(context, t.privacy.toUpperCase()), // ✅
              const SizedBox(height: 8),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return _buildSwitchTile(
                    context,
                    icon: Icons.share,
                    iconColor: Colors.teal,
                    title: t.dataSharing, // ✅
                    subtitle: t.dataSharingSubtitle, // ✅
                    value: settingsProvider.dataSharing,
                    onChanged: (value) {
                      settingsProvider.setDataSharing(value);
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // About Section
              _buildSectionTitle(context, t.about.toUpperCase()), // ✅
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildAboutTile(
                      context,
                      icon: Icons.info_outline,
                      title: t.version, // ✅
                      value: '1.0.0',
                      isLink: false,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    // Terms of Service (tappable)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsScreen()),
                        );
                      },
                      child: _buildAboutTile(
                        context,
                        icon: Icons.description_outlined,
                        title: t.termsOfService, // ✅
                        value: '',
                        isLink: true,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    // Privacy Policy (tappable)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                        );
                      },
                      child: _buildAboutTile(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: t.privacyPolicy, // ✅
                        value: '',
                        isLink: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Back to Profile Button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 20),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(t.backToProfile), // ✅
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue.withOpacity(0.5),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: theme.dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
          ),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        if (isLink)
          Icon(
            Icons.arrow_forward_ios,
            color: theme.textTheme.bodyMedium?.color,
            size: 14,
          ),
      ],
    );
  }
}