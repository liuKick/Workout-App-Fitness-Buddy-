// lib/features/nutrition/screens/meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_log_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import 'today_log_screen.dart';

class MealDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool _isFavorite = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.meal['favorite'] ?? false;
  }

  void _addToLog() async {
    // Create a copy of the meal with the selected quantity
    final mealToAdd = Map<String, dynamic>.from(widget.meal);
    mealToAdd['quantity'] = _quantity;
    
    // Add to meal log provider
    Provider.of<MealLogProvider>(context, listen: false).addMeal(mealToAdd);
    
    // Check for achievements after meal logging
    final healthProvider = context.read<HealthProvider>();
    await healthProvider.checkAchievementsAfterMeal(context);
    
    // LOG SCORING ACTIVITY
    final scoringProvider = context.read<ScoringProvider>();
    await scoringProvider.logMealActivity(
      mealName: widget.meal['name'],
      calories: widget.meal['calories'] * _quantity,
      context: context,
    );
    
    // Show confirmation snackbar with VIEW button and points info
    final achievementProvider = context.read<AchievementProvider>();
    final totalPoints = scoringProvider.totalPoints;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${_quantity}x ${widget.meal['name']} to your log • +5 pts • Total: $totalPoints pts',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TodayLogScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            // ✅ FIXED: Safe back button navigation
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
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
                  // Hero image
                  Hero(
                    tag: meal['name'],
                    child: Image.asset(
                      meal['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: cardColor,
                          child: Center(
                            child: Text(
                              meal['name'][0],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  
                  // Favorite button only (right side)
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : textColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                      ),
                    ),
                  ),
                  // Meal name at bottom of image
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: meal['badgeColor'].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: meal['badgeColor'].withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                meal['badge'],
                                style: TextStyle(
                                  color: meal['badgeColor'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
          
          // Meal Details
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Macro Circle Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroCircle(
                      context,
                      value: '${meal['calories']}',
                      label: 'kcal',
                      color: Colors.orange,
                      icon: Icons.local_fire_department,
                    ),
                    _buildMacroCircle(
                      context,
                      value: '${meal['protein']}g',
                      label: 'Protein',
                      color: Colors.blue,
                      icon: Icons.fitness_center,
                    ),
                    _buildMacroCircle(
                      context,
                      value: '${meal['carbs']}g',
                      label: 'Carbs',
                      color: Colors.green,
                      icon: Icons.energy_savings_leaf,
                    ),
                    _buildMacroCircle(
                      context,
                      value: '${meal['fat']}g',
                      label: 'Fat',
                      color: Colors.purple,
                      icon: Icons.opacity,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor, height: 1),
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal['description'],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor, height: 1),
                const SizedBox(height: 24),
                
                // Ingredients
                Text(
                  'INGREDIENTS',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildIngredientList(meal, theme),
                
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor, height: 1),
                const SizedBox(height: 24),
                
                // Dietary Info
                Text(
                  'DIETARY',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (meal['dietary'] as List).map((diet) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDietColor(diet).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getDietColor(diet).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        diet,
                        style: TextStyle(
                          color: _getDietColor(diet),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor, height: 1),
                const SizedBox(height: 24),
                
                // Prep Time and Difficulty
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        context,
                        icon: Icons.timer,
                        label: 'Prep Time',
                        value: '${meal['time']} min',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        context,
                        icon: Icons.auto_awesome,
                        label: 'Difficulty',
                        value: _getDifficulty(meal['time']),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
      
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: textColor),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: textColor),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Add to log button with points info
              Expanded(
                child: ElevatedButton(
                  onPressed: _addToLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ADD TO LOG • ${meal['calories'] * _quantity} kcal • +5 pts',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCircle(
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
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

  List<Widget> _buildIngredientList(Map<String, dynamic> meal, ThemeData theme) {
    // Mock ingredients - in real app, these would come from the meal data
    List<String> ingredients = [];
    
    if (meal['name'].contains('Avocado')) {
      ingredients = ['2 slices sourdough', '1 avocado', '1 egg', 'Salt and pepper'];
    } else if (meal['name'].contains('Smoothie')) {
      ingredients = ['1 scoop protein', '1 cup berries', '1 cup almond milk', '1 banana'];
    } else if (meal['name'].contains('Chicken Salad')) {
      ingredients = ['150g chicken', '2 cups mixed greens', '10 cherry tomatoes', 'Balsamic'];
    } else if (meal['name'].contains('Poke')) {
      ingredients = ['150g tuna', '1 cup rice', '1/2 avocado', 'Edamame'];
    } else if (meal['name'].contains('Salmon')) {
      ingredients = ['200g salmon', '1 cup asparagus', '1/2 cup quinoa', 'Lemon'];
    } else if (meal['name'].contains('Stir-fry')) {
      ingredients = ['200g beef', '1 bell pepper', '1 cup broccoli', 'Teriyaki'];
    } else if (meal['name'].contains('Yogurt')) {
      ingredients = ['1 cup greek yogurt', '1/4 cup granola', '1/2 cup berries', 'Honey'];
    } else if (meal['name'].contains('Protein Bar')) {
      ingredients = ['Protein blend', 'Peanut butter', 'Chocolate', 'Oats'];
    } else if (meal['name'].contains('Burger')) {
      ingredients = ['2 beef patties', '1 bun', 'Cheddar cheese', 'Lettuce, tomato'];
    } else if (meal['name'].contains('Pizza')) {
      ingredients = ['1 pizza dough', 'Tomato sauce', 'Pepperoni', 'Mozzarella'];
    } else {
      ingredients = ['Ingredient 1', 'Ingredient 2', 'Ingredient 3', 'Ingredient 4'];
    }
    
    return ingredients.map((ingredient) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(Icons.circle, color: Colors.blue, size: 6),
            const SizedBox(width: 8),
            Text(
              ingredient,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getDietColor(String diet) {
    switch (diet) {
      case 'Vegetarian':
        return Colors.green;
      case 'Vegan':
        return Colors.lightGreen;
      case 'Keto':
        return Colors.orange;
      case 'Low Carb':
        return Colors.amber;
      case 'High Protein':
        return Colors.blue;
      case 'Gluten Free':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getDifficulty(int time) {
    if (time < 10) return 'Easy';
    if (time < 20) return 'Medium';
    return 'Hard';
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}