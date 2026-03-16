# Fitness Buddy

A comprehensive fitness tracking application built with Flutter, designed to help users achieve their health and wellness goals through personalized workout plans, nutrition tracking, and progress monitoring.

## 🏆 Features

### Authentication
- Email/password sign-up and login with Supabase
- Google Sign-In integration (ready for OAuth configuration)
- Secure session management
- "Remember me" functionality

### Onboarding Flow
- 12-step personalized onboarding to collect user data:
  - Gender, age, weight, height
  - Fitness goals (fat loss, muscle building, etc.)
  - Workout frequency and duration preferences
  - Fitness level, equipment access, and location
- Progress indicator for each step
- All data stored in Supabase for personalized recommendations

### Workouts
- **Smart program recommendations** based on user goals, level, and equipment
- **4 pre-built programs** with progressive overload:
  - Fat Loss Journey, Muscle Builder, Calisthenics Master, Cardio Challenge
- Weekly workout schedules with rest days
- Detailed workout player with:
  - Exercise videos (MP4) for proper form guidance
  - Set and rep tracking
  - Rest timer with countdown
  - Overall progress bar
- Automatic day advancement after completing scheduled workouts
- "Today's workout" highlighting
- Program enrollment and progress tracking

### Nutrition
- Meal logging with custom meals
- Meal detail screen with macronutrients
- Today's log to track daily intake
- Integration with scoring system

### Health Tracking
- Weight logging with history chart
- Automatic calculation of BMI, BMR, and TDEE
- Streak tracking for workout consistency
- Health score based on activity and nutrition

### Scoring & Achievements
- Points for completing workouts and logging meals
- Activity feed showing recent achievements
- Achievement unlocking system with pop-up notifications

### User Profile
- Editable profile information
- Theme switcher (dark/light mode)
- Units customization (kg/lb, cm/in)
- Notification preferences
- Language selection (English, Spanish, French)
- Terms of Service and Privacy Policy screens

### Additional
- Responsive UI with consistent theming
- Provider for state management
- Supabase for backend (authentication, database, real-time updates)
- SharedPreferences for local settings persistence

## 🛠 Tech Stack

- **Flutter** (SDK ^3.10.4)
- **Dart** (^3.10.4)
- **Supabase** – backend and authentication
- **Provider** – state management
- **SharedPreferences** – local storage
- **flutter_localizations** & **intl** – internationalization
- **video_player** – exercise video playback
- **confetti** – celebration animations
- **flutter_local_notifications** – reminder notifications
- **google_sign_in** – Google authentication

## 📁 Project Structure
lib/
├── core/
│ ├── providers/ # App-level providers (theme, settings)
│ ├── services/ # Notification service
│ └── utils/ # Helpers and constants
├── features/
│ ├── achievements/ # Achievement tracking and popups
│ ├── auth/ # Authentication screens and provider
│ ├── health/ # Health tracking (weight, BMI, streak)
│ ├── home/ # Home screen dashboard
│ ├── nutrition/ # Meal logging and today's log
│ ├── onboarding/ # 12-step onboarding flow
│ ├── profile/ # User profile, settings, terms, privacy
│ ├── scoring/ # Points and activity feed
│ └── workouts/ # Programs, workout player, filters
├── l10n/ # Localization ARB files
├── models/ # Data models
├── routes/ # App routing
└── widgets/ # Reusable UI components

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed ([Install Flutter](https://flutter.dev/docs/get-started/install))
- A Supabase project (free tier works)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd gym_lyna_clean

2. Install Dependecies:
   flutter pub get

3. Set up Supabase:
   ~Create a project at supabase.com
   ~Copy your project URL and anon key
   ~Create a file lib/config/~supabase_config.dart with:

     class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_ANON_KEY';

}
4. Run the app:
flutter run

=====Localization====
The app supports English, Spanish, and French. To modify translations, edit the ARB files in lib/l10n/ and run:
 flutter gen-l10n

📱 Testing the App
Use the email/password sign-up to create a new account and go through the onboarding flow.

For a quick start, you can also sign in with a test account (if you’ve created one in Supabase).

After onboarding, explore the Workouts hub, enroll in a program, and start a workout.

Log meals in the Nutrition section and check your daily progress.

View your health stats and weight history in the Health screen.

🔧 Troubleshooting
If the app fails to build, run flutter clean and flutter pub get again.

For localization errors, ensure the l10n folder is correctly named and ARB files are valid JSON (no comments).

If Google Sign-In fails, it may require OAuth configuration in Google Cloud Console and Supabase – for now, use email sign-up.

🤝 Contributing
This project was developed as a final-year assignment of RUPP Class SLS Y4. Contributions are welcome – feel free to fork and submit pull requests.

📄 License
This project is for educational purposes. Unless u wanna get extreme Shreded dont use this app ..*wink*

Developed by: [Your Name/Team Name]
Date: March 2026
Course: Mobile Application Development – Year 4