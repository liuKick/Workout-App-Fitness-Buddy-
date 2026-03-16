// lib/features/workouts/screens/workouts_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/program_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../health/providers/health_provider.dart';
import 'workout_detail_screen.dart';
import 'program_detail_screen.dart';
import 'filter_screens/level_filter_screen.dart';
import 'filter_screens/goal_filter_screen.dart';
import 'filter_screens/type_filter_screen.dart';

// Gradient constants
final List<List<Color>> cardGradients = [
  [Colors.blue.shade900, Colors.purple.shade900],
  [Colors.green.shade900, Colors.teal.shade900],
  [Colors.orange.shade900, Colors.red.shade900],
  [Colors.indigo.shade900, Colors.pink.shade900],
  [Colors.cyan.shade900, Colors.blue.shade900],
  [Colors.amber.shade900, Colors.deepOrange.shade900],
];

class WorkoutsHubScreen extends StatefulWidget {
  const WorkoutsHubScreen({super.key});

  @override
  State<WorkoutsHubScreen> createState() => _WorkoutsHubScreenState();
}

class _WorkoutsHubScreenState extends State<WorkoutsHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserProgress();
    });
  }

  Future<void> _loadData() async {
    final workoutProvider = context.read<WorkoutProvider>();
    final programProvider = context.read<ProgramProvider>();
    final healthProvider = context.read<HealthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();

    await Future.wait([
      workoutProvider.loadWorkouts(),
      programProvider.loadPrograms(),
      healthProvider.loadHealthData(),
      programProvider.loadUserProgress(),
    ]);

    await programProvider.getRecommendedPrograms(
      userLevel: onboardingProvider.fitnessLevel?.toLowerCase() ?? 'beginner',
      userGoal: onboardingProvider.fitnessGoal?.toLowerCase() ?? 'fat loss',
      userEquipment: onboardingProvider.availableEquipment,
      userFrequency: onboardingProvider.workoutFrequency ?? 3,
    );
    
    if (programProvider.userProgress != null) {
      final programId = programProvider.userProgress!['program_id'];
      if (programProvider.currentProgram == null || 
          programProvider.currentProgram!['id'] != programId) {
        await programProvider.getProgramDetails(programId);
      }
    }
  }

  Future<void> _refreshUserProgress() async {
    final programProvider = context.read<ProgramProvider>();
    final healthProvider = context.read<HealthProvider>();
    
    await Future.wait([
      programProvider.loadUserProgress(),
      healthProvider.loadHealthData(),
    ]);
    
    if (programProvider.userProgress != null && mounted) {
      final programId = programProvider.userProgress!['program_id'];
      await programProvider.getProgramDetails(programId);
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  int _getStreakDays(BuildContext context) {
    return context.watch<HealthProvider>().streakDays;
  }

  int _getWorkoutsThisWeek(BuildContext context) {
    return context.watch<HealthProvider>().workoutsThisWeek;
  }

  double _getProgressToNextLevel(BuildContext context) {
    final workoutsThisWeek = context.watch<HealthProvider>().workoutsThisWeek;
    return (workoutsThisWeek / 5).clamp(0, 1);
  }

  String _getDayLabel(int index, int frequency) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    if (frequency == 3) {
      const threeDayPattern = [0, 2, 4];
      return index < threeDayPattern.length ? days[threeDayPattern[index]] : 'Next';
    } else if (frequency == 4) {
      const fourDayPattern = [0, 1, 3, 4];
      return index < fourDayPattern.length ? days[fourDayPattern[index]] : 'Next';
    } else if (frequency == 5) {
      return index < 5 ? days[index] : 'Next';
    } else if (frequency == 6) {
      return index < 6 ? days[index] : 'Next';
    }
    return index < 7 ? days[index] : 'Day ${index + 1}';
  }

  List<Map<String, dynamic>> _getPersonalizedWorkouts(
    List<Map<String, dynamic>> allWorkouts,
    OnboardingProvider onboarding,
  ) {
    final frequency = onboarding.workoutFrequency ?? 3;
    final goal = onboarding.fitnessGoal?.toLowerCase() ?? '';
    final level = onboarding.fitnessLevel?.toLowerCase() ?? 'beginner';
    final equipment = onboarding.availableEquipment;

    var filtered = allWorkouts.where((w) {
      if (level == 'beginner' && w['level'] != 'Beginner') return false;
      if (level == 'intermediate' && !['Intermediate', 'Beginner'].contains(w['level'])) return false;
      
      final required = List<String>.from(w['equipment_required'] ?? []);
      if (required.isNotEmpty && !required.every((item) => equipment.contains(item))) {
        if (!(required.length == 1 && required.first == 'none')) return false;
      }
      return true;
    }).toList();

    if (goal.contains('fat loss')) {
      filtered.sort((a, b) {
        final aScore = (a['category'] == 'HIIT' || a['title']?.contains('Full Body') == true) ? 1 : 0;
        final bScore = (b['category'] == 'HIIT' || b['title']?.contains('Full Body') == true) ? 1 : 0;
        return bScore.compareTo(aScore);
      });
    } else if (goal.contains('muscle')) {
      filtered.sort((a, b) {
        final aScore = (a['title']?.contains('Upper') == true || a['title']?.contains('Leg') == true) ? 1 : 0;
        final bScore = (b['title']?.contains('Upper') == true || b['title']?.contains('Leg') == true) ? 1 : 0;
        return bScore.compareTo(aScore);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutProvider = context.watch<WorkoutProvider>();
    final programProvider = context.watch<ProgramProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final workouts = workoutProvider.workouts;
    
    final userProgress = programProvider.userProgress;
    final hasActiveProgram = userProgress != null;
    final program = userProgress?['programs'];
    final programProgress = programProvider.getProgramProgress();
    final todaysWorkout = programProvider.getTodaysWorkout();
    
    // Optional: keep one line for debugging if needed, but commented out for now
    // if (hasActiveProgram) {
    //   debugPrint('USER PROGRESS: current_week: ${userProgress!['current_week']}, current_day: ${userProgress['current_day']}');
    // }
    
    List<Map<String, dynamic>> weekSchedule = [];
    if (hasActiveProgram && userProgress != null) {
      final currentWeek = userProgress['current_week'] ?? 1;
      weekSchedule = programProvider.getWeekSchedule(currentWeek);
    }
    
    final isLoading = workoutProvider.isLoading || programProvider.isLoading;

    final personalizedWorkouts = _getPersonalizedWorkouts(workouts, onboardingProvider);
    final frequency = onboardingProvider.workoutFrequency ?? 3;
    final displayCount = frequency < 7 ? frequency + 1 : 7;

    List<Map<String, dynamic>> displayWorkouts = personalizedWorkouts;
    if (displayWorkouts.isEmpty && workouts.isNotEmpty) {
      displayWorkouts = workouts.where((w) => 
        w['level'] == 'Beginner' || w['level'] == 'beginner'
      ).toList();
      if (displayWorkouts.isEmpty) {
        displayWorkouts = workouts.take(5).toList();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshUserProgress,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/LoginScreen2.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Workouts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black45,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_getStreakDays(context)} days',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Text(
                                      '${_getWorkoutsThisWeek(context)} workouts',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.stars, color: Colors.amber, size: 20),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'RECOMMENDED FOR YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  '${frequency}x/week',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: displayCount,
                          itemBuilder: (context, index) {
                            if (index < displayWorkouts.length && index < frequency) {
                              final workout = displayWorkouts[index];
                              final dayLabel = _getDayLabel(index, frequency);
                              
                              return _buildEnhancedRecommendedCard(
                                context, 
                                workout, 
                                dayLabel,
                                isToday: index == 0,
                              );
                            } else {
                              return _buildNextUpCard(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb, size: 14, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(
                              'Personalized based on your goals and level',
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXPLORE',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return _buildHorizontalCategoryCard(
                                  context,
                                  title: 'FOR YOU',
                                  subtitle: '${programProvider.recommendedPrograms.length} programs',
                                  icon: Icons.star,
                                  color: Colors.amber,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FilteredProgramsScreen(
                                          title: 'Recommended For You',
                                          programs: programProvider.recommendedPrograms,
                                        ),
                                      ),
                                    ).then((_) {
                                      _refreshUserProgress();
                                    });
                                  },
                                );
                              case 1:
                                return _buildHorizontalCategoryCard(
                                  context,
                                  title: 'BY LEVEL',
                                  subtitle: 'Beginner • Intermediate • Advanced',
                                  icon: Icons.trending_up,
                                  color: Colors.green,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LevelFilterScreen(),
                                      ),
                                    ).then((_) {
                                      _refreshUserProgress();
                                    });
                                  },
                                );
                              case 2:
                                return _buildHorizontalCategoryCard(
                                  context,
                                  title: 'BY GOAL',
                                  subtitle: 'Muscle • Fat Loss • Cardio',
                                  icon: Icons.flag,
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const GoalFilterScreen(),
                                      ),
                                    ).then((_) {
                                      _refreshUserProgress();
                                    });
                                  },
                                );
                              case 3:
                                return _buildHorizontalCategoryCard(
                                  context,
                                  title: 'BY TYPE',
                                  subtitle: 'Calisthenics • Weights • Yoga',
                                  icon: Icons.category,
                                  color: Colors.purple,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TypeFilterScreen(),
                                      ),
                                    ).then((_) {
                                      _refreshUserProgress();
                                    });
                                  },
                                );
                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR PROGRAM',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: !hasActiveProgram 
                          ? _buildNoActiveProgram(context)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            program?['name'] ?? 'Program',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            program?['description'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getProgramColor(program?['level'] ?? '').withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Week ${userProgress?['current_week'] ?? 1} of ${program?['duration_weeks'] ?? 4}',
                                        style: TextStyle(
                                          color: _getProgramColor(program?['level'] ?? ''),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                LinearProgressIndicator(
                                  value: programProgress,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getProgramColor(program?['level'] ?? '')
                                  ),
                                  minHeight: 4,
                                ),
                                const SizedBox(height: 16),
                                
                                ...List.generate(7, (index) {
                                  final dayNumber = index + 1;
                                  Map<String, dynamic>? dayWorkout;
                                  
                                  if (index < weekSchedule.length) {
                                    dayWorkout = weekSchedule[index];
                                  }
                                  
                                  final isRest = dayWorkout == null || dayWorkout['workouts'] == null;
                                  final workoutData = dayWorkout?['workouts'];
                                  final isToday = dayNumber == (userProgress?['current_day'] ?? 1);
                                  
                                  // ✅ Proper completion check
                                  bool isCompleted = false;
                                  if (userProgress != null && workoutData != null) {
                                    final completedList = userProgress['completed_workouts'];
                                    if (completedList != null && completedList is List) {
                                      isCompleted = completedList.any((entry) {
                                        if (entry is Map) {
                                          return entry['workout_id'] == workoutData['id'] && 
                                                 entry['week'] == userProgress['current_week'] &&
                                                 entry['day'] == dayNumber;
                                        } else if (entry is int) {
                                          return entry == workoutData['id'];
                                        }
                                        return false;
                                      });
                                    }
                                  }
                                  
                                  return _buildProgramWorkoutItem(
                                    dayNumber,
                                    isRest ? 'Rest Day' : (workoutData?['title'] ?? 'Workout'),
                                    isRest ? '' : '${workoutData?['duration_minutes'] ?? 20} min',
                                    isRest,
                                    isCompleted,
                                    isToday,
                                    workoutData,
                                  );
                                }),
                                
                                const SizedBox(height: 12),
                                
                                if (todaysWorkout != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _navigateToWorkout(context, todaysWorkout);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'CONTINUE YOUR JOURNEY →',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                TextButton(
                                  onPressed: () {
                                    if (hasActiveProgram) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProgramDetailScreen(
                                            programId: program!['id'],
                                            onProgramStarted: () {
                                              _refreshUserProgress();
                                            },
                                          ),
                                        ),
                                      ).then((_) {
                                        _refreshUserProgress();
                                      });
                                    }
                                  },
                                  child: const Text(
                                    'VIEW FULL PROGRAM →',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoActiveProgram(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              const Text(
                'No Active Program',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a program from EXPLORE to start your fitness journey',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickExploreButton(
                    context,
                    'BY LEVEL',
                    Icons.trending_up,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LevelFilterScreen(),
                        ),
                      ).then((_) {
                        _refreshUserProgress();
                      });
                    },
                  ),
                  _buildQuickExploreButton(
                    context,
                    'BY GOAL',
                    Icons.flag,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GoalFilterScreen(),
                        ),
                      ).then((_) {
                        _refreshUserProgress();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickExploreButton(
                    context,
                    'BY TYPE',
                    Icons.category,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TypeFilterScreen(),
                        ),
                      ).then((_) {
                        _refreshUserProgress();
                      });
                    },
                  ),
                  _buildQuickExploreButton(
                    context,
                    'FOR YOU',
                    Icons.star,
                    Colors.amber,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FilteredProgramsScreen(
                            title: 'Recommended For You',
                            programs: context.read<ProgramProvider>().recommendedPrograms,
                          ),
                        ),
                      ).then((_) {
                        _refreshUserProgress();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickExploreButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedRecommendedCard(
    BuildContext context,
    Map<String, dynamic> workout,
    String dayLabel, {
    bool isToday = false,
  }) {
    String getRecommendationReason() {
      final goal = context.read<OnboardingProvider>().fitnessGoal ?? '';
      if (goal.contains('fat loss') && workout['category'] == 'HIIT') {
        return '🔥 Fat loss focus';
      } else if (goal.contains('muscle') && workout['title']?.contains('Upper') == true) {
        return '💪 Muscle building';
      } else if (workout['level'] == 'Beginner') {
        return '🌟 Beginner friendly';
      }
      return '🎯 Matches your goals';
    }

    IconData getWorkoutIcon() {
      switch (workout['category']?.toString().toLowerCase()) {
        case 'calisthenics': return Icons.accessibility_new;
        case 'weightlifting': return Icons.fitness_center;
        case 'yoga': return Icons.self_improvement;
        case 'hiit': return Icons.flash_on;
        default: return Icons.fitness_center;
      }
    }

    return GestureDetector(
      onTap: () => _navigateToWorkout(context, workout),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isToday 
                ? [Colors.blue.shade800, Colors.purple.shade800]
                : [Colors.grey[900]!, Colors.grey[850]!],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday ? Colors.blue : Colors.grey[800]!,
            width: isToday ? 2 : 1,
          ),
          boxShadow: isToday ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue : Colors.grey[800],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.grey[300],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      if (!isToday && workout['level'] == 'Beginner')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '🌟',
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout['title'] ?? 'Workout',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.grey[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          getWorkoutIcon(),
                          color: isToday ? Colors.white70 : Colors.grey[500],
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: isToday ? Colors.white60 : Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${workout['duration_minutes'] ?? 20} min',
                        style: TextStyle(
                          color: isToday ? Colors.white60 : Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: isToday ? Colors.white60 : Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(workout['duration_minutes'] ?? 20) * 8} kcal',
                        style: TextStyle(
                          color: isToday ? Colors.white60 : Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isToday 
                          ? Colors.white.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getRecommendationReason(),
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.blue,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramWorkoutItem(
    int day,
    String title,
    String duration,
    bool isRest,
    bool isCompleted,
    bool isToday,
    Map<String, dynamic>? workout,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isRest && workout != null && !isCompleted) {
          _navigateToWorkout(context, workout);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRest 
              ? Colors.grey[900] 
              : isToday 
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday 
                ? Colors.blue 
                : isRest 
                    ? Colors.grey[800]! 
                    : isCompleted
                        ? Colors.green
                        : Colors.grey[700]!,
            width: isToday ? 2 : (isCompleted ? 1 : 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isRest 
                    ? Colors.grey[800] 
                    : isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : isToday
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.green, size: 16)
                    : Text(
                        'D$day',
                        style: TextStyle(
                          color: isRest 
                              ? Colors.grey[500] 
                              : isToday
                                  ? Colors.blue
                                  : Colors.grey[400],
                          fontSize: 10,
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
                    title,
                    style: TextStyle(
                      color: isRest 
                          ? Colors.grey[500] 
                          : isCompleted
                              ? Colors.green
                              : isToday
                                  ? Colors.blue
                                  : Colors.white,
                      fontWeight: isCompleted || isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (!isRest) ...[
                    const SizedBox(height: 2),
                    Text(
                      duration,
                      style: TextStyle(
                        color: isCompleted ? Colors.green.withOpacity(0.7) : Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRest && !isCompleted && !isToday)
              const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (isToday && !isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextUpCard(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 40, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text(
            'Next Up',
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'More workouts coming',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _getProgramColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.blue;
      case 'advanced': return Colors.orange;
      case 'athlete':
      case 'elite': return Colors.purple;
      default: return Colors.blue;
    }
  }

  void _navigateToWorkout(BuildContext context, Map<String, dynamic> workout) {
    int workoutId;

    if (workout['title'] == 'Beginner Full Body') {
      workoutId = 9;
    } else if (workout['title'] == 'Core Crusher') {
      workoutId = 10;
    } else if (workout['title'] == 'Upper Body Pump') {
      workoutId = 11;
    } else if (workout['title'] == 'Leg Day') {
      workoutId = 12;
    } else if (workout['title'] == 'HIIT Blast') {
      workoutId = 13;
    } else if (workout['title'] == 'Calisthenics Master') {
      workoutId = 14;
    } else if (workout['title'] == 'Full Body Advanced') {
      workoutId = 15;
    } else {
      workoutId = workout['id'] as int? ?? 0;
    }

    if (workoutId != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workoutId: workoutId),
        ),
      ).then((_) {
        _refreshUserProgress();
      });
    }
  }
}

// Simple filtered programs screen for "FOR YOU" category
class FilteredProgramsScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> programs;

  const FilteredProgramsScreen({
    super.key,
    required this.title,
    required this.programs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: programs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No programs found',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.purple.shade900],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.white),
                  ),
                  title: Text(
                    program['name'] ?? 'Program',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${program['duration_weeks']} weeks • ${program['level'] ?? 'Beginner'}',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgramDetailScreen(
                          programId: program['id'],
                          onProgramStarted: () {},
                        ),
                      ),
                    ).then((_) {
                      context.read<ProgramProvider>().loadUserProgress();
                      context.read<HealthProvider>().loadHealthData();
                    });
                  },
                );
              },
            ),
    );
  }
}