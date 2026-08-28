Finanzas_GT/ <---- Proyecto Original
│
├── assets/
│     ├── animations/
│     │       ├── Blooming_Flowers.json <------- Migrado
│     │       ├── growing.json <------- Migrado
│     │       ├── little_sun.json <------- Migrado
│     │       ├── rain.json <------- Migrado
│     │       ├── tree_growth_without_background.json <------- Migrado
│     │       ├── weather.json <------- Migrado
│     │       ├── images/
│     │       └── sounds/
│     │
├── docs/
│     └── diagrama.md
│
├── lib/
│    ├── app/
│    │    ├── layout/
│    │    │     └── main_layout.dart
│    │    ├── router/
│    │    └── theme/
│    ├── features/
│    │       ├── auth/
│    │       │     ├── data/
│    │       │     │     ├── models/
│    │       │     │     │     └── user_model.dart <------- Migrado
│    │       │     │     └── repositories/
│    │       │     │            └── auth_repository.dart <------- Migrado
│    │       │     └── presentation/
│    │       │             ├── providers/
│    │       │             │     ├── user_provider.dart <------- Migrado
│    │       │             └── screens/
│    │       │                    ├── auth_screen.dart <------- Migrado
│    │       │                    ├── forgot_password_screen.dart <------- Migrado
│    │       │                    ├── link_email_screen.dart <------- Migrado
│    │       │                    ├── setup_profile_screen.dart <------- Migrado
│    │       │                    └── welcome_screen.dart <------- Migrado
│    │       ├── budgets/
│    │       │     ├── data/
│    │       │     │     ├── repositories/
│    │       │     │     │        └── budget_repository.dart <------- Migrado
│    │       │     │     └──providers/
│    │       │     │            └── budget_provider.dart <------- Migrado
│    │       │     └── presentation/
│    │       │             ├── screens/
│    │       │             │     ├── add_debt_screen.dart <------- Migrado
│    │       │             │     ├── budget_config_screen.dart <------- Migrado
│    │       │             │     ├── budget_screen.dart  <------- Migrado
│    │       │             │     ├── fixed_expenses_screen.dart <------- Migrado
│    │       │             │     ├── flexible_expenses_screen.dart <------- Migrado
│    │       │             │     └── debts_screen.dart <------- Migrado
│    │       │             └──widgets/
│    │       │                  ├── budget_bar_chat.dart <------- Migrado
│    │       │                  ├── budget_card.dart <------- Migrado
│    │       │                  └── expense_pie_chat.dart <------- Migrado
│    │       ├── dashboard/
│    │       │     └── presentation/
│    │       │             └── screens/
│    │       │                   └── dashboard_screen.dart <------- Migrado
│    │       ├── education/
│    │       │     ├── data/
│    │       │     │     ├── models/
│    │       │     │     │     └── lesson_model.dart <------- Migrado
│    │       │     │     ├── providers/
│    │       │     │     │     └── lesson_provider.dart <------- Migrado
│    │       │     │     └── lesson_data.dart <------- Migrado
│    │       │     └── presentation/
│    │       │             └── screens/
│    │       │                    ├── lesson/
│    │       │                    │   ├── emergency_fund_edu_screen.dart <------- Migrado
│    │       │                    │   ├── learning_path_screen.dart <------- Migrado
│    │       │                    │   ├── interative_lesson_screen.dart <------- Migrado
│    │       │                    │   └── lesson_50_30_20_screen.dart <------- Migrado
│    │       │                    └── education_screen.dart <------- Migrado
│    │       ├── goals/
│    │       │     ├── data/
│    │       │     │     ├── models/
│    │       │     │     │     │── debt_model.dart <------- Migrado
│    │       │     │     │     ├── goal_model.dart <------- Migrado
│    │       │     │     ├── providers/
│    │       │     │     │       ├── debt_provider.dart <------- Migrado
│    │       │     │     │       └── GoalProvider.dart <------- Migrado
│    │       │     │     └── repositories/
│    │       │     │             └── goal_repository.dart <------- Migrado
│    │       │     └── presentation/
│    │       │             └── screens/
│    │       │                   └── saving_goals_screen.dart <------- Migrado
│    │       ├── Onboarding/
│    │       │       └── onboarding.dart
│    │       ├── profile/
│    │       │     └── presentation/
│    │       │             ├── components/
│    │       │             │       └── feedback_botton_sheet.dart <------- Migrado
│    │       │             └── screens/
│    │       │                    ├── profile_anon_screen.dart <------- Migrado
│    │       │                    ├── profile_registered_screen.dart <------- Migrado
│    │       │                    └── profile_screen.dart <------- Migrado
│    │       ├── reports/
│    │       │      └── reports_screen.dart <------- Migrado
│    │       ├── sanctuary/
│    │       │     ├── data/
│    │       │     │     ├── providers/
│    │       │     │           └── sanctuary_provider.dart <------- Migrado
│    │       │     └── presentation/
│    │       │             └── screens/
│    │       │                   ├── add_goal_screen.dart <------- Migrado
│    │       │                   └── sactuary_screen.dart <------- Migrado
│    │       ├── transactions/
│    │       │     ├── data/
│    │       │     │     ├── models/
│    │       │     │     │     └── transaction_model.dart <------- Migrado
│    │       │     │     ├── providers/
│    │       │     │     │     └──  transaction_provider.dart <------- Migrado
│    │       │     │     └── repositories/
│    │       │     │     │     └── transaction_repository.dart <------- Migrado
│    │       │     └── presentation/
│    │       │             └── screens/
│    │       │                     ├── add_transaction_screen.dart <------- Migrado
│    │       │                     └── manage_ccategories_screen.dart <------- Migrado
│    ├── firebase_options.dart
     └── main.dart <------- Migrado
