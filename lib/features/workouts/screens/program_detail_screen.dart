// lib/features/workouts/screens/program_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/program_provider.dart';
import '../providers/workout_provider.dart';
import '../../health/providers/health_provider.dart';
import 'workout_detail_screen.dart';

class ProgramDetailScreen extends StatefulWidget {
  final int programId;
  final VoidCallback? onProgramStarted;

  const ProgramDetailScreen({
    super.key,
    required this.programId,
    this.onProgramStarted,
  });

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  int _selectedWeek = 1;
  bool _isLoading = false;
  bool _isEnrolling = false;
  Map<String, dynamic>? _program; // local copy, not from provider

  @override
  void initState() {
    super.initState();
    print('🚀 ProgramDetailScreen opened with programId: ${widget.programId}');
    _loadProgramDetails();
  }

  Future<void> _loadProgramDetails() async {
    setState(() => _isLoading = true);
    
    final programProvider = context.read<ProgramProvider>();
    // Use the new fetch method that doesn't affect shared state
    _program = await programProvider.fetchProgramById(widget.programId);
    
    await context.read<WorkoutProvider>().loadWorkouts();
    await programProvider.loadUserProgress();
    
    if (_program != null) {
      print('✅ Loaded program: ${_program!['name']}');
      print('📊 Duration: ${_program!['duration_weeks']} weeks');
      print('✅ ID: ${_program!['id']}');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _enrollInProgram() async {
    setState(() => _isEnrolling = true);
    
    final programProvider = context.read<ProgramProvider>();
    await programProvider.enrollInProgram(widget.programId);
    
    if (widget.onProgramStarted != null) {
      widget.onProgramStarted!();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Enrolled in ${_getProgramName()}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      final todaysWorkout = programProvider.getTodaysWorkout();
      if (todaysWorkout != null) {
        _navigateToWorkout(context, todaysWorkout);
      } else {
        Navigator.pop(context);
      }
    }
    
    setState(() => _isEnrolling = false);
  }

  String _getProgramName() => _program?['name'] ?? 'Program';

  String _getProgramBackground() {
    final name = _program?['name']?.toString().toLowerCase() ?? '';
    if (name.contains('fat')) return 'assets/images/fatloss2.jpg';
    if (name.contains('muscle')) return 'assets/images/muscle_builder.jpg';
    if (name.contains('calisthenics')) return 'assets/images/calisthetic.jpg';
    if (name.contains('cardio')) return 'assets/images/cardio.jpg';
    if (name.contains('yoga')) return 'assets/images/yoga.jpg';
    if (name.contains('hiit')) return 'assets/images/hiit.jpg';
    return 'assets/images/LoginScreen2.jpg';
  }

  Color _getProgramColor() {
    if (_program == null) return Colors.blue;
    final level = _program!['level']?.toString().toLowerCase() ?? '';
    switch (level) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.blue;
      case 'advanced': return Colors.orange;
      case 'athlete':
      case 'elite': return Colors.purple;
      default: return Colors.blue;
    }
  }

  Color _getProgramAccentColor() {
    if (_program == null) return Colors.lightBlue;
    final level = _program!['level']?.toString().toLowerCase() ?? '';
    switch (level) {
      case 'beginner': return Colors.lightGreen;
      case 'intermediate': return Colors.lightBlue;
      case 'advanced': return Colors.deepOrange;
      case 'athlete':
      case 'elite': return Colors.deepPurple;
      default: return Colors.lightBlue;
    }
  }

  void _navigateToWorkout(BuildContext context, Map<String, dynamic> workout) {
    int workoutId = workout['id'] as int? ?? 0;
    if (workoutId != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workoutId: workoutId),
        ),
      );
    }
  }

  bool _isWorkoutCompleted(Map<String, dynamic>? userProgress, int workoutId, int week, int day) {
    if (userProgress == null) return false;
    final completedWorkouts = userProgress['completed_workouts'];
    if (completedWorkouts == null) return false;
    if (completedWorkouts is List) {
      if (completedWorkouts.isNotEmpty && completedWorkouts.first is Map) {
        return completedWorkouts.any((cw) => 
          cw['workout_id'] == workoutId && 
          cw['week'] == week && 
          cw['day'] == day
        );
      } else if (completedWorkouts.isNotEmpty && completedWorkouts.first is int) {
        return (completedWorkouts as List).contains(workoutId);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programProvider = context.watch<ProgramProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final userProgress = programProvider.userProgress;
    final isEnrolled = userProgress != null && 
                      userProgress['program_id'] == widget.programId &&
                      userProgress['status'] == 'active';

    if (_isLoading || (_program == null && programProvider.isLoading)) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.textTheme.bodyLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_program == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.textTheme.bodyLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Program Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'Could not load program',
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Build weeks and workouts from local _program
    final weeks = <Map<String, dynamic>>[];
    if (_program!['program_weeks'] != null) {
      final weekList = _program!['program_weeks'] as List;
      weeks.addAll(weekList.map((w) => Map<String, dynamic>.from(w)));
    }
    weeks.sort((a, b) => (a['week_number'] as int? ?? 0).compareTo(b['week_number'] as int? ?? 0));
    
    Map<String, dynamic> currentWeekData = {};
    if (weeks.isNotEmpty) {
      try {
        currentWeekData = weeks.firstWhere(
          (w) => (w['week_number'] as int? ?? 0) == _selectedWeek,
          orElse: () => weeks.first,
        );
      } catch (e) {
        currentWeekData = weeks.first;
      }
    }
    
    final workouts = <Map<String, dynamic>>[];
    if (currentWeekData['program_workouts'] != null) {
      final workoutList = currentWeekData['program_workouts'] as List;
      workouts.addAll(workoutList.map((w) {
        final workoutData = Map<String, dynamic>.from(w);
        if (workoutData['workouts'] != null) {
          workoutData['workouts'] = Map<String, dynamic>.from(workoutData['workouts']);
        }
        return workoutData;
      }));
    }
    workouts.sort((a, b) => (a['day_number'] as int? ?? 0).compareTo(b['day_number'] as int? ?? 0));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_getProgramBackground()),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (_program!['goals'] as List?)?.first?.toString().toUpperCase() ?? 'PROGRAM',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _program!['name'] as String? ?? 'Program',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatItem(
                                icon: Icons.calendar_today,
                                value: '${_program!['duration_weeks']} weeks',
                              ),
                              const SizedBox(width: 16),
                              _buildStatItem(
                                icon: Icons.fitness_center,
                                value: _program!['level'] as String? ?? 'Beginner',
                              ),
                              const SizedBox(width: 16),
                              _buildStatItem(
                                icon: Icons.access_time,
                                value: '${_program!['min_frequency'] ?? 3}/week',
                              ),
                            ],
                          ),
                          
                          if (isEnrolled) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: programProvider.getProgramProgress(),
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(programProvider.getProgramProgress() * 100).round()}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  _program!['description'] as String? ?? 'No description available',
                  style: TextStyle(color: Colors.grey[300], height: 1.5),
                ),
                const SizedBox(height: 20),

                if (_program!['goals'] != null) ...[
                  _buildSectionTitle('Goals', _getProgramColor()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_program!['goals'] as List).map((goal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getProgramColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getProgramColor().withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          goal.toString(),
                          style: TextStyle(
                            color: _getProgramColor().withOpacity(0.8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (_program!['equipment_needed'] != null) ...[
                  _buildSectionTitle('Equipment Needed', _getProgramColor()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_program!['equipment_needed'] as List).map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getEquipmentIcon(item.toString()),
                              size: 14,
                              color: _getProgramColor().withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.toString(),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (!isEnrolled)
                  _buildEnrollButton(),
                if (isEnrolled)
                  _buildContinueButton(userProgress!),

                const SizedBox(height: 20),

                _buildSectionTitle('Program Schedule', _getProgramColor()),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(weeks.length, (index) {
                      final week = weeks[index];
                      final weekNumber = week['week_number'] as int? ?? index + 1;
                      final isSelected = _selectedWeek == weekNumber;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWeek = weekNumber;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? _getProgramColor().withOpacity(0.2)
                                : Colors.grey[900],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected 
                                  ? _getProgramColor().withOpacity(0.5)
                                  : Colors.grey[800]!,
                            ),
                          ),
                          child: Text(
                            'Week $weekNumber',
                            style: TextStyle(
                              color: isSelected ? _getProgramColor() : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Workouts', _getProgramColor()),
                const SizedBox(height: 12),

                if (workouts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center, size: 48, color: Colors.grey[700]),
                          const SizedBox(height: 8),
                          Text(
                            'No workouts this week',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...workouts.map((pw) {
                    final workout = pw['workouts'] as Map<String, dynamic>? ?? {};
                    final workoutId = workout['id'] as int? ?? 0;
                    final dayNumber = pw['day_number'] as int? ?? 0;
                    
                    bool isCompleted = _isWorkoutCompleted(
                      userProgress, 
                      workoutId, 
                      _selectedWeek, 
                      dayNumber
                    );
                    
                    final isTodaysWorkout = isEnrolled && 
                        dayNumber == (userProgress?['current_day'] as int? ?? 0) &&
                        _selectedWeek == (userProgress?['current_week'] as int? ?? 1) &&
                        !isCompleted;
                    
                    return _buildWorkoutItem(
                      context,
                      workout: workout,
                      dayNumber: dayNumber,
                      isCompleted: isCompleted,
                      isTodaysWorkout: isTodaysWorkout,
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isEnrolling ? null : _enrollInProgram,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getProgramColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isEnrolling
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'START PROGRAM',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildContinueButton(Map<String, dynamic> progress) {
    final todaysWorkout = context.read<ProgramProvider>().getTodaysWorkout();
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (todaysWorkout != null) {
            _navigateToWorkout(context, todaysWorkout);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'CONTINUE WEEK ${progress['current_week']} • DAY ${progress['current_day']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildWorkoutItem(
    BuildContext context, {
    required Map<String, dynamic> workout,
    required int dayNumber,
    required bool isCompleted,
    required bool isTodaysWorkout,
  }) {
    bool isRestDay = workout.isEmpty || workout['id'] == null;
    
    return GestureDetector(
      onTap: () {
        if (!isRestDay && !isCompleted) {
          _navigateToWorkout(context, workout);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRestDay 
              ? Colors.grey[900] 
              : isCompleted 
                  ? Colors.green.withOpacity(0.1)
                  : isTodaysWorkout 
                      ? _getProgramColor().withOpacity(0.05)
                      : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRestDay 
                ? Colors.grey[800]! 
                : isCompleted 
                    ? Colors.green.withOpacity(0.3)
                    : isTodaysWorkout
                        ? _getProgramColor().withOpacity(0.3)
                        : Colors.grey[700]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isRestDay 
                    ? Colors.grey[800] 
                    : (isCompleted 
                        ? Colors.green.withOpacity(0.2)
                        : _getProgramColor().withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isRestDay 
                      ? Icons.hotel 
                      : (isCompleted 
                          ? Icons.check_circle 
                          : Icons.fitness_center),
                  color: isRestDay 
                      ? Colors.grey[500] 
                      : (isCompleted 
                          ? Colors.green 
                          : _getProgramColor()),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isRestDay ? 'Rest Day' : (workout['title'] as String? ?? 'Workout'),
                        style: TextStyle(
                          color: isRestDay 
                              ? Colors.grey[500] 
                              : (isCompleted 
                                  ? Colors.green 
                                  : isTodaysWorkout 
                                      ? _getProgramColor() 
                                      : Colors.white),
                          fontWeight: isRestDay ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Day $dayNumber',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isRestDay) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(
                          '${workout['duration_minutes'] ?? 20} min',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.fitness_center, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(
                          workout['level'] as String? ?? 'Beginner',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            if (isRestDay)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'REST',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else if (isTodaysWorkout)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgramColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getProgramColor().withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'TODAY',
                  style: TextStyle(
                    color: _getProgramColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(
                Icons.play_circle_outline, 
                color: _getProgramColor().withOpacity(0.7), 
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'dumbbells':
      case 'dumbbell':
        return Icons.fitness_center;
      case 'barbell':
        return Icons.fitness_center;
      case 'kettlebell':
        return Icons.fitness_center;
      case 'resistance bands':
      case 'bands':
        return Icons.linear_scale;
      case 'yoga mat':
      case 'mat':
        return Icons.accessibility_new;
      case 'pull up bar':
        return Icons.fitness_center;
      default:
        return Icons.fitness_center;
    }
  }
}