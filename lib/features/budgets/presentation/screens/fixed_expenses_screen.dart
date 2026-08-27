import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_provider.dart';




class FixedExpensesScreen extends ConsumerStatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  ConsumerState<FixedExpensesScreen> createState() =>
      _FixedExpensesScreenState();
}

class _FixedExpensesScreenState
    extends ConsumerState<FixedExpensesScreen> {
  final TextEditingController _amountController =
  TextEditingController();

  final TextEditingController _titleController =
  TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREAR GASTO FIJO
  // ============================================================

  Future<void> _saveNewExpense(
      String uid,
      String title,
      double amount,
      ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fixed_expenses')
          .add({
        'title': title,
        'amount': amount,
        'isPaid': false,
        'color': '#4A47F6',
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto fijo creado correctamente.'),
        ),
      );
    } catch (e) {
      debugPrint('Error guardando gasto fijo: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar el gasto fijo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ACTUALIZAR GASTO FIJO
  // ============================================================

  Future<void> _updateExpense(
      String uid,
      String docId,
      String title,
      double amount,
      ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fixed_expenses')
          .doc(docId)
          .update({
        'title': title,
        'amount': amount,
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gasto fijo actualizado correctamente.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error actualizando gasto fijo: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar el gasto fijo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ELIMINAR GASTO FIJO
  // ============================================================

  Future<void> _deleteExpense(
      String uid,
      String docId,
      ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fixed_expenses')
          .doc(docId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gasto fijo eliminado correctamente.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error borrando gasto fijo: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo eliminar el gasto fijo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // REGISTRAR PAGO DEL GASTO FIJO
  //
  // IMPORTANTE:
  // Esta operación permanece atómica porque modifica:
  // - safe_balance
  // - net_worth
  // - transactions
  //
  // No se sustituye por TransactionRepository.addTransaction()
  // porque actualmente ese método NO actualiza esos saldos.
  // ============================================================

  Future<void> _payFixedExpense(
      String uid,
      String docId,
      String title,
      double amount,
      ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);

      final fixedExpenseRef = userRef
          .collection('fixed_expenses')
          .doc(docId);

      final newTransactionRef = userRef
          .collection('transactions')
          .doc();

      await FirebaseFirestore.instance.runTransaction(
            (transaction) async {
          final userSnapshot = await transaction.get(userRef);
          final fixedExpenseSnapshot =
          await transaction.get(fixedExpenseRef);

          if (!userSnapshot.exists) {
            throw Exception('El usuario no existe.');
          }

          if (!fixedExpenseSnapshot.exists) {
            throw Exception(
              'El gasto fijo ya no existe.',
            );
          }

          final userData = userSnapshot.data();

          final currentSafe =
              (userData?['safe_balance'] as num?)?.toDouble() ??
                  0.0;

          final currentNetWorth =
              (userData?['net_worth'] as num?)?.toDouble() ??
                  0.0;

          // Actualizar saldos.
          transaction.update(
            userRef,
            {
              'safe_balance': currentSafe - amount,
              'net_worth': currentNetWorth - amount,
            },
          );

          // Registrar transacción financiera real.
          transaction.set(
            newTransactionRef,
            {
              'title': 'Pago Fijo: $title',
              'amount': amount,
              'type': 'expense',
              'category': 'Gastos Fijos',
              'date': Timestamp.now(),
            },
          );

          // Marcar el gasto como pagado.
          //
          // Se conserva el campo existente del modelo antiguo.
          transaction.update(
            fixedExpenseRef,
            {
              'isPaid': true,
            },
          );
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pago de $title registrado correctamente. ✓',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Error pagando gasto fijo: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo registrar el pago.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final uid = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Gastos Fijos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('fixed_expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudieron cargar los gastos fijos.',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final expenses = snapshot.data?.docs ?? [];

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes gastos fijos',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final doc = expenses[index];
              final data = doc.data();

              final title =
                  data['title'] as String? ??
                      'Gasto Fijo';

              final amount =
                  (data['amount'] as num?)
                      ?.toDouble() ??
                      0.0;

              final isPaid =
                  data['isPaid'] as bool? ?? false;

              return _buildExpenseCard(
                uid: uid,
                docId: doc.id,
                title: title,
                amount: amount,
                isPaid: isPaid,
                color: const Color(0xFF4A47F6),
              );
            },
          );
        },
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : () => _showExpenseFormModal(
          uid: uid,
        ),
        label: const Text(
          'Nuevo Gasto Fijo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor:
        const Color(0xFF4A47F6),
      ),
    );
  }

  // ============================================================
  // MODAL CREAR / EDITAR
  // ============================================================

  void _showExpenseFormModal({
    required String uid,
    String? docId,
    String? currentTitle,
    double? currentAmount,
  }) {
    if (docId != null) {
      _titleController.text =
          currentTitle ?? '';

      _amountController.text =
          currentAmount?.toStringAsFixed(2) ?? '';
    } else {
      _titleController.clear();
      _amountController.clear();
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              modalContext,
            ).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                docId == null
                    ? 'Nuevo Gasto Fijo'
                    : 'Editar Gasto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller:
                _titleController,
                textInputAction:
                TextInputAction.next,
                decoration:
                const InputDecoration(
                  labelText:
                  'Nombre (ej. Alquiler)',
                  border:
                  OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller:
                _amountController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration:
                const InputDecoration(
                  labelText:
                  'Monto (Q)',
                  border:
                  OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    final title =
                    _titleController
                        .text
                        .trim();

                    final amount =
                    double.tryParse(
                      _amountController
                          .text
                          .trim(),
                    );

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(
                        modalContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ingresa el nombre del gasto.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (amount == null ||
                        amount <= 0) {
                      ScaffoldMessenger.of(
                        modalContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ingresa un monto válido mayor que cero.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (docId == null) {
                      _saveNewExpense(
                        uid,
                        title,
                        amount,
                      );
                    } else {
                      _updateExpense(
                        uid,
                        docId,
                        title,
                        amount,
                      );
                    }
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF4A47F6),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TARJETA DE GASTO
  // ============================================================

  Widget _buildExpenseCard({
    required String uid,
    required String docId,
    required String title,
    required double amount,
    required bool isPaid,
    required Color color,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(
            alpha: 0.1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                onSelected:
                _isLoading
                    ? null
                    : (value) {
                  if (value ==
                      'edit') {
                    _showExpenseFormModal(
                      uid: uid,
                      docId: docId,
                      currentTitle:
                      title,
                      currentAmount:
                      amount,
                    );
                  }

                  if (value ==
                      'delete') {
                    _confirmDeleteExpense(
                      uid,
                      docId,
                      title,
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Q${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          if (isPaid)
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Colors.green,
                ),
                SizedBox(width: 6),
                Text(
                  'Pagado',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed:
              _isLoading || isPaid
                  ? null
                  : () => _payFixedExpense(
                uid,
                docId,
                title,
                amount,
              ),
              icon: const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                isPaid
                    ? 'Pago registrado'
                    : 'Registrar Pago',
                style:
                const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                isPaid
                    ? Colors.grey
                    : color,
                disabledBackgroundColor:
                Colors.grey,
                elevation: 0,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRMACIÓN DE ELIMINACIÓN
  // ============================================================

  Future<void> _confirmDeleteExpense(
      String uid,
      String docId,
      String title,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar gasto fijo',
          ),
          content: Text(
            '¿Deseas eliminar "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),
              child:
              const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),
              child:
              const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true &&
        mounted) {
      await _deleteExpense(
        uid,
        docId,
      );
    }
  }
}