// lib/features/health/screens/health_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import 'weight_log_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadHealthData();
    });
  }

  // Calculate BMI
  double _calculateBMI(double weightKg, int heightCm) {
    if (weightKg <= 0 || heightCm <= 0) return 0;
    double heightM = heightCm / 100;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  // Get BMI Category
  String _getBMICategory(double bmi) {
    if (bmi == 0) return 'Not available';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Get BMI Color
  Color _getBMIColor(double bmi) {
    if (bmi == 0) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  // Calculate BMR (Mifflin-St Jeor Equation)
  int _calculateBMR(int age, double weightKg, int heightCm, String? gender) {
    if (age <= 0 || weightKg <= 0 || heightCm <= 0) return 0;
    
    if (gender?.toLowerCase() == 'male') {
      return (10 * weightKg + 6.25 * heightCm - 5 * age + 5).round();
    } else {
      return (10 * weightKg + 6.25 * heightCm - 5 * age - 161).round();
    }
  }

  // Calculate TDEE based on activity level
  int _calculateTDEE(int bmr, String? activityLevel) {
    if (bmr == 0) return 0;
    
    switch (activityLevel?.toLowerCase()) {
      case 'sedentary':
        return (bmr * 1.2).round();
      case 'light':
        return (bmr * 1.375).round();
      case 'moderate':
        return (bmr * 1.55).round();
      case 'active':
        return (bmr * 1.725).round();
      case 'very active':
        return (bmr * 1.9).round();
      default:
        return (bmr * 1.55).round();
    }
  }

  // Get activity level from fitness level
  String _getActivityLevel(String? fitnessLevel) {
    if (fitnessLevel == null) return 'Moderate';
    
    if (fitnessLevel.contains('Beginner')) return 'Light';
    if (fitnessLevel.contains('Intermediate')) return 'Moderate';
    if (fitnessLevel.contains('Advanced')) return 'Active';
    if (fitnessLevel.contains('Athlete')) return 'Very Active';
    
    return 'Moderate';
  }

  String _getDayLetter(int index) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[index];
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day} ${_getMonthShort(start.month)} - ${end.day} ${_getMonthShort(end.month)}';
  }

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Get goal target based on fitness goal
  int _getGoalTarget(String? fitnessGoal) {
    if (fitnessGoal == null) return 20;
    
    if (fitnessGoal.contains('Lose weight')) return 30;
    if (fitnessGoal.contains('Build muscle')) return 40;
    if (fitnessGoal.contains('Increase strength')) return 36;
    if (fitnessGoal.contains('Improve endurance')) return 24;
    if (fitnessGoal.contains('Stay healthy')) return 20;
    if (fitnessGoal.contains('Rehab')) return 15;
    if (fitnessGoal.contains('competition')) return 50;
    
    return 20;
  }

  // Get recommendation based on REAL data
  String _getWorkoutRecommendation(int workoutsThisWeek, int streakDays) {
    if (workoutsThisWeek == 0) {
      return 'Start with 2-3 workouts this week to build momentum';
    } else if (workoutsThisWeek < 3) {
      return 'Try to work out 3-4 times per week for better results';
    } else if (streakDays > 7) {
      return 'Great consistency! Add variety to your workouts';
    } else {
      return 'You\'re on track! Keep up the good work';
    }
  }

  // Get nutrition recommendation based on BMI
  String _getNutritionRecommendation(double bmi) {
    if (bmi == 0) return 'Complete your profile to get nutrition tips';
    if (bmi < 18.5) return 'Focus on calorie-dense nutritious foods to gain healthy weight';
    if (bmi < 25) return 'Maintain balanced macros: 40% carbs, 30% protein, 30% fat';
    if (bmi < 30) return 'Focus on protein intake to preserve muscle while losing fat';
    return 'Consult a nutritionist for a personalized plan';
  }

  Widget _buildWeekCard(BuildContext context, Map<String, dynamic> weekData, int index) {
    final theme = Theme.of(context);
    final dailyMinutes = List<int>.from(weekData['dailyMinutes']);
    final total = weekData['totalMinutes'];
    final avg = weekData['averageMinutes'];
    final startDate = weekData['startDate'] as DateTime;
    final endDate = weekData['endDate'] as DateTime;
    
    // Determine if this week is better than last week
    final healthProvider = context.read<HealthProvider>();
    final isImproving = index == 0 && healthProvider.getTrendPercentage().contains('+');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImproving ? Colors.green.withOpacity(0.3) : theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'WEEK ${weekData['weekNumber']}',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isImproving) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.green, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            healthProvider.getTrendPercentage(),
                            style: const TextStyle(color: Colors.green, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                _formatDateRange(startDate, endDate),
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Mini bar chart for the week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final minutes = dailyMinutes[dayIndex];
              final barHeight = (minutes / 60) * 40;
              
              return Column(
                children: [
                  Container(
                    height: barHeight.clamp(4, 40),
                    width: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: minutes > 0
                            ? [theme.primaryColor.withOpacity(0.5), theme.primaryColor]
                            : [theme.dividerColor, theme.dividerColor],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayLetter(dayIndex),
                    style: TextStyle(
                      color: minutes > 0 ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                      fontSize: 9,
                      fontWeight: minutes > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (minutes > 0)
                    Text(
                      '$minutes',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const SizedBox(height: 7),
                ],
              );
            }),
          ),
          
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: $total min',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$avg min/day',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
    final userName = onboardingProvider.name ?? 
                    authProvider.userEmail?.split('@')[0] ?? 
                    'User';
    
    final age = onboardingProvider.age ?? 25;
    final weight = onboardingProvider.weight ?? 70.0;
    final height = onboardingProvider.height ?? 175;
    final gender = onboardingProvider.gender;
    final fitnessLevel = onboardingProvider.fitnessLevel;
    final fitnessGoal = onboardingProvider.fitnessGoal;
    
    final bmi = _calculateBMI(weight, height);
    final bmiCategory = _getBMICategory(bmi);
    final bmiColor = _getBMIColor(bmi);
    
    final bmr = _calculateBMR(age, weight, height, gender);
    final activityLevel = _getActivityLevel(fitnessLevel);
    final tdee = _calculateTDEE(bmr, activityLevel);
    
    // REAL data from health provider
    final workoutsThisWeek = healthProvider.workoutsThisWeek;
    final streakDays = healthProvider.streakDays;
    final totalWorkouts = healthProvider.totalWorkouts;
    final totalMinutes = healthProvider.totalMinutes;
    final weeklyData = healthProvider.weeklyData;
    final trendPercentage = healthProvider.getTrendPercentage();
    
    // Calculate health score
    final healthScore = healthProvider.calculateRealHealthScore(
      totalWorkouts: totalWorkouts,
      streakDays: streakDays,
      totalMinutes: totalMinutes,
      caloriesConsumed: healthProvider.totalCaloriesConsumed,
      calorieTarget: tdee,
      bmi: bmi,
      mealsLogged: healthProvider.mealLogs.length,
    );

    // REAL goal target based on fitness goal
    final goalTarget = _getGoalTarget(fitnessGoal);
    final goalProgress = (totalWorkouts / goalTarget).clamp(0, 1);
    final goalPercentage = (goalProgress * 100).round();

    // REAL recommendations
    final workoutRec = _getWorkoutRecommendation(workoutsThisWeek, streakDays);
    final nutritionRec = _getNutritionRecommendation(bmi);

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
          'Health Insights',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: healthProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Hi $userName,',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here\'s your health breakdown',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Overall Health Score Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4158D0),
                            const Color(0xFFC850C0),
                            const Color(0xFFFFCC70),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'HEALTH SCORE',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  healthScore >= 80 ? 'TOP 15%' : 
                                  healthScore >= 60 ? 'GOOD' : 'NEEDS WORK',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                healthScore.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '/100',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Based on your activity, nutrition, and consistency',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Section
                    Text(
                      'YOUR STATS',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // BMI Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bmiColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.monitor_weight,
                                  color: bmiColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'BMI',
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          bmi.toString(),
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bmiCategory,
                                      style: TextStyle(
                                        color: bmiColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: theme.dividerColor, height: 1),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'BMR', // ✅ FIXED: was 'BMI'
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$bmr kcal',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Resting',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color: theme.dividerColor,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'TDEE',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$tdee kcal',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Daily needs',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 10,
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
                    
                    // ✅ ADDED: Explanatory tooltip for stats (fixed text)
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'BMI: Healthy weight range • BMR: Calories at complete rest • TDEE: Your daily calorie target', // ✅ FIXED
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Consistency Section
                    Text(
                      'CONSISTENCY',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'HISTORY',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Last 4 weeks',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Scrollable weeks
                          if (weeklyData.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(Icons.history, size: 48, color: Colors.grey[700]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No workout history yet',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Complete workouts to see your progress!',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: weeklyData.length,
                              itemBuilder: (context, index) {
                                return _buildWeekCard(context, weeklyData[index], index);
                              },
                            ),
                          
                          if (weeklyData.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Divider(color: theme.dividerColor, height: 1),
                            const SizedBox(height: 16),
                            
                            // Summary stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryStat(context, 'Total', '$totalMinutes min', Icons.timer, Colors.blue),
                                _buildSummaryStat(context, 'Avg', '${(totalMinutes / 28).round()} min', Icons.trending_up, Colors.green),
                                _buildSummaryStat(context, 'Trend', trendPercentage, Icons.insights, Colors.orange),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Goal Progress Section with REAL data
                    if (fitnessGoal != null) ...[
                      Text(
                        'GOAL PROGRESS',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.withOpacity(0.2),
                              Colors.teal.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.flag,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fitnessGoal,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$goalPercentage% complete ($totalWorkouts/$goalTarget workouts)',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: goalProgress.toDouble(),
                                backgroundColor: theme.dividerColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Recommendations Section with REAL data
                    Text(
                      'RECOMMENDATIONS',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildRecommendationItem(
                            context,
                            icon: Icons.fitness_center,
                            text: workoutRec,
                            color: Colors.blue,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: theme.dividerColor, height: 1),
                          ),
                          _buildRecommendationItem(
                            context,
                            icon: Icons.restaurant,
                            text: nutritionRec,
                            color: Colors.green,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: theme.dividerColor, height: 1),
                          ),
                          _buildRecommendationItem(
                            context,
                            icon: Icons.water_drop,
                            text: 'Drink 2-3 liters of water daily for optimal performance',
                            color: Colors.lightBlue,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Weight Log Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WeightLogScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.monitor_weight, color: Colors.white),
                        label: const Text(
                          'TRACK YOUR WEIGHT',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
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