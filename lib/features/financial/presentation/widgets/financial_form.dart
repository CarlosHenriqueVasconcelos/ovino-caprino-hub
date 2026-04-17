import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/animal.dart';
import '../../../../models/financial_account.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/financial_service.dart';
import '../../../../utils/animal_display_utils.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBrand50 = Color(0xFFE8F5EE);
const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);

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
      backgroundColor: _kBeige,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pop(context),
                      child: Ink(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _kSurface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: _kText2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditing
                          ? 'Editar ${isRevenue ? 'Receita' : 'Despesa'}'
                          : 'Nova ${isRevenue ? 'Receita' : 'Despesa'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isRevenue ? _kBrand50 : _kErr50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isRevenue ? _kBrand : _kErr)
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: (isRevenue ? _kBrand : _kErr)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isRevenue
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 14,
                              color: isRevenue ? _kBrand : _kErr,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRevenue
                                    ? 'Lançamento de Receita'
                                    : 'Lançamento de Despesa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isRevenue ? _kBrand : _kErr,
                                ),
                              ),
                              Text(
                                isRevenue
                                    ? 'Registre entradas financeiras'
                                    : 'Registre saídas financeiras',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: (isRevenue ? _kBrand : _kErr)
                                      .withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Informações obrigatórias',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kText3,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildFieldContainer(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: _decoration('Categoria *'),
                        items: categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
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
                    ),
                    const SizedBox(height: 7),
                    _buildFieldContainer(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: _decoration('Valor *', prefixText: 'R\$ '),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o valor';
                          }
                          final amount = double.tryParse(value.replaceAll(',', '.'));
                          if (amount == null || amount <= 0) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildFieldContainer(
                      child: TextFormField(
                        controller: _dueDateController,
                        decoration: _decoration(
                          'Data de vencimento *',
                          suffixIcon: const Icon(Icons.calendar_today, size: 16),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Selecione a data'
                            : null,
                      ),
                    ),
                    if (isRevenue && _selectedCategory == 'Venda de Animais') ...[
                      const SizedBox(height: 7),
                      _buildFieldContainer(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedAnimalId,
                          decoration: _decoration('Animal *'),
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
                      ),
                    ],
                    const SizedBox(height: 10),
                    const Text(
                      'Informações opcionais',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kText3,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildFieldContainer(
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: _decoration('Descrição'),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildFieldContainer(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPaymentMethod,
                        decoration: _decoration('Forma de pagamento'),
                        items: _paymentMethods
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildFieldContainer(
                      child: TextFormField(
                        controller: _supplierCustomerController,
                        decoration:
                            _decoration(isRevenue ? 'Cliente' : 'Fornecedor'),
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildFieldContainer(
                      child: TextFormField(
                        controller: _notesController,
                        decoration: _decoration('Observações'),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: _kBeige,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kText2,
                    side: BorderSide(color: _kBorder.withValues(alpha: 0.95)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _saveAccount,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kBrand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    isRevenue ? 'Salvar receita' : 'Salvar despesa',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
      ),
      child: child,
    );
  }

  InputDecoration _decoration(
    String label, {
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      labelStyle: const TextStyle(
        color: _kText3,
        fontSize: 12,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}
