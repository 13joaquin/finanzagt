Finanzas_GT/
│
├── assets/
│     ├── animations/
│     │       ├── Blooming_Flowers.json
│     │       ├── growing.json
│     │       ├── little_sun.json
│     │       ├── rain.json
│     │       ├── tree_growth_without_background.json
│     │       ├── weather.json
│     │       ├── images/
│     │       ├── sounds/
├── docs/
│     └── diagrama.md
│
├── lib/
│    ├── data/
│    │     ├── models/
│    │     │     ├── debt_model.dart <------- Migrado
│    │     │     ├── goal_model.dart <------- Migrado
│    │     │     ├── lesson_model.dart
│    │     │     ├── transaction_model.dart <------- Migrado
│    │     │     └── user_model.dart <------- Migrado
│    │     ├── repositories/
│    │     │       ├── auth_repository.dart <------- Migrado
│    │     │       ├── goal_repository.dart <------- Migrado
│    │     │       ├── transaction_repository.dart <------- Migrado
│    │     └── lesson_data.dart
│    ├── providers/
│    │     ├── debt_provider.dart <------- Migrado
│    │     ├── GoalProvider.dart <------- Migrado
│    │     ├── lesson_provider.dart
│    │     ├── sanctuary_provider.dart <------- Migrado
│    │     ├── transaction_provider.dart <------- Migrado
│    │     ├── user_provider.dart <------- Migrado
│    ├── screens/
│    │     ├── auth/
│    │     │    ├── auth_screen.dart <------- Migrado
│    │     │    ├── forgot_password_screen.dart <------- Migrado
│    │     │    ├── link_email_screen.dart <------- Migrado
│    │     │    ├── setup_profile_screen.dart <------- Migrado
│    │     │    └── welcome_screen.dart <------- Migrado
│    │     ├── budget_and_goals/
│    │     │         ├── goals/
│    │     │         │     ├── fixed_expenses_screen.dart
│    │     │         │     ├── flexible_expenses_screen.dart
│    │     │         │     ├── saving_goals_screen.dart <------- Migrado
│    │     │         ├── add_debt_screen.dart
│    │     │         ├── budget_config_screen.dart
│    │     │         ├── budget_screen.dart  <------- Migrado
│    │     │         └── debts_screen.dart
│    │     ├── dashboard/
│    │     │        └── dashboard_screen.dart <------- Migrado
│    │     ├── education/
│    │     │       ├── lesson/
│    │     │       │     ├── emergency_fund_edu_screen.dart
│    │     │       │     ├── interative_lesson_screen.dart
│    │     │       │     └── lesson_50_30_20_screen.dart
│    │     │       └── education_screen.dart
│    │     ├── Onboarding/
│    │     │       └── onboarding.dart
│    │     ├── profile/
│    │     │       ├── components/
│    │     │       │       ├── feedback_botton_sheet.dart
│    │     │       ├── profile_anon/
│    │     │       │       ├── profile_anon_screen.dart
│    │     │       ├── profile_registered_screen.dart
│    │     │       └── profile_screen.dart <------- Migrado
│    │     ├── reports/
│    │     │      └── reports_screen.dart
│    │     ├── sanctuary/
│    │     │       ├── add_goal_screen.dart <------- Migrado
│    │     │       └── sactuary_screen.dart <------- Migrado
│    │     ├── transactions/
│    │     │       ├── learning_path_screen.dart
│    │     │       └── main_layout.dart <------- Migrado
│    ├── widgets/
│    │     ├── budget_bar_chat.dart
│    │     ├── budget_card.dart
│    │     └── expense_pie_chat.dart
│    ├── firebase_options.dart
     └── main.dart
