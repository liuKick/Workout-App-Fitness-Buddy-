// lib/features/achievements/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    
    // Force reload when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().loadAchievements();
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
    final achievementProvider = context.watch<AchievementProvider>();
    final unlockedAchievements = achievementProvider.userAchievements;
    final allAchievements = achievementProvider.achievements;
    
    // Debug prints
    print('🏆 ACHIEVEMENTS SCREEN:');
    print('   Total achievements: ${allAchievements.length}');
    print('   Unlocked count: ${unlockedAchievements.length}');
    if (unlockedAchievements.isNotEmpty) {
      print('   First unlocked: ${unlockedAchievements.first.achievement.title}');
    } else {
      print('   No achievements unlocked yet');
    }
    
    // Group achievements by category
    final workoutAchievements = allAchievements.where((a) => 
      a.requirement == 'workouts' || a.requirement == 'streak' || a.requirement == 'minutes'
    ).toList();
    
    final nutritionAchievements = allAchievements.where((a) => 
      a.requirement == 'meals'
    ).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // ✅ FIXED: Safe back button navigation
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
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
                  // Background with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.shade900,
                          Colors.purple.shade900,
                          Colors.blue.shade900,
                        ],
                      ),
                    ),
                  ),
                  // Content with proper spacing
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'ACHIEVEMENTS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your Badges',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard(
                                icon: Icons.emoji_events,
                                value: '${unlockedAchievements.length}',
                                label: 'Unlocked',
                                color: Colors.amber,
                              ),
                              _buildStatCard(
                                icon: Icons.stars,
                                value: '${achievementProvider.totalPoints}',
                                label: 'Points',
                                color: Colors.blue,
                              ),
                              _buildStatCard(
                                icon: Icons.military_tech,
                                value: '${allAchievements.length}',
                                label: 'Total',
                                color: Colors.purple,
                              ),
                            ],
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CATEGORIES',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        String label;
                        Color color;
                        
                        switch (index) {
                          case 0:
                            label = 'ALL';
                            color = Colors.blue;
                            break;
                          case 1:
                            label = 'WORKOUTS';
                            color = Colors.green;
                            break;
                          case 2:
                            label = 'NUTRITION';
                            color = Colors.orange;
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
                ],
              ),
            ),
          ),
          
          // Achievements Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  Achievement achievement;
                  List<Achievement> displayList;
                  
                  switch (_selectedTab) {
                    case 1:
                      displayList = workoutAchievements;
                      break;
                    case 2:
                      displayList = nutritionAchievements;
                      break;
                    default:
                      displayList = allAchievements;
                  }
                  
                  if (index >= displayList.length) return null;
                  achievement = displayList[index];
                  
                  final isUnlocked = unlockedAchievements.any(
                    (ua) => ua.achievementId == achievement.id
                  );
                  
                  return _buildAchievementCard(
                    achievement: achievement,
                    isUnlocked: isUnlocked,
                  );
                },
                childCount: _selectedTab == 1 
                    ? workoutAchievements.length
                    : _selectedTab == 2
                        ? nutritionAchievements.length
                        : allAchievements.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stat card
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Achievement card
  Widget _buildAchievementCard({
    required Achievement achievement,
    required bool isUnlocked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked 
            ? achievement.color.withOpacity(0.15)
            : Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? achievement.color.withOpacity(0.5)
              : Colors.grey[800]!,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and points row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? achievement.color.withOpacity(0.2)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: isUnlocked ? achievement.color : Colors.grey[600],
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? achievement.color.withOpacity(0.2)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${achievement.points}',
                    style: TextStyle(
                      color: isUnlocked ? achievement.color : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Title
            Text(
              achievement.title,
              style: TextStyle(
                color: isUnlocked ? achievement.color : Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            // Status badge
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement.color.withOpacity(0.2)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock,
                    color: isUnlocked ? achievement.color : Colors.grey[600],
                    size: 10,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUnlocked ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      color: isUnlocked ? achievement.color : Colors.grey[600],
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
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
}