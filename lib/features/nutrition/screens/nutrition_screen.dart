// lib/features/nutrition/screens/nutrition_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meal_detail_screen.dart';
import 'today_log_screen.dart';
import 'add_custom_meal_screen.dart';
import '../providers/meal_log_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _selectedFilterIndex = 0;
  
  // REAL DATA from providers
  int get _caloriesConsumed {
    final mealProvider = context.read<MealLogProvider>();
    return mealProvider.totalCalories;
  }
  
  int get _caloriesGoal {
    final onboarding = context.read<OnboardingProvider>();
    return 2000;
  }
  
  int get _proteinConsumed {
    final mealProvider = context.read<MealLogProvider>();
    return mealProvider.totalProtein;
  }
  
  int get _proteinGoal {
    return 120;
  }

  final List<Map<String, dynamic>> _customMeals = [];

  String _selectedSortOption = 'Recommended';
  final Map<String, bool> _dietaryPreferences = {
    'Vegetarian': false,
    'Vegan': false,
    'Keto': false,
    'Low Carb': false,
    'High Protein': false,
    'Gluten Free': false,
  };
  RangeValues _calorieRange = const RangeValues(0, 1000);
  String _selectedPrepTime = '';
  
  final List<String> _prepTimeOptions = [
    '< 15 min',
    '15-30 min', 
    '30-45 min',
    '45+ min'
  ];

  final List<String> _filters = [
    '🍳 ALL',
    '🥗 Breakfast',
    '🥪 Lunch',
    '🍽️ Dinner',
    '🍿 Snacks',
    '🍔 Cheat',
    '❤️ Favorites',
  ];

  List<Map<String, dynamic>> get _allMeals => [
    ..._builtInMeals,
    ..._customMeals,
  ];

  final List<Map<String, dynamic>> _builtInMeals = [
    // Breakfast
    {
      'category': 'Breakfast',
      'image': 'assets/images/meals/avocado-toast.jpg',
      'name': 'Avocado Toast',
      'description': 'Creamy avocado on whole grain toast with poached egg',
      'calories': 350,
      'protein': 12,
      'carbs': 30,
      'fat': 18,
      'time': 10,
      'badge': '🌟 Popular',
      'badgeColor': Colors.orange,
      'dietary': ['Vegetarian'],
      'favorite': false,
    },
    {
      'category': 'Breakfast',
      'image': 'assets/images/meals/protein-smoothie.jpg',
      'name': 'Protein Smoothie',
      'description': 'Berry blast with whey protein and almond milk',
      'calories': 280,
      'protein': 25,
      'carbs': 20,
      'fat': 8,
      'time': 5,
      'badge': '⚡ Quick',
      'badgeColor': Colors.green,
      'dietary': ['Vegetarian', 'Gluten Free'],
      'favorite': true,
    },
    // Lunch
    {
      'category': 'Lunch',
      'image': 'assets/images/meals/chicken-salad.jpg',
      'name': 'Grilled Chicken Salad',
      'description': 'Mixed greens, grilled chicken, cherry tomatoes, balsamic',
      'calories': 420,
      'protein': 35,
      'carbs': 15,
      'fat': 22,
      'time': 15,
      'badge': '🔥 Most Popular',
      'badgeColor': Colors.orange,
      'dietary': ['Gluten Free', 'High Protein'],
      'favorite': false,
    },
    {
      'category': 'Lunch',
      'image': 'assets/images/meals/pooke-bowl.jpg',
      'name': 'Tuna Poke Bowl',
      'description': 'Fresh tuna, rice, avocado, edamame, sesame',
      'calories': 380,
      'protein': 32,
      'carbs': 40,
      'fat': 12,
      'time': 10,
      'badge': '💪 High Protein',
      'badgeColor': Colors.blue,
      'dietary': ['Gluten Free', 'High Protein'],
      'favorite': false,
    },
    // Dinner
    {
      'category': 'Dinner',
      'image': 'assets/images/meals/salmon-veggie.jpg',
      'name': 'Salmon with Veggies',
      'description': 'Grilled salmon, roasted asparagus, quinoa',
      'calories': 520,
      'protein': 42,
      'carbs': 25,
      'fat': 28,
      'time': 25,
      'badge': '✨ Omega-3 Rich',
      'badgeColor': Colors.purple,
      'dietary': ['Gluten Free', 'Keto'],
      'favorite': true,
    },
    {
      'category': 'Dinner',
      'image': 'assets/images/meals/Beef Stir-Fry with Vegetables.jpg',
      'name': 'Beef Stir-fry',
      'description': 'Sliced beef, bell peppers, broccoli in teriyaki',
      'calories': 580,
      'protein': 38,
      'carbs': 35,
      'fat': 32,
      'time': 20,
      'badge': '🔥 High Energy',
      'badgeColor': Colors.red,
      'dietary': ['High Protein'],
      'favorite': false,
    },
    // Snacks
    {
      'category': 'Snacks',
      'image': 'assets/images/meals/greek-yogurt-with-berry.jpg',
      'name': 'Greek Yogurt Bowl',
      'description': 'Greek yogurt, honey, granola, mixed berries',
      'calories': 180,
      'protein': 15,
      'carbs': 18,
      'fat': 5,
      'time': 2,
      'badge': '🏃 Post-Workout',
      'badgeColor': Colors.green,
      'dietary': ['Vegetarian', 'Gluten Free'],
      'favorite': false,
    },
    {
      'category': 'Snacks',
      'image': 'assets/images/meals/protein_bar.jpg',
      'name': 'Protein Bar',
      'description': 'Chocolate peanut butter protein bar',
      'calories': 220,
      'protein': 18,
      'carbs': 20,
      'fat': 9,
      'time': 1,
      'badge': '⚡ Quick Snack',
      'badgeColor': Colors.orange,
      'dietary': ['Gluten Free', 'High Protein'],
      'favorite': false,
    },
    // Cheat Meals
    {
      'category': 'Cheat',
      'image': 'assets/images/meals/High-Protein Vegan Burgers.jpg',
      'name': 'Double Cheeseburger',
      'description': 'Double beef patty, cheddar, lettuce, tomato, special sauce',
      'calories': 850,
      'protein': 35,
      'carbs': 45,
      'fat': 52,
      'time': 15,
      'badge': '🍟 Cheat Day',
      'badgeColor': Colors.red,
      'dietary': [],
      'favorite': false,
    },
    {
      'category': 'Cheat',
      'image': 'assets/images/meals/peperoni-pizza.jpg',
      'name': 'Pepperoni Pizza',
      'description': 'Thin crust, pepperoni, mozzarella, tomato sauce',
      'calories': 920,
      'protein': 28,
      'carbs': 85,
      'fat': 48,
      'time': 20,
      'badge': '🍕 Weekend Special',
      'badgeColor': Colors.orange,
      'dietary': [],
      'favorite': true,
    },
  ];

  List<Map<String, dynamic>> _getFilteredMeals() {
    return _allMeals.where((meal) {
      if (_selectedFilterIndex != 0) {
        String selectedCategory = _filters[_selectedFilterIndex]
            .replaceAll('🍳 ', '')
            .replaceAll('🥗 ', '')
            .replaceAll('🥪 ', '')
            .replaceAll('🍽️ ', '')
            .replaceAll('🍿 ', '')
            .replaceAll('🍔 ', '')
            .replaceAll('❤️ ', '');
            
        if (selectedCategory == 'Favorites') {
          if (!(meal['favorite'] ?? false)) return false;
        } else if (selectedCategory != 'ALL') {
          if (meal['category'] != selectedCategory) return false;
        }
      }
      
      if (meal['calories'] < _calorieRange.start || meal['calories'] > _calorieRange.end) return false;
      
      if (_selectedPrepTime.isNotEmpty) {
        int mealTime = meal['time'];
        if (_selectedPrepTime == '< 15 min' && mealTime >= 15) return false;
        if (_selectedPrepTime == '15-30 min' && (mealTime < 15 || mealTime > 30)) return false;
        if (_selectedPrepTime == '30-45 min' && (mealTime < 30 || mealTime > 45)) return false;
        if (_selectedPrepTime == '45+ min' && mealTime <= 45) return false;
      }
      
      bool hasActiveDietary = _dietaryPreferences.values.any((value) => value);
      if (hasActiveDietary) {
        bool matchesDietary = false;
        _dietaryPreferences.forEach((diet, isSelected) {
          if (isSelected && (meal['dietary'] as List).contains(diet)) matchesDietary = true;
        });
        if (!matchesDietary) return false;
      }
      
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _sortMeals(List<Map<String, dynamic>> meals) {
    List<Map<String, dynamic>> sortedMeals = List.from(meals);
    switch (_selectedSortOption) {
      case 'Calories: Low to High':
        sortedMeals.sort((a, b) => a['calories'].compareTo(b['calories']));
        break;
      case 'Calories: High to Low':
        sortedMeals.sort((a, b) => b['calories'].compareTo(a['calories']));
        break;
      case 'Protein: High to Low':
        sortedMeals.sort((a, b) => b['protein'].compareTo(a['protein']));
        break;
      case 'Prep Time: Fast first':
        sortedMeals.sort((a, b) => a['time'].compareTo(b['time']));
        break;
    }
    return sortedMeals;
  }

  Map<String, List<Map<String, dynamic>>> _groupMealsByCategory(List<Map<String, dynamic>> meals) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var meal in meals) {
      String category = meal['category'];
      if (!grouped.containsKey(category)) grouped[category] = [];
      grouped[category]!.add(meal);
    }
    return grouped;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'FILTER MEALS',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 20),
                
                const Text('SORT BY', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildRadioOption('Recommended', _selectedSortOption == 'Recommended', (value) {
                  setState(() => _selectedSortOption = 'Recommended');
                }),
                _buildRadioOption('Calories: Low to High', _selectedSortOption == 'Calories: Low to High', (value) {
                  setState(() => _selectedSortOption = 'Calories: Low to High');
                }),
                _buildRadioOption('Calories: High to Low', _selectedSortOption == 'Calories: High to Low', (value) {
                  setState(() => _selectedSortOption = 'Calories: High to Low');
                }),
                _buildRadioOption('Protein: High to Low', _selectedSortOption == 'Protein: High to Low', (value) {
                  setState(() => _selectedSortOption = 'Protein: High to Low');
                }),
                _buildRadioOption('Prep Time: Fast first', _selectedSortOption == 'Prep Time: Fast first', (value) {
                  setState(() => _selectedSortOption = 'Prep Time: Fast first');
                }),
                
                const SizedBox(height: 24),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 20),
                
                const Text('DIETARY PREFERENCES', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 4,
                  children: _dietaryPreferences.keys.map((key) {
                    return _buildCheckboxOption(
                      key, _dietaryPreferences[key]!, (value) {
                        setState(() => _dietaryPreferences[key] = value ?? false);
                      }
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 20),
                
                const Text('CALORIE RANGE', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                RangeSlider(
                  values: _calorieRange,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey[800],
                  labels: RangeLabels('${_calorieRange.start.round()} kcal', '${_calorieRange.end.round()} kcal'),
                  onChanged: (values) => setState(() => _calorieRange = values),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_calorieRange.start.round()} kcal', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('${_calorieRange.end.round()} kcal', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 20),
                
                const Text('PREP TIME', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _prepTimeOptions.map((option) {
                    return _buildTimeChip(
                      option, _selectedPrepTime == option, (selected) {
                        setState(() => _selectedPrepTime = selected ? option : '');
                      }
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSortOption = 'Recommended';
                            _dietaryPreferences.updateAll((key, value) => false);
                            _calorieRange = const RangeValues(0, 1000);
                            _selectedPrepTime = '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('RESET'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('APPLY'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, bool isSelected, Function(dynamic) onChanged) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Radio(
          value: title,
          groupValue: isSelected ? title : null,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        Expanded(
          child: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(String title, bool value, Function(bool?) onChanged) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          checkColor: Colors.white,
          side: BorderSide(color: theme.dividerColor),
        ),
        Expanded(
          child: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String label, bool isSelected, Function(bool) onSelected) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label, style: TextStyle(
        color: isSelected ? Colors.blue : theme.textTheme.bodyLarge?.color,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: theme.cardColor,
      selectedColor: Colors.blue.withOpacity(0.3),
      checkmarkColor: Colors.blue,
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? Colors.blue : theme.dividerColor, width: isSelected ? 1.5 : 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealProvider = context.watch<MealLogProvider>();
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
    // REAL DATA
    final caloriesConsumed = _caloriesConsumed;
    final caloriesGoal = _caloriesGoal;
    final proteinConsumed = _proteinConsumed;
    final proteinGoal = _proteinGoal;
    final remainingProtein = (proteinGoal - proteinConsumed).clamp(0, proteinGoal);
    final progress = caloriesGoal > 0 ? caloriesConsumed / caloriesGoal : 0;
    
    final filteredMeals = _getFilteredMeals();
    final sortedMeals = _sortMeals(filteredMeals);
    final groupedMeals = _groupMealsByCategory(sortedMeals);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ✅ FIXED: Safe back button navigation
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
        title: Text('Nutrition', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: textColor),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const TodayLogScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            color: cardColor,
            onSelected: (value) {
              switch (value) {
                case 'sort_low_cal':
                  setState(() => _selectedSortOption = 'Calories: Low to High');
                  break;
                case 'sort_high_cal':
                  setState(() => _selectedSortOption = 'Calories: High to Low');
                  break;
                case 'sort_high_protein':
                  setState(() => _selectedSortOption = 'Protein: High to Low');
                  break;
                case 'sort_fastest':
                  setState(() => _selectedSortOption = 'Prep Time: Fast first');
                  break;
                case 'reset':
                  setState(() {
                    _selectedSortOption = 'Recommended';
                    _dietaryPreferences.updateAll((key, value) => false);
                    _calorieRange = const RangeValues(0, 1000);
                    _selectedPrepTime = '';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All filters reset'),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort_low_cal',
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text('Calories: Low to High', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_high_cal',
                child: Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text('Calories: High to Low', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_high_protein',
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text('Protein: High to Low', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_fastest',
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text('Prep Time: Fast first', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restart_alt, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Reset All Filters', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text('$caloriesConsumed / $caloriesGoal kcal', 
                              style: TextStyle(color: textColor)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Text('$remainingProtein g left', 
                              style: const TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.8 * progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).round()}% of daily goal',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Chips Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...List.generate(_filters.length, (index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_filters[index]),
                              selected: _selectedFilterIndex == index,
                              onSelected: (selected) => setState(() => _selectedFilterIndex = index),
                              backgroundColor: cardColor,
                              selectedColor: Colors.blue.withOpacity(0.3),
                              checkmarkColor: Colors.blue,
                              labelStyle: TextStyle(
                                color: _selectedFilterIndex == index ? Colors.blue : textColor,
                                fontWeight: _selectedFilterIndex == index ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(color: _selectedFilterIndex == index ? Colors.blue : theme.dividerColor),
                              ),
                            ),
                          );
                        }),
                        
                        // Filter Button
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: GestureDetector(
                            onTap: _showFilterDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.blue.withOpacity(0.5)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.filter_list, color: Colors.blue, size: 18),
                                  SizedBox(width: 4),
                                  Text('FILTER', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('← swipe for more categories', style: TextStyle(color: secondaryTextColor, fontSize: 10)),
                ],
              ),

              const SizedBox(height: 20),

              // Meal Categories
              if (groupedMeals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_menu, size: 60, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text('No meals match your filters', 
                          style: TextStyle(color: secondaryTextColor, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Try adjusting your filters', 
                          style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                ...groupedMeals.keys.map((category) {
                  final meals = groupedMeals[category]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${category.toUpperCase()} (${meals.length})',
                            style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                            child: const Row(
                              children: [
                                Icon(Icons.add, size: 16), 
                                SizedBox(width: 4), 
                                Text('ADD')
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ...meals.map((meal) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => MealDetailScreen(meal: meal)),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    meal['image'], 
                                    width: 70, 
                                    height: 70, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 70, 
                                      height: 70,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          meal['badgeColor'].withOpacity(0.3),
                                          meal['badgeColor'].withOpacity(0.1),
                                        ]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          meal['name'][0],
                                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                                        )
                                      ),
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
                                          Expanded(
                                            child: Text(
                                              meal['name'],
                                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: meal['badgeColor'].withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: meal['badgeColor'].withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              meal['badge'],
                                              style: TextStyle(color: meal['badgeColor'], fontSize: 9, fontWeight: FontWeight.w600)
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        meal['description'],
                                        style: TextStyle(color: secondaryTextColor, fontSize: 12),
                                        maxLines: 2, 
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                                          const SizedBox(width: 2),
                                          Text('${meal['calories']} kcal',
                                            style: const TextStyle(color: Colors.orange, fontSize: 11)),
                                          const SizedBox(width: 8),
                                          Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.timer, color: Colors.grey, size: 12),
                                          const SizedBox(width: 2),
                                          Text('${meal['time']} min', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                          const SizedBox(width: 8),
                                          Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Text('${meal['protein']}g protein',
                                            style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Add to log button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                                    onPressed: () {
                                      Provider.of<MealLogProvider>(context, listen: false).addMeal(meal);
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Added ${meal['name']} to log'),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          action: SnackBarAction(
                                            label: 'VIEW',
                                            textColor: Colors.white,
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              Navigator.push(
                                                context, 
                                                MaterialPageRoute(builder: (context) => const TodayLogScreen()),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    iconSize: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),

              const SizedBox(height: 8),

              // Add Custom Meal Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const AddCustomMealScreen()),
                    );
                    if (result != null) {
                      setState(() => _customMeals.add(result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${result['name']} created!'), 
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text('ADD CUSTOM MEAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}