import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/pharmacy_stock.dart';
import '../../services/pharmacy_service.dart';
import '../../utils/responsive_utils.dart';

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
    'Frasco',
    'Spray',
    'Pomada',
    'Pó',
    'Outro'
  ];

  final List<String> _units = ['ml', 'mg', 'g', 'unidade'];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.stock?.medicationName ?? '');
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
      // Garantir que quantityPerUnit seja null quando unitOfMeasure for 'unidade'
      double? quantityPerUnitValue;
      if (_selectedUnit == 'ml' ||
          _selectedUnit == 'mg' ||
          _selectedUnit == 'g') {
        if (_quantityPerUnitController.text.isEmpty) {
          throw Exception(
              'Quantidade por recipiente é obrigatória para $_selectedUnit');
        }
        quantityPerUnitValue = double.tryParse(
            _quantityPerUnitController.text.replaceAll(',', '.'));
      } else {
        quantityPerUnitValue = null; // Forçar null para 'unidade'
      }

      final stock = PharmacyStock(
        id: widget.stock?.id ?? _uuid.v4(),
        medicationName: _nameController.text.trim(),
        medicationType: _selectedType,
        unitOfMeasure: _selectedUnit,
        quantityPerUnit: quantityPerUnitValue,
        totalQuantity:
            double.parse(_totalQuantityController.text.replaceAll(',', '.')),
        minStockAlert: _minStockController.text.isEmpty
            ? null
            : double.tryParse(_minStockController.text.replaceAll(',', '.')),
        expirationDate: _expirationDate,
        createdAt: widget.stock?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pharmacyService =
          Provider.of<PharmacyService>(context, listen: false);
      if (widget.stock == null) {
        await pharmacyService.createMedication(stock);
      } else {
        await pharmacyService.updateMedication(stock.id, stock);
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
    final isMobile = ResponsiveUtils.isMobile(context);
    final dialogWidth = ResponsiveUtils.getDialogWidth(context);
    
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: 700),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.stock == null
                ? 'Novo Medicamento'
                : 'Editar Medicamento'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
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

                if (isMobile) ...[
                  // Mobile: Stack dropdowns vertically
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _types.map((type) {
                      return DropdownMenuItem(
                        value: type, 
                        child: Text(type, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Unidade *',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit, 
                        child: Text(unit, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedUnit = value!);
                    },
                  ),
                ] else ...[
                  // Desktop: Side by side
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: _types.map((type) {
                            return DropdownMenuItem(
                              value: type, 
                              child: Text(type, overflow: TextOverflow.ellipsis),
                            );
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
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Unidade *',
                            border: OutlineInputBorder(),
                          ),
                          items: _units.map((unit) {
                            return DropdownMenuItem(
                              value: unit, 
                              child: Text(unit, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedUnit = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Mostrar campo de quantidade por recipiente apenas para ml/mg/g
                if (_selectedUnit == 'ml' ||
                    _selectedUnit == 'mg' ||
                    _selectedUnit == 'g') ...[
                  TextFormField(
                    controller: _quantityPerUnitController,
                    decoration: InputDecoration(
                      labelText: 'Quantidade por recipiente ($_selectedUnit) *',
                      hintText:
                          'Ex: 20 $_selectedUnit por ${_selectedType.toLowerCase()}',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.water_drop),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantidade por recipiente é obrigatória para $_selectedUnit';
                      }
                      final number =
                          double.tryParse(value.replaceAll(',', '.'));
                      if (number == null || number <= 0) {
                        return 'Quantidade deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                if (isMobile) ...[
                  // Mobile: Stack quantity fields vertically
                  TextFormField(
                    controller: _totalQuantityController,
                    decoration: InputDecoration(
                      labelText: _selectedUnit == 'unidade'
                          ? 'Quantidade Total (unidades) *'
                          : 'Quantidade de Recipientes *',
                      hintText: _selectedUnit == 'unidade'
                          ? 'Número de comprimidos/cápsulas'
                          : 'Número de frascos/ampolas/embalagens',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantidade é obrigatória';
                      }
                      final number =
                          double.tryParse(value.replaceAll(',', '.'));
                      if (number == null || number < 0) {
                        return 'Quantidade inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Estoque Mínimo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning_amber),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  // Desktop: Side by side
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _totalQuantityController,
                          decoration: InputDecoration(
                            labelText: _selectedUnit == 'unidade'
                                ? 'Quantidade Total (unidades) *'
                                : 'Quantidade de Recipientes *',
                            hintText: _selectedUnit == 'unidade'
                                ? 'Número de comprimidos/cápsulas'
                                : 'Número de frascos/ampolas/embalagens',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Quantidade é obrigatória';
                            }
                            final number =
                                double.tryParse(value.replaceAll(',', '.'));
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
                ],
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      locale: const Locale('pt', 'BR'),
                      initialDate: _expirationDate ??
                          DateTime.now().add(const Duration(days: 365)),
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
