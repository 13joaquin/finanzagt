import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/models/user_model.dart';
import '../features/auth/presentation/providers/user_provider.dart';
import '../features/education/data/providers/lesson_provider.dart';
import '../features/goals/data/providers/GoalProvider.dart';
import '../features/goals/data/providers/debt_provider.dart';
import '../features/transactions/data/providers/transaction_provider.dart';

/// Inicializa los providers financieros que dependen del usuario autenticado.
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  ProviderSubscription<UserModel?>? _userSubscription;
  String? _activeUserId;

  @override
  void initState() {
    super.initState();
    _userSubscription = ref.listenManual<UserModel?>(
      userProvider,
      _handleUserChanged,
      fireImmediately: true,
    );
  }

  void _handleUserChanged(UserModel? previous, UserModel? next) {
    final uid = next?.uid;

    if (_activeUserId == uid) return;

    _activeUserId = uid;

    if (uid == null) {
      ref.read(debtProvider.notifier).updateUser(null);
      ref.invalidate(transactionProvider);
      ref.invalidate(goalProvider);
      ref.invalidate(debtProvider);
      ref.read(lessonProvider.notifier).resetUser();
      return;
    }

    ref.read(transactionProvider.notifier).listenToTransactions(uid);
    ref.read(goalProvider.notifier).listenToGoals(uid);
    ref.read(debtProvider.notifier).updateUser(uid);
    ref.read(lessonProvider.notifier).initializeUser(uid);
  }

  @override
  void dispose() {
    _userSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
