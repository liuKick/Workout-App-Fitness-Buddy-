// lib/features/workouts/screens/workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/workout_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import '../../../widgets/workout_video_player.dart';
import '../../workouts/providers/program_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restSeconds = 30;
  int _restSecondsRemaining = 30;
  bool _isTimerActive = false;
  List<bool> _completedExercises = [];
  List<Map<String, dynamic>> _exercises = [];
  
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Optional: keep essential print for debugging
    debugPrint('🚀 WorkoutDetailScreen initialized with ID: ${widget.workoutId}');
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkout();
    });
  }

  @override
  void dispose() {
    _isTimerActive = false;
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkout() async {
    final provider = context.read<WorkoutProvider>();
    final programProvider = context.read<ProgramProvider>();
    
    debugPrint('📥 Loading workout ID: ${widget.workoutId}');
    await provider.getWorkoutById(widget.workoutId);
    
    await programProvider.loadUserProgress();
    
    if (provider.currentWorkout == null) {
      if (mounted) {
        String errorMessage = provider.errorMessage ?? 'Could not load workout';
        debugPrint('❌ $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _loadWorkout();
              },
            ),
          ),
        );
      }
      return;
    }
    
    final workout = provider.currentWorkout;
    debugPrint('✅ Workout loaded: ${workout?['title']}');
    
    final workoutExercises = workout?['workout_exercises'];
    
    if (workoutExercises == null || workoutExercises is! List) {
      debugPrint('❌ workout_exercises is null or not a List');
      _showError('Invalid exercise data format');
      return;
    }
    
    debugPrint('✅ Found ${workoutExercises.length} exercises');
    
    if (workoutExercises.isEmpty) {
      _showError('This workout has no exercises');
      return;
    }
    
    setState(() {
      _exercises = List<Map<String, dynamic>>.from(workoutExercises);
      _completedExercises = List<bool>.filled(_exercises.length, false);
    });
    
    final userProgress = programProvider.userProgress;
    if (userProgress != null) {
      final todaysWorkout = programProvider.getTodaysWorkout();
      if (todaysWorkout != null && todaysWorkout['id'] == widget.workoutId) {
        debugPrint('🎯 This is today\'s program workout!');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _completeCurrentExercise() {
    setState(() {
      _completedExercises[_currentExerciseIndex] = true;
      
      if (_currentExerciseIndex < _completedExercises.length - 1) {
        _currentExerciseIndex++;
        _currentSet = 1;
        _startRestTimer();
      } else {
        _showCompleteDialog();
      }
    });
  }

  void _nextSet() {
    if (_exercises.isEmpty) return;
    
    final exercise = _exercises[_currentExerciseIndex];
    final totalSets = exercise['sets'] as int? ?? 3;
    
    if (_currentSet < totalSets) {
      setState(() {
        _currentSet++;
        _startRestTimer();
      });
    } else {
      _completeCurrentExercise();
    }
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _isTimerActive = true;
      _restSecondsRemaining = _restSeconds;
    });
    
    _runTimer();
  }

  void _runTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isTimerActive) return;
      
      setState(() {
        if (_restSecondsRemaining > 1) {
          _restSecondsRemaining--;
          _runTimer();
        } else {
          _isResting = false;
          _isTimerActive = false;
          _restSecondsRemaining = _restSeconds;
        }
      });
    });
  }

  void _skipRest() {
    setState(() {
      _isResting = false;
      _isTimerActive = false;
      _restSecondsRemaining = _restSeconds;
    });
  }

  void _showCompleteDialog() {
    _confettiController.play();
    
    int totalSeconds = 0;
    int totalCalories = 0;
    
    for (var ex in _exercises) {
      final duration = ex['duration_seconds'] as int? ?? 30;
      totalSeconds += duration;
      totalCalories += (duration * 0.1).round();
    }
    
    int totalMinutes = (totalSeconds / 60).ceil();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('🎉 Workout Complete!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Great job! You finished your workout.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue),
                    const SizedBox(height: 4),
                    Text('$totalMinutes min', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange),
                    const SizedBox(height: 4),
                    Text('$totalCalories kcal', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final healthProvider = context.read<HealthProvider>();
              final programProvider = context.read<ProgramProvider>();
              final workoutProvider = context.read<WorkoutProvider>();
              final onboardingProvider = context.read<OnboardingProvider>();
              final scoringProvider = context.read<ScoringProvider>();
              
              Navigator.of(ctx).pop();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saving your progress...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
              
              final workoutTitle = workoutProvider.currentWorkout?['title'] ?? 'Workout';
              
              debugPrint('🔥🔥🔥 WORKOUT COMPLETE - Saving...');
              debugPrint('   Workout: $workoutTitle');
              debugPrint('   Duration: $totalMinutes min');
              
              // Log workout to health (streak, etc.)
              await healthProvider.logWorkoutAndCheckAchievements(
                workoutId: widget.workoutId,
                durationMinutes: totalMinutes,
                caloriesBurned: totalCalories,
                context: context,
              );
              
              // Log to scoring system
              await scoringProvider.logWorkoutActivity(
                workoutName: workoutTitle,
                durationMinutes: totalMinutes,
                context: context,
              );
              
              // Complete workout in program (this now returns a bool)
              bool programSuccess = true;
              if (programProvider.userProgress != null) {
                programSuccess = await programProvider.completeWorkout(
                  context, 
                  widget.workoutId, 
                  totalSeconds,
                  totalCalories
                );
                // No need to call loadUserProgress again – completeWorkout already does it.
              }
              
              // Refresh recommended workouts
              await workoutProvider.getRecommendedWorkouts(
                userLevel: onboardingProvider.fitnessLevel?.toLowerCase() ?? 'beginner',
                userGoals: [onboardingProvider.fitnessGoal?.toLowerCase() ?? 'strength'],
                userEquipment: onboardingProvider.availableEquipment,
              );
              
              if (mounted) {
                if (!programSuccess) {
                  // Show the actual error message, or a fallback if null
                  String errorMsg = programProvider.errorMessage ?? 'Unknown error (program progress may not be saved)';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⚠️ Workout logged but program progress may not be saved: $errorMsg'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Workout saved! Streak: ${healthProvider.streakDays} days • Total points: ${scoringProvider.totalPoints}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                
                // Wait a moment then go back
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }
                });
              }
            },
            child: const Text('FINISH', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  int _getCompletedSets() {
    if (_exercises.isEmpty) return 0;
    
    int completed = 0;
    for (int i = 0; i < _currentExerciseIndex; i++) {
      final exercise = _exercises[i];
      completed += (exercise['sets'] as int? ?? 3);
    }
    completed += (_currentSet - 1);
    return completed;
  }

  int _getTotalSets() {
    int total = 0;
    for (var ex in _exercises) {
      total += (ex['sets'] as int? ?? 3);
    }
    return total;
  }

  String _getNextExerciseName() {
    if (_currentExerciseIndex + 1 < _exercises.length) {
      final nextExercise = _exercises[_currentExerciseIndex + 1];
      final exerciseData = nextExercise['exercises'] as Map<String, dynamic>?;
      return exerciseData?['name'] as String? ?? 'Next';
    }
    return 'Finish';
  }

  String _getExerciseVideoPath(String exerciseName) {
    final String normalized = exerciseName.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    
    final Map<String, String> videoMap = {
      'burpees': 'assets/videos/workouts/burpee.mp4',
      'crunches': 'assets/videos/workouts/Crunches.mp4',
      'dips': 'assets/videos/workouts/dip.mp4',
      'lunges': 'assets/videos/workouts/lunges.mp4',
      'plank': 'assets/videos/workouts/plank.mp4',
      'pullups': 'assets/videos/workouts/pullup.mp4',
      'pushups': 'assets/videos/workouts/pushup.mp4',
      'squats': 'assets/videos/workouts/squat.mp4',
      'bicyclecrunches': 'assets/videos/workouts/bicycleCrucnches.mp4',
      'glutebridges': 'assets/videos/workouts/GluteBridges.mp4',
      'jumpingjacks': 'assets/videos/workouts/JumpingJacks.mp4',
      'legraises': 'assets/videos/workouts/LegRaise.mp4',
      'mountainclimbers': 'assets/videos/workouts/MountainClimbers.mp4',
      'russiantwists': 'assets/videos/workouts/RussianTwists.mp4',
      'tricepdips': 'assets/videos/workouts/TricepDips.mp4',
    };
    
    return videoMap[normalized] ?? '';
  }

  IconData _getExerciseIcon(String name) {
    if (name.contains('Push')) return Icons.fitness_center;
    if (name.contains('Squat')) return Icons.directions_run;
    if (name.contains('Plank')) return Icons.accessibility_new;
    if (name.contains('Lunge')) return Icons.accessibility;
    if (name.contains('Pull')) return Icons.fitness_center;
    if (name.contains('Dip')) return Icons.fitness_center;
    if (name.contains('Burpee')) return Icons.flash_on;
    return Icons.fitness_center;
  }

  Widget _buildExercisePlaceholder(Map<String, dynamic>? exerciseData) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getExerciseIcon(exerciseData?['name'] as String? ?? ''),
              size: 50,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 8),
            Text(
              exerciseData?['name'] as String? ?? 'Exercise',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Video coming soon',
                style: TextStyle(color: Colors.blue, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(Map<String, dynamic>? exerciseData) {
    final exerciseName = exerciseData?['name'] as String? ?? '';
    final videoPath = _getExerciseVideoPath(exerciseName);
    
    if (videoPath.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: WorkoutVideoPlayer(
          videoPath: videoPath,
          exerciseName: exerciseName,
        ),
      );
    } else {
      return _buildExercisePlaceholder(exerciseData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutProvider = context.watch<WorkoutProvider>();
    final workout = workoutProvider.currentWorkout;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          workout?['title'] as String? ?? 'Workout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[800],
            height: 0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises in this workout',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Workout ID: ${widget.workoutId}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('RETRY'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('GO BACK'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Overall Progress',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                ),
                                Text(
                                  '${((_getCompletedSets() / _getTotalSets()) * 100).round()}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _getTotalSets() > 0 ? _getCompletedSets() / _getTotalSets() : 0,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ),
                      if (!_isResting && _currentExerciseIndex < _exercises.length)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildVideoPlayer(_exercises[_currentExerciseIndex]['exercises'] as Map<String, dynamic>?),
                        ),
                      const SizedBox(height: 8),
                      if (!_isResting && _currentExerciseIndex < _exercises.length)
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade900, Colors.purple.shade900],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Set $_currentSet/${_exercises[_currentExerciseIndex]['sets']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (_exercises[_currentExerciseIndex]['exercises'] as Map<String, dynamic>?)?['name'] as String? ?? 'Exercise',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _exercises[_currentExerciseIndex]['reps'] != null
                                            ? '${_exercises[_currentExerciseIndex]['reps']} reps'
                                            : '${_exercises[_currentExerciseIndex]['duration_seconds']} sec',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Target',
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: _nextSet,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue,
                                      minimumSize: const Size(120, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      _currentSet == (_exercises[_currentExerciseIndex]['sets'] as int? ?? 3)
                                          ? 'COMPLETE'
                                          : 'NEXT SET',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (_isResting)
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.timer, color: Colors.orange, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'REST',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Next: ${_getNextExerciseName()}',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$_restSecondsRemaining',
                                  style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _skipRest,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('SKIP', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'UP NEXT (${_exercises.length - _currentExerciseIndex - (_isResting ? 0 : 1)} exercises)',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_exercises.length - _currentExerciseIndex - (_isResting ? 0 : 1)} remaining',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = _exercises[index];
                                final exData = exercise['exercises'] as Map<String, dynamic>?;
                                final isCompleted = index < _currentExerciseIndex;
                                final isCurrent = index == _currentExerciseIndex && !_isResting;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Colors.blue.withOpacity(0.1)
                                        : isCompleted
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey[900],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCurrent
                                          ? Colors.blue
                                          : isCompleted
                                              ? Colors.green
                                              : Colors.grey[800]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? Colors.blue.withOpacity(0.2)
                                              : isCompleted
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.grey[800],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            isCompleted
                                                ? Icons.check_circle
                                                : Icons.fitness_center,
                                            color: isCompleted
                                                ? Colors.green
                                                : isCurrent
                                                    ? Colors.blue
                                                    : Colors.grey[500],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exData?['name'] as String? ?? 'Exercise',
                                              style: TextStyle(
                                                color: isCompleted
                                                    ? Colors.green
                                                    : isCurrent
                                                        ? Colors.blue
                                                        : Colors.white,
                                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${exercise['sets']} sets • ${exercise['reps'] ?? exercise['duration_seconds']} ${exercise['reps'] != null ? 'reps' : 'sec'}',
                                              style: TextStyle(
                                                color: isCompleted
                                                    ? Colors.green.withOpacity(0.7)
                                                    : Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCurrent)
                                        const Icon(Icons.play_arrow, color: Colors.blue, size: 20),
                                      if (isCompleted)
                                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 8,
              minBlastForce: 4,
              gravity: 0.3,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.amber,
                Colors.red,
              ],
              strokeWidth: 3,
              strokeColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}