// lib/features/scoring/screens/scoring_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scoring_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../achievements/providers/achievement_provider.dart';

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadHealthData();
      context.read<ScoringProvider>().loadActivityLogs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoringProvider = context.watch<ScoringProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final achievementProvider = context.watch<AchievementProvider>();
    
    // DEBUG PRINTS
    print('📊 SCORING SCREEN DATA:');
    print('   Health - totalWorkouts: ${healthProvider.totalWorkouts}');
    print('   Health - workoutLogs count: ${healthProvider.workoutLogs.length}');
    print('   Health - totalMinutes: ${healthProvider.totalMinutes}');
    print('   Health - streakDays: ${healthProvider.streakDays}');
    if (healthProvider.workoutLogs.isNotEmpty) {
      print('   First log: ${healthProvider.workoutLogs.first}');
    }
    
    final weeklyPoints = scoringProvider.getWeeklyPoints();
    final pointsHistory = scoringProvider.getPointsHistory(7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // ✅ FIXED: Safe back button navigation
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: theme.textTheme.bodyLarge?.color),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade900,
                          Colors.purple.shade900,
                          Colors.amber.shade800,
                        ],
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'SCORING SYSTEM',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your Activity Points',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Total points display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars, color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  '${scoringProvider.totalPoints}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'pts',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
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
          
          // Category chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    String label;
                    Color color;
                    
                    switch (index) {
                      case 0:
                        label = 'ACTIVITY FEED';
                        color = Colors.blue;
                        break;
                      case 1:
                        label = 'STATISTICS';
                        color = Colors.green;
                        break;
                      default:
                        label = '';
                        color = Colors.grey;
                    }
                    
                    final isSelected = _selectedTab == index;
                    
                    return GestureDetector(
                      onTap: () {
                        _tabController.index = index;
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? color.withOpacity(0.5) : Colors.grey[800]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? color : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Points breakdown cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildBreakdownCard(
                    icon: Icons.fitness_center,
                    label: 'Workouts',
                    points: scoringProvider.workoutPoints,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _buildBreakdownCard(
                    icon: Icons.restaurant,
                    label: 'Meals',
                    points: scoringProvider.mealPoints,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _buildBreakdownCard(
                    icon: Icons.local_fire_department,
                    label: 'Streaks',
                    points: scoringProvider.streakPoints,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          
          // Content based on selected tab
          if (_selectedTab == 0) ...[
            // ACTIVITY FEED
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= scoringProvider.activityLogs.length) return null;
                    final log = scoringProvider.activityLogs[index];
                    
                    return _buildActivityCard(log);
                  },
                  childCount: scoringProvider.activityLogs.length,
                ),
              ),
            ),
          ] else ...[
            // STATISTICS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY POINTS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Weekly chart
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeeklyBar('Mon', weeklyPoints['Mon'] ?? 0, Colors.blue),
                          _buildWeeklyBar('Tue', weeklyPoints['Tue'] ?? 0, Colors.blue),
                          _buildWeeklyBar('Wed', weeklyPoints['Wed'] ?? 0, Colors.blue),
                          _buildWeeklyBar('Thu', weeklyPoints['Thu'] ?? 0, Colors.blue),
                          _buildWeeklyBar('Fri', weeklyPoints['Fri'] ?? 0, Colors.blue),
                          _buildWeeklyBar('Sat', weeklyPoints['Sat'] ?? 0, Colors.green),
                          _buildWeeklyBar('Sun', weeklyPoints['Sun'] ?? 0, Colors.green),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'OVERALL STATS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Using health provider for real data
                    _buildStatRow('Total Workouts', '${healthProvider.totalWorkouts}'),
                    _buildStatRow('Total Minutes', '${healthProvider.totalMinutes}'),
                    _buildStatRow('Current Streak', '${healthProvider.streakDays} days'),
                    _buildStatRow('Achievements', '${achievementProvider.userAchievements.length}'),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'POINTS HISTORY',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...pointsHistory.map((data) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                data['day'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: data['points'] / 100,
                                backgroundColor: Colors.grey[800],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${data['points']} pts',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard({
    required IconData icon,
    required String label,
    required int points,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$points',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityLog log) {
    Color getColor() {
      switch (log.type) {
        case 'workout': return Colors.blue;
        case 'meal': return Colors.green;
        case 'streak': return Colors.orange;
        case 'achievement': return Colors.amber;
        default: return Colors.grey;
      }
    }

    IconData getIcon() {
      switch (log.type) {
        case 'workout': return Icons.fitness_center;
        case 'meal': return Icons.restaurant;
        case 'streak': return Icons.local_fire_department;
        case 'achievement': return Icons.emoji_events;
        default: return Icons.stars;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              getIcon(),
              color: getColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(log.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.amber, size: 14),
                Text(
                  '${log.points}',
                  style: TextStyle(
                    color: getColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar(String day, int points, Color color) {
    double maxPoints = 100;
    double height = (points / maxPoints) * 60;
    
    return Column(
      children: [
        Container(
          width: 20,
          height: height.clamp(4, 60),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
        Text(
          '$points',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400]),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}