// lib/features/workouts/screens/filter_screens/level_filter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';
import '../program_detail_screen.dart';

class LevelFilterScreen extends StatefulWidget {
  const LevelFilterScreen({super.key});

  @override
  State<LevelFilterScreen> createState() => _LevelFilterScreenState();
}

class _LevelFilterScreenState extends State<LevelFilterScreen> {
  String _selectedLevel = 'Beginner';
  
  final List<Map<String, dynamic>> _levels = [
    {'name': 'Beginner', 'color': Colors.green, 'icon': Icons.eco},
    {'name': 'Intermediate', 'color': Colors.blue, 'icon': Icons.trending_up},
    {'name': 'Advanced', 'color': Colors.orange, 'icon': Icons.whatshot},
    {'name': 'Athlete', 'color': Colors.purple, 'icon': Icons.military_tech},
  ];

  Map<String, List<Map<String, dynamic>>> _programsByLevel = {
    'Beginner': [],
    'Intermediate': [],
    'Advanced': [],
    'Athlete': [],
  };

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final programProvider = context.read<ProgramProvider>();
    await programProvider.loadPrograms();
    
    final allPrograms = programProvider.programs;
    
    print('📋 ALL PROGRAMS IN DATABASE:');
    for (var p in allPrograms) {
      print('   - ${p['name']} (ID: ${p['id']}) - Level: ${p['level']} - Duration: ${p['duration_weeks']} weeks');
    }
    
    setState(() {
      _programsByLevel = {
        'Beginner': allPrograms.where((p) {
          final level = p['level']?.toString().toLowerCase() ?? '';
          return level == 'beginner';
        }).toList(),
        'Intermediate': allPrograms.where((p) {
          final level = p['level']?.toString().toLowerCase() ?? '';
          return level == 'intermediate';
        }).toList(),
        'Advanced': allPrograms.where((p) {
          final level = p['level']?.toString().toLowerCase() ?? '';
          return level == 'advanced';
        }).toList(),
        'Athlete': allPrograms.where((p) {
          final level = p['level']?.toString().toLowerCase() ?? '';
          return level == 'athlete' || level == 'elite';
        }).toList(),
      };
    });
    
    print('📊 PROGRAMS FOR $_selectedLevel:');
    for (var p in _programsByLevel[_selectedLevel]!) {
      print('   - ${p['name']} (ID: ${p['id']}) - ${p['duration_weeks']} weeks');
    }
  }

  Future<void> _refreshAfterProgramStart() async {
    await _loadPrograms();
    context.read<ProgramProvider>().loadUserProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPrograms = _programsByLevel[_selectedLevel] ?? [];

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
                            'WORKOUT PLANS BY LEVEL',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose Your Level',
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
                    'SELECT LEVEL',
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
                      itemCount: _levels.length,
                      itemBuilder: (context, index) {
                        final level = _levels[index];
                        final isSelected = _selectedLevel == level['name'];
                        final programCount = _programsByLevel[level['name']]?.length ?? 0;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLevel = level['name'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? level['color'] : Colors.grey[900],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? level['color'] : Colors.grey[800]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  level['icon'],
                                  color: isSelected ? Colors.white : level['color'],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  level['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : level['color'],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (programCount > 0)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.2) : level['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$programCount',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : level['color'],
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
                              'No programs for $_selectedLevel level',
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
                        final programColor = _getLevelColor(program['level']?.toString() ?? '');
                        
                        // Capture the program ID locally
                        final int programId = program['id'] as int;
                        final String programName = program['name'] ?? 'Program';
                        
                        return GestureDetector(
                          onTap: () {
                            // 🔴 CRITICAL: Verify the program ID from the provider again
                            final freshProgram = context.read<ProgramProvider>().programs.firstWhere(
                              (p) => p['id'] == programId,
                              orElse: () => <String, dynamic>{},
                            );
                            
                            if (freshProgram.isEmpty) {
                              print('❌ Program with ID $programId not found in provider!');
                              return;
                            }
                            
                            print('🔴🔴🔴 TAPPED PROGRAM:');
                            print('   Name: $programName');
                            print('   ID from tile: $programId');
                            print('   Fresh ID: ${freshProgram['id']}');
                            print('   Fresh Name: ${freshProgram['name']}');
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProgramDetailScreen(
                                  programId: programId,  // Use the captured ID
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
                                  programColor.withOpacity(0.2),
                                  programColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: programColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: programColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getProgramEmoji(programName),
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
                                        programName,
                                        style: TextStyle(
                                          color: programColor,
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
                                              color: programColor.withOpacity(0.2),
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
                                              color: programColor.withOpacity(0.2),
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
    return '💪';
  }
}