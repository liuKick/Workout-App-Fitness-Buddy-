// lib/features/workouts/screens/filter_screens/type_filter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';
import '../program_detail_screen.dart';

class TypeFilterScreen extends StatefulWidget {
  const TypeFilterScreen({super.key});

  @override
  State<TypeFilterScreen> createState() => _TypeFilterScreenState();
}

class _TypeFilterScreenState extends State<TypeFilterScreen> {
  String _selectedType = 'Weightlifting';
  
  final List<Map<String, dynamic>> _types = [
    {'name': 'Calisthenics', 'color': Colors.blue, 'emoji': '🤸', 'count': 0},
    {'name': 'Weightlifting', 'color': Colors.red, 'emoji': '🏋️', 'count': 0},
    {'name': 'Yoga', 'color': Colors.green, 'emoji': '🧘', 'count': 0},
    {'name': 'HIIT', 'color': Colors.orange, 'emoji': '⚡', 'count': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ProgramProvider>().loadPrograms();
    setState(() {});
  }

  Future<void> _refreshAfterProgramStart() async {
    await _loadData();
    context.read<ProgramProvider>().loadUserProgress();
  }

  List<Map<String, dynamic>> _getProgramsForType(List<Map<String, dynamic>> allPrograms, String type) {
    return allPrograms.where((p) {
      final category = p['category']?.toString().toLowerCase() ?? '';
      final name = p['name']?.toString().toLowerCase() ?? '';
      final equipment = p['equipment_needed'] as List? ?? [];
      
      if (type == 'Weightlifting') {
        return category.contains('weight') || 
               name.contains('strength') || 
               name.contains('muscle') ||
               equipment.any((e) => 
                 e.toString().toLowerCase().contains('dumbbell') ||
                 e.toString().toLowerCase().contains('barbell')
               );
      } else if (type == 'Calisthenics') {
        return category.contains('calisthenics') || 
               name.contains('calisthenics') ||
               name.contains('bodyweight');
      } else if (type == 'Yoga') {
        return category.contains('yoga') || name.contains('yoga');
      } else if (type == 'HIIT') {
        return category.contains('hiit') || 
               name.contains('hiit') || 
               name.contains('cardio');
      }
      return false;
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
    if (programName.contains('Beast')) return '🦁';
    if (programName.contains('Westside')) return '🏋️';
    if (programName.contains('531')) return '5️⃣3️⃣1️⃣';
    if (programName.contains('Muscle')) return '💪';
    if (programName.contains('Calisthenics')) return '🤸';
    if (programName.contains('Yoga')) return '🧘';
    if (programName.contains('HIIT')) return '⚡';
    if (programName.contains('Cardio')) return '❤️';
    if (programName.contains('Power')) return '⚡';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programProvider = context.watch<ProgramProvider>();
    final allPrograms = programProvider.programs;
    
    for (var type in _types) {
      type['count'] = _getProgramsForType(allPrograms, type['name']).length;
    }
    
    final selectedPrograms = _getProgramsForType(allPrograms, _selectedType);

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
                            'PROGRAMS BY TYPE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose Workout Type',
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
                    'SELECT TYPE',
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
                      itemCount: _types.length,
                      itemBuilder: (context, index) {
                        final type = _types[index];
                        final isSelected = _selectedType == type['name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = type['name'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? type['color'] : Colors.grey[900],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? type['color'] : Colors.grey[800]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  type['emoji'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  type['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : type['color'],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (type['count'] > 0) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.2) : type['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${type['count']}',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : type['color'],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
            sliver: selectedPrograms.isEmpty
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
                              'No programs for $_selectedType type',
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
                        final program = selectedPrograms[index];
                        final levelColor = _getLevelColor(program['level'] ?? '');
                        
                        return GestureDetector(
                          onTap: () {
                            print('🔴🔴🔴 TAPPED PROGRAM IN TYPE FILTER:');
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
                      childCount: selectedPrograms.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}