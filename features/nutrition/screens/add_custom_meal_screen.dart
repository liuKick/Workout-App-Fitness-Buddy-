// lib/features/nutrition/screens/add_custom_meal_screen.dart
import 'package:flutter/material.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/app_button.dart';

class AddCustomMealScreen extends StatefulWidget {
  const AddCustomMealScreen({super.key});

  @override
  State<AddCustomMealScreen> createState() => _AddCustomMealScreenState();
}

class _AddCustomMealScreenState extends State<AddCustomMealScreen> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _prepTimeController = TextEditingController();

  String _selectedCategory = 'Breakfast';
  String _selectedDifficulty = 'Medium';
  List<String> _selectedDietary = [];
  List<String> _ingredients = [];

  final List<String> _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Cheat',
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Keto',
    'Low Carb',
    'High Protein',
    'Gluten Free',
  ];

  final TextEditingController _ingredientController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _prepTimeController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientController.text.trim().isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _saveCustomMeal() {
    final customMeal = {
      'category': _selectedCategory,
      'image': '',
      'name': _nameController.text.trim().isEmpty 
          ? 'My Custom Meal' 
          : _nameController.text.trim(),
      'description': 'Custom meal with ${_ingredients.length} ingredients',
      'calories': _caloriesController.text.isEmpty ? 0 : int.parse(_caloriesController.text),
      'protein': _proteinController.text.isEmpty ? 0 : int.parse(_proteinController.text),
      'carbs': _carbsController.text.isEmpty ? 0 : int.parse(_carbsController.text),
      'fat': _fatController.text.isEmpty ? 0 : int.parse(_fatController.text),
      'time': _prepTimeController.text.isEmpty ? 0 : int.parse(_prepTimeController.text),
      'badge': '👤 Custom',
      'badgeColor': Colors.purple,
      'dietary': _selectedDietary,
      'favorite': true,
      'isCustom': true,
      'ingredients': _ingredients,
    };
    
    Navigator.pop(context, customMeal);
  }

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
        title: Text(
          'Create Custom Meal',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Placeholder
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image picker coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add photo',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Meal Name
              Text(
                'MEAL NAME',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              AppTextfield(
                controller: _nameController,
                hintText: 'e.g., My Protein Pancakes',
                prefixIcon: Icons.restaurant,
              ),

              const SizedBox(height: 20),

              // Category Selection
              Text(
                'CATEGORY',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Macros Section
              Text(
                'NUTRITION FACTS',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextfield(
                      controller: _caloriesController,
                      hintText: 'Calories',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextfield(
                      controller: _proteinController,
                      hintText: 'Protein (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextfield(
                      controller: _carbsController,
                      hintText: 'Carbs (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextfield(
                      controller: _fatController,
                      hintText: 'Fat (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Prep Time
              Text(
                'PREP TIME (minutes)',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              AppTextfield(
                controller: _prepTimeController,
                hintText: 'e.g., 15',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.timer,
              ),

              const SizedBox(height: 20),

              // Difficulty
              Text(
                'DIFFICULTY',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _difficulties.map((difficulty) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDifficulty = difficulty;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedDifficulty == difficulty
                              ? Colors.blue.withOpacity(0.2)
                              : cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedDifficulty == difficulty
                                ? Colors.blue
                                : theme.dividerColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            difficulty,
                            style: TextStyle(
                              color: _selectedDifficulty == difficulty
                                  ? Colors.blue
                                  : textColor,
                              fontSize: 14,
                              fontWeight: _selectedDifficulty == difficulty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Dietary Preferences
              Text(
                'DIETARY TAGS',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dietaryOptions.map((option) {
                  final isSelected = _selectedDietary.contains(option);
                  return FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : textColor,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDietary.add(option);
                        } else {
                          _selectedDietary.remove(option);
                        }
                      });
                    },
                    backgroundColor: cardColor,
                    selectedColor: Colors.blue.withOpacity(0.3),
                    checkmarkColor: Colors.blue,
                    side: BorderSide(color: theme.dividerColor),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextfield(
                      controller: _ingredientController,
                      hintText: 'Add ingredient',
                      prefixIcon: Icons.add,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addIngredient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_ingredients.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: _ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.blue, size: 6),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 16),
                              onPressed: () => _removeIngredient(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 30),

              // Save Button
              AppButton(
                text: 'CREATE MEAL',
                onPressed: _saveCustomMeal,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}