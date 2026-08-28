import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/budget_repository.dart';


final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final budgetProvider =
NotifierProvider<BudgetProvider, BudgetState>(BudgetProvider.new);

class BudgetState {
  final bool isLoading;
  final String? errorMessage;

  const BudgetState({
    this.isLoading = false,
    this.errorMessage,
  });

  BudgetState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BudgetProvider extends Notifier<BudgetState> {
  BudgetRepository get _repository => ref.read(budgetRepositoryProvider);

  @override
  BudgetState build() {
    return const BudgetState();
  }

  Future<Map<String, dynamic>?> loadBudget(String uid) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final budget = await _repository.getBudget(uid);

      state = state.copyWith(
        isLoading: false,
      );

      return budget;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      return null;
    }
  }

  Future<bool> saveBudget({
    required String uid,
    required double monthlyIncome,
    required double limitNeeds,
    required double limitWants,
    required double limitSavings,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.saveBudget(
        uid: uid,
        monthlyIncome: monthlyIncome,
        limitNeeds: limitNeeds,
        limitWants: limitWants,
        limitSavings: limitSavings,
      );

      state = state.copyWith(
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }
}