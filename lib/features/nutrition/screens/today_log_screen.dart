// lib/features/nutrition/screens/today_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_log_provider.dart';
import '../../scoring/providers/scoring_provider.dart'; // ✅ ADD THIS IMPORT
import 'nutrition_screen.dart';

class TodayLogScreen extends StatefulWidget {
  const TodayLogScreen({super.key});

  @override
  State<TodayLogScreen> createState() => _TodayLogScreenState();
}

class _TodayLogScreenState extends State<TodayLogScreen> {
  @override
  Widget build(BuildContext context) {
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
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: Text(
          "Today's Log",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showClearDialog,
          ),
        ],
      ),
      body: Consumer<MealLogProvider>(
        builder: (context, mealLog, child) {
          if (mealLog.todayMeals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No meals added yet',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + on meals to add them here',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NutritionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('BROWSE MEALS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Daily Summary Card
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL TODAY',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${mealLog.todayMeals.length} meals',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          context,
                          value: mealLog.totalCalories.toString(),
                          label: 'kcal',
                          color: Colors.orange,
                          icon: Icons.local_fire_department,
                        ),
                        _buildSummaryItem(
                          context,
                          value: '${mealLog.totalProtein}g',
                          label: 'Protein',
                          color: Colors.blue,
                          icon: Icons.fitness_center,
                        ),
                        _buildSummaryItem(
                          context,
                          value: '${mealLog.totalCarbs}g',
                          label: 'Carbs',
                          color: Colors.green,
                          icon: Icons.energy_savings_leaf,
                        ),
                        _buildSummaryItem(
                          context,
                          value: '${mealLog.totalFat}g',
                          label: 'Fat',
                          color: Colors.purple,
                          icon: Icons.opacity,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Meal List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: mealLog.todayMeals.length,
                  itemBuilder: (context, index) {
                    final meal = mealLog.todayMeals[index];
                    return _buildMealCard(context, meal, mealLog);
                  },
                ),
              ),

              // Add More Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NutritionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ADD MORE MEALS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Show options for meal (Delete or Mark as Eaten)
  void _showMealOptions(BuildContext context, Map<String, dynamic> meal, MealLogProvider mealLog) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Meal name
            Text(
              meal['name'],
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${meal['calories'] * (meal['quantity'] as int)} kcal',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            
            // Divider
            Divider(color: Colors.grey[800], height: 1),
            
            // ✅ Mark as Eaten option with scoring integration
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              title: const Text(
                'Mark as Eaten',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Keep in history, counts toward calories',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                // ✅ Log to scoring system
                context.read<ScoringProvider>().logMealActivity(
                  mealName: meal['name'],
                  calories: meal['calories'] * (meal['quantity'] as int),
                  context: context,
                );
                
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${meal['name']} marked as eaten'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            
            // Delete option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Remove from log completely',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                mealLog.removeMeal(meal['name']);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${meal['name']} removed'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 10),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal, MealLogProvider mealLog) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          // Meal Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              meal['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: theme.dividerColor,
                  child: Center(
                    child: Text(
                      meal['name'][0],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Meal Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal['name'],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'x${meal['quantity']}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, 
                           color: Colors.orange.shade300, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${meal['calories'] * (meal['quantity'] as int)} kcal',
                        style: TextStyle(
                          color: Colors.orange.shade300,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'P: ${meal['protein']}g',
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'C: ${meal['carbs']}g',
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'F: ${meal['fat']}g',
                        style: const TextStyle(color: Colors.purple, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal['category'] ?? 'Meal',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Three-dot menu for options
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity controls
              IconButton(
                icon: Icon(Icons.remove_circle_outline, 
                          color: Colors.orange, size: 20),
                onPressed: () {
                  mealLog.decrementQuantity(meal['name']);
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, 
                          color: Colors.green, size: 20),
                onPressed: () {
                  mealLog.incrementQuantity(meal['name']);
                },
              ),
              const SizedBox(width: 4),
              
              // Three-dot menu for options
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey, size: 20),
                onPressed: () => _showMealOptions(context, meal, mealLog),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text(
          'Clear Log',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all meals?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MealLogProvider>(context, listen: false).clearLog();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Log cleared'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}