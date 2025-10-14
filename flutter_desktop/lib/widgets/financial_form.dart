import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/financial_service.dart';
import '../models/financial_account.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  }

  void _initializeControllers() {
    final account = widget.account;
    
    _descriptionController = TextEditingController(text: account?.description ?? '');
    _amountController = TextEditingController(
      text: account?.amount.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _dueDateController = TextEditingController(
      text: account != null ? DateFormat('dd/MM/yyyy').format(account.dueDate) : '',
    );
    _supplierCustomerController = TextEditingController(text: account?.supplierCustomer ?? '');
    _notesController = TextEditingController(text: account?.notes ?? '');

    _selectedCategory = account?.category;
    _selectedPaymentMethod = account?.paymentMethod;
    _selectedDueDate = account?.dueDate;
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
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      amount: amount,
      dueDate: _selectedDueDate!,
      status: widget.account?.status ?? 'Pendente',
      paymentMethod: _selectedPaymentMethod,
      supplierCustomer: _supplierCustomerController.text.isEmpty ? null : _supplierCustomerController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.account?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.account != null) {
        await FinancialService.updateAccount(account);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta atualizada com sucesso')),
          );
        }
      } else {
        await FinancialService.createAccount(account);
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
    final categories = widget.type == 'receita' ? _revenueCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Editar ${widget.type == 'receita' ? 'Receita' : 'Despesa'}'
              : 'Nova ${widget.type == 'receita' ? 'Receita' : 'Despesa'}',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
                border: OutlineInputBorder(),
              ),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) => value == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor *',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            const SizedBox(height: 16),

            TextFormField(
              controller: _dueDateController,
              decoration: const InputDecoration(
                labelText: 'Data de Vencimento *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) => value == null || value.isEmpty ? 'Selecione a data' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Forma de Pagamento',
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _supplierCustomerController,
              decoration: InputDecoration(
                labelText: widget.type == 'receita' ? 'Cliente' : 'Fornecedor',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAccount,
                    child: const Text('Salvar'),
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
