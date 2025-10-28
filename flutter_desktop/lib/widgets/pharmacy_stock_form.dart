import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pharmacy_stock.dart';
import '../services/pharmacy_service.dart';

class PharmacyStockForm extends StatefulWidget {
  final PharmacyStock? stock;

  const PharmacyStockForm({super.key, this.stock});

  @override
  State<PharmacyStockForm> createState() => _PharmacyStockFormState();
}

class _PharmacyStockFormState extends State<PharmacyStockForm> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _nameController;
  late TextEditingController _quantityPerUnitController;
  late TextEditingController _totalQuantityController;
  late TextEditingController _minStockController;

  String _selectedType = 'Ampola';
  String _selectedUnit = 'ml';
  DateTime? _expirationDate;
  bool _isSaving = false;

  final List<String> _types = [
    'Ampola',
    'Comprimido',
    'Frasco',
    'Spray',
    'Pomada',
    'Pó',
    'Outro'
  ];

  final List<String> _units = ['ml', 'mg', 'g', 'comprimido', 'unidade'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.stock?.medicationName ?? '');
    _quantityPerUnitController = TextEditingController(
      text: widget.stock?.quantityPerUnit?.toString() ?? '',
    );
    _totalQuantityController = TextEditingController(
      text: widget.stock?.totalQuantity.toString() ?? '0',
    );
    _minStockController = TextEditingController(
      text: widget.stock?.minStockAlert?.toString() ?? '',
    );

    if (widget.stock != null) {
      _selectedType = widget.stock!.medicationType;
      _selectedUnit = widget.stock!.unitOfMeasure;
      _expirationDate = widget.stock!.expirationDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityPerUnitController.dispose();
    _totalQuantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final stock = PharmacyStock(
        id: widget.stock?.id ?? _uuid.v4(),
        medicationName: _nameController.text.trim(),
        medicationType: _selectedType,
        unitOfMeasure: _selectedUnit,
        quantityPerUnit: _quantityPerUnitController.text.isEmpty
            ? null
            : double.tryParse(_quantityPerUnitController.text.replaceAll(',', '.')),
        totalQuantity: double.parse(_totalQuantityController.text.replaceAll(',', '.')),
        minStockAlert: _minStockController.text.isEmpty
            ? null
            : double.tryParse(_minStockController.text.replaceAll(',', '.')),
        expirationDate: _expirationDate,
        createdAt: widget.stock?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.stock == null) {
        await PharmacyService.createMedication(stock);
      } else {
        await PharmacyService.updateMedication(stock.id, stock);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.stock == null
                ? 'Medicamento cadastrado com sucesso!'
                : 'Medicamento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.stock == null ? 'Novo Medicamento' : 'Editar Medicamento'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Medicamento *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedType = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unidade *',
                          border: OutlineInputBorder(),
                        ),
                        items: _units.map((unit) {
                          return DropdownMenuItem(value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedUnit = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_selectedType == 'Ampola' || _selectedType == 'Frasco') ...[
                  TextFormField(
                    controller: _quantityPerUnitController,
                    decoration: InputDecoration(
                      labelText: 'Quantidade por ${_selectedType == 'Frasco' ? 'Frasco' : 'Ampola'}',
                      hintText: 'Ex: 10 ml',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.water_drop),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalQuantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade Total *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Quantidade é obrigatória';
                          }
                          final number = double.tryParse(value.replaceAll(',', '.'));
                          if (number == null || number < 0) {
                            return 'Quantidade inválida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        decoration: const InputDecoration(
                          labelText: 'Estoque Mínimo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.warning_amber),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _expirationDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Validade',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _expirationDate == null
                          ? 'Selecione a data'
                          : '${_expirationDate!.day.toString().padLeft(2, '0')}/${_expirationDate!.month.toString().padLeft(2, '0')}/${_expirationDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
