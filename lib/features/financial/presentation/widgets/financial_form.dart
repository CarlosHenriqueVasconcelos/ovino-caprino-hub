import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/animal.dart';
import '../../../../models/financial_account.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/financial_service.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_display_utils.dart';

class FinancialFormScreen extends StatefulWidget {
  final String type;
  final FinancialAccount? account;

  const FinancialFormScreen({
    super.key,
    required this.type,
    this.account,
  });

  @override
  State<FinancialFormScreen> createState() => _FinancialFormScreenState();
}

class _FinancialFormScreenState extends State<FinancialFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dueDateController;
  late TextEditingController _supplierCustomerController;
  late TextEditingController _notesController;

  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime? _selectedDueDate;
  String? _selectedAnimalId;
  List<Animal> _animals = [];

  final List<String> _expenseCategories = [
    'Alimentação',
    'Medicamentos',
    'Veterinário',
    'Manutenção',
    'Equipamentos',
    'Energia',
    'Água',
    'Funcionários',
    'Transporte',
    'Outros',
  ];

  final List<String> _revenueCategories = [
    'Venda de Animais',
    'Venda de Leite',
    'Venda de Lã',
    'Serviços',
    'Outros',
  ];

  final List<String> _paymentMethods = [
    'Dinheiro',
    'PIX',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Transferência',
    'Boleto',
    'Cheque',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final animalService = context.read<AnimalService>();
    try {
      final animals = await animalService.searchAnimals(limit: 2000);
      AnimalDisplayUtils.sortAnimalsList(animals);
      if (!mounted) return;
      setState(() {
        _animals = animals;
      });
    } catch (_) {
      // Mantém lista vazia em caso de erro
    }
  }

  void _initializeControllers() {
    final account = widget.account;

    _descriptionController =
        TextEditingController(text: account?.description ?? '');
    _amountController = TextEditingController(
      text: account?.amount.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _dueDateController = TextEditingController(
      text: account != null
          ? DateFormat('dd/MM/yyyy').format(account.dueDate)
          : '',
    );
    _supplierCustomerController =
        TextEditingController(text: account?.supplierCustomer ?? '');
    _notesController = TextEditingController(text: account?.notes ?? '');

    _selectedCategory = account?.category;
    _selectedPaymentMethod = account?.paymentMethod;
    _selectedDueDate = account?.dueDate;
    _selectedAnimalId = account?.animalId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    _supplierCustomerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de vencimento')),
      );
      return;
    }

    if (widget.type == 'receita' &&
        _selectedCategory == 'Venda de Animais' &&
        _selectedAnimalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o animal para a venda')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }

    final account = FinancialAccount(
      id: widget.account?.id ?? const Uuid().v4(),
      type: widget.type,
      category: _selectedCategory ?? '',
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      amount: amount,
      dueDate: _selectedDueDate!,
      status: widget.account?.status ?? 'Pendente',
      paymentMethod: _selectedPaymentMethod,
      animalId: _selectedAnimalId,
      supplierCustomer: _supplierCustomerController.text.isEmpty
          ? null
          : _supplierCustomerController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.account?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final service = context.read<FinancialService>();
    try {
      if (widget.account != null) {
        await service.updateAccount(account);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta atualizada com sucesso')),
          );
        }
      } else {
        await service.createAccount(account);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada com sucesso')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    final isRevenue = widget.type == 'receita';
    final categories = isRevenue ? _revenueCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Editar ${isRevenue ? 'Receita' : 'Despesa'}'
              : 'Nova ${isRevenue ? 'Receita' : 'Despesa'}',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              variant: AppCardVariant.soft,
              child: SectionHeader(
                title: isRevenue ? 'Lançamento de Receita' : 'Lançamento de Despesa',
                subtitle: isRevenue
                    ? 'Registre entradas financeiras com categoria e vencimento.'
                    : 'Registre saídas financeiras para manter o controle atualizado.',
                action: Icon(
                  isRevenue ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isRevenue ? AppColors.success : AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoria *'),
                    items: categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        if (value != 'Venda de Animais') {
                          _selectedAnimalId = null;
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecione uma categoria' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (isRevenue && _selectedCategory == 'Venda de Animais') ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAnimalId,
                      decoration: const InputDecoration(
                        labelText: 'Animal *',
                        helperText:
                            'Quando a conta for paga, o animal será movido para a tabela de vendidos',
                      ),
                      items: _animals.map((animal) {
                        return DropdownMenuItem(
                          value: animal.id,
                          child: Text(
                            AnimalDisplayUtils.getDisplayText(animal),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAnimalId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecione o animal' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Valor *',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Informe o valor';
                      final amount = double.tryParse(value.replaceAll(',', '.'));
                      if (amount == null || amount <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Vencimento *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Selecione a data' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentMethod,
                    decoration:
                        const InputDecoration(labelText: 'Forma de Pagamento'),
                    items: _paymentMethods
                        .map((method) =>
                            DropdownMenuItem(value: method, child: Text(method)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _supplierCustomerController,
                    decoration: InputDecoration(
                      labelText: isRevenue ? 'Cliente' : 'Fornecedor',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Observações'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancelar',
                    fullWidth: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Salvar',
                    fullWidth: true,
                    onPressed: _saveAccount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
