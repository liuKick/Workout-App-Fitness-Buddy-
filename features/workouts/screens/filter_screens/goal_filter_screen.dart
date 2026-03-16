// lib/features/workouts/screens/filter_screens/goal_filter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';
import '../program_detail_screen.dart';

class GoalFilterScreen extends StatefulWidget {
  const GoalFilterScreen({super.key});

  @override
  State<GoalFilterScreen> createState() => _GoalFilterScreenState();
}

class _GoalFilterScreenState extends State<GoalFilterScreen> {
  String _selectedGoal = 'Muscle';
  
  final List<Map<String, dynamic>> _goals = [
    {'name': 'Muscle', 'color': Colors.blue, 'icon': Icons.fitness_center},
    {'name': 'Fat Loss', 'color': Colors.orange, 'icon': Icons.local_fire_department},
    {'name': 'Cardio', 'color': Colors.red, 'icon': Icons.directions_run},
    {'name': 'Strength', 'color': Colors.purple, 'icon': Icons.fitness_center},
  ];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final programProvider = context.read<ProgramProvider>();
    await programProvider.loadPrograms();
    setState(() {});
  }

  Future<void> _refreshAfterProgramStart() async {
    await _loadPrograms();
    context.read<ProgramProvider>().loadUserProgress();
  }

  List<Map<String, dynamic>> _getProgramsForGoal(List<Map<String, dynamic>> allPrograms, String goal) {
    return allPrograms.where((p) {
      final goals = p['goals'] as List?;
      if (goals == null) return false;
      
      return goals.any((g) {
        final goalStr = g.toString().toLowerCase();
        final searchGoal = goal.toLowerCase();
        
        if (searchGoal == 'muscle' && goalStr.contains('muscle')) return true;
        if (searchGoal == 'fat loss' && (goalStr.contains('fat') || goalStr.contains('loss'))) return true;
        if (searchGoal == 'cardio' && goalStr.contains('cardio')) return true;
        if (searchGoal == 'strength' && goalStr.contains('strength')) return true;
        
        return false;
      });
    }).toList();
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.blue;
      case 'advanced': return Colors.orange;
      case 'athlete':
      case 'elite': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _getProgramEmoji(String programName) {
    if (programName.contains('Foundation')) return '🌱';
    if (programName.contains('Strength')) return '💪';
    if (programName.contains('Transformation')) return '🔥';
    if (programName.contains('Fat Loss')) return '⚡';
    if (programName.contains('Muscle')) return '🏋️';
    if (programName.contains('Calisthenics')) return '🤸';
    if (programName.contains('Yoga')) return '🧘';
    if (programName.contains('HIIT')) return '💨';
    if (programName.contains('Beast')) return '🦁';
    if (programName.contains('Elite')) return '👑';
    if (programName.contains('Peak')) return '⛰️';
    if (programName.contains('Cardio')) return '❤️';
    if (programName.contains('Power')) return '⚡';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programProvider = context.watch<ProgramProvider>();
    final allPrograms = programProvider.programs;
    
    final currentPrograms = _getProgramsForGoal(allPrograms, _selectedGoal);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
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
                  Navigator.pushReplacementNamed(context, '/workouts');
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
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'PROGRAMS BY GOAL',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose Your Goal',
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
                        ],
                      ),
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
                    'SELECT GOAL',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        final isSelected = _selectedGoal == goal['name'];
                        final programCount = _getProgramsForGoal(allPrograms, goal['name']).length;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGoal = goal['name'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? goal['color'] : Colors.grey[900],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? goal['color'] : Colors.grey[800]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  goal['icon'],
                                  color: isSelected ? Colors.white : goal['color'],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  goal['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : goal['color'],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (programCount > 0)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.2) : goal['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$programCount',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : goal['color'],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: currentPrograms.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center, size: 48, color: Colors.grey[700]),
                            const SizedBox(height: 12),
                            Text(
                              'No programs for $_selectedGoal goal',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final program = currentPrograms[index];
                        final levelColor = _getLevelColor(program['level'] ?? '');
                        
                        return GestureDetector(
                          onTap: () {
                            // CRITICAL DEBUG - This MUST show in console
                            print('🔴🔴🔴 TAPPED PROGRAM IN GOAL FILTER:');
                            print('   Name: ${program['name']}');
                            print('   ID: ${program['id']}');
                            print('   Duration: ${program['duration_weeks']} weeks');
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProgramDetailScreen(
                                  programId: program['id'],
                                  onProgramStarted: () {
                                    _refreshAfterProgramStart();
                                  },
                                ),
                              ),
                            ).then((_) {
                              _refreshAfterProgramStart();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  levelColor.withOpacity(0.2),
                                  levelColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: levelColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: levelColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getProgramEmoji(program['name'] ?? ''),
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program['name'] ?? 'Program',
                                        style: TextStyle(
                                          color: levelColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        program['description'] ?? 'No description',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: levelColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${program['duration_weeks']} weeks',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: levelColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.fitness_center, size: 12, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${program['min_frequency'] ?? 3}x/week',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: levelColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              program['level'] ?? 'Beginner',
                                              style: TextStyle(
                                                color: levelColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: currentPrograms.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}