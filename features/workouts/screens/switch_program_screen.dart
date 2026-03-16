// lib/features/workouts/screens/switch_program_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/program_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import 'program_detail_screen.dart';

class SwitchProgramScreen extends StatefulWidget {
  const SwitchProgramScreen({super.key});

  @override
  State<SwitchProgramScreen> createState() => _SwitchProgramScreenState();
}

class _SwitchProgramScreenState extends State<SwitchProgramScreen> {
  String _selectedGoal = 'All';
  String _selectedLevel = 'All';
  final List<String> _goals = ['All', 'Fat Loss', 'Muscle', 'Cardio', 'Calisthenics'];
  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrograms();
    });
  }

  Future<void> _loadPrograms() async {
    final programProvider = context.read<ProgramProvider>();
    await programProvider.loadPrograms();
    
    // Get recommendations based on user profile
    final onboardingProvider = context.read<OnboardingProvider>();
    programProvider.getRecommendedPrograms(
      userLevel: onboardingProvider.fitnessLevel?.toLowerCase() ?? 'beginner',
      userGoal: onboardingProvider.fitnessGoal?.toLowerCase() ?? 'strength',
      userEquipment: onboardingProvider.availableEquipment,
      userFrequency: onboardingProvider.workoutFrequency ?? 3,
    );
  }

  Future<void> _switchToProgram(int programId, String programName) async {
    final programProvider = context.read<ProgramProvider>();
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Switch Program?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to switch to $programName?\n\nYour progress in your current program will be saved.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SWITCH', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await programProvider.switchProgram(programId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to $programName!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to workouts hub
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programProvider = context.watch<ProgramProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final programs = programProvider.programs;
    final recommended = programProvider.recommendedPrograms;
    final currentProgress = programProvider.userProgress;
    final currentProgramId = currentProgress != null ? currentProgress['program_id'] : null;

    // Filter programs based on selected filters
    // Filter programs based on selected filters
    final filteredPrograms = programs.where((program) {
  // Handle goals filter with null check
  if (_selectedGoal != 'All') {
    final goals = program['goals'] as List?;
    if (goals == null || !goals.contains(_selectedGoal)) {
      return false;
    }
  }
  
  // Handle level filter with null check
  if (_selectedLevel != 'All') {
    final level = program['level'] as String?;
    if (level == null || level.toLowerCase() != _selectedLevel.toLowerCase()) {
      return false;
    }
  }
  
  return true;
}).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Your Journey',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: programProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommended Section (based on user profile)
                  if (recommended.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.orange.shade900, Colors.pink.shade900],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.stars, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'RECOMMENDED FOR YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Based on your profile:',
                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Goal: ${onboardingProvider.fitnessGoal ?? 'Any'}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Level: ${onboardingProvider.fitnessLevel ?? 'Beginner'}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...recommended.take(2).map((program) {
                            final isCurrent = program['id'] == currentProgramId;
                            return _buildProgramCard(
                              context, 
                              program, 
                              isRecommended: true,
                              isCurrent: isCurrent,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Filter Chips
                  const Text(
                    'FILTER PROGRAMS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Goal filters
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goals.map((goal) {
                      final isSelected = _selectedGoal == goal;
                      return FilterChip(
                        label: Text(goal),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGoal = goal;
                          });
                        },
                        backgroundColor: Colors.grey[900],
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Level filters
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _levels.map((level) {
                      final isSelected = _selectedLevel == level;
                      return FilterChip(
                        label: Text(level),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedLevel = level;
                          });
                        },
                        backgroundColor: Colors.grey[900],
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Results count
                  Text(
                    '${filteredPrograms.length} programs available',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),

                  // Program list
                  ...filteredPrograms.map((program) {
                    final isCurrent = program['id'] == currentProgramId;
                    return _buildProgramCard(context, program, isCurrent: isCurrent);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildProgramCard(
    BuildContext context,
    Map<String, dynamic> program, {
    bool isRecommended = false,
    bool isCurrent = false,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        if (isCurrent) {
          // If it's the current program, just go to detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgramDetailScreen(programId: program['id']),
            ),
          );
        } else {
          // If it's a different program, show switch option
          _switchToProgram(program['id'], program['name']);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isRecommended
              ? LinearGradient(
                  colors: [Colors.orange.shade900.withOpacity(0.3), Colors.pink.shade900.withOpacity(0.3)],
                )
              : null,
          color: isRecommended ? null : (isCurrent ? Colors.blue.withOpacity(0.1) : theme.cardColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? Colors.blue
                : isRecommended
                    ? Colors.orange.withOpacity(0.5)
                    : theme.dividerColor,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(program['category']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryEmoji(program['category']),
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              program['name'],
                              style: TextStyle(
                                color: isCurrent ? Colors.blue : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'BEST MATCH',
                                style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'CURRENT',
                                style: TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${program['level']?.toString().toUpperCase()} • ${program['duration_weeks']} weeks',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program['description'] ?? 'No description',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Equipment tags
                      if (program['equipment_needed'] != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (program['equipment_needed'] as List).take(3).map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(color: Colors.grey[400], fontSize: 8),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  isCurrent ? Icons.check_circle : Icons.arrow_forward_ios,
                  color: isCurrent ? Colors.blue : Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'calisthenics':
        return Colors.blue;
      case 'powerlifting':
        return Colors.red;
      case 'yoga':
        return Colors.green;
      case 'hiit':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case 'calisthenics':
        return '🤸';
      case 'powerlifting':
        return '🏋️';
      case 'yoga':
        return '🧘';
      case 'hiit':
        return '⚡';
      default:
        return '💪';
    }
  }
}