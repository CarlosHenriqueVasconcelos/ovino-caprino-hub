import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/supabase_service.dart';

class FinancialFormDialog extends StatefulWidget {
  const FinancialFormDialog({super.key});

  @override
  State<FinancialFormDialog> createState() => _FinancialFormDialogState();
}

class _FinancialFormDialogState extends State<FinancialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _type = 'receita';
  String _category = 'Venda de Animais';
  String? _selectedAnimalId;
  DateTime _date = DateTime.now();

  final Map<String, List<String>> _categoriesByType = {
    'receita': [
      'Venda de Animais',
      'Venda de Leite',
      'Venda de Carne', 
      'Aluguel de Reprodutor',
      'Subsídios',
      'Outras Receitas',
    ],
    'despesa': [
      'Ração',
      'Medicamentos',
      'Vacinas',
      'Veterinário',
      'Mão de Obra',
      'Energia Elétrica',
      'Combustível',
      'Manutenção',
      'Impostos',
      'Outras Despesas',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context);
    
    return AlertDialog(
      title: Text(_type == 'receita' ? 'Nova Receita' : 'Nova Despesa'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type Selection
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.trending_up, 
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Receita'),
                          ],
                        ),
                        value: 'receita',
                        groupValue: _type,
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                            _category = _categoriesByType[_type]![0];
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.trending_down, 
                                color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            const Text('Despesa'),
                          ],
                        ),
                        value: 'despesa',
                        groupValue: _type,
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                            _category = _categoriesByType[_type]![0];
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Category
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categoriesByType[_type]!.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount and Date
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Valor (R\$) *',
                          border: const OutlineInputBorder(),
                          prefixText: 'R\$ ',
                          prefixStyle: TextStyle(
                            color: _type == 'receita' 
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          if (double.tryParse(value!.replaceAll(',', '.')) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() {
                              _date = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data *',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Animal (Optional for some categories)
                if (_category == 'Venda de Animais' || _category == 'Aluguel de Reprodutor') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedAnimalId,
                    decoration: const InputDecoration(
                      labelText: 'Animal Relacionado',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Nenhum animal específico'),
                      ),
                      ...animalService.animals.map((animal) {
                        return DropdownMenuItem(
                          value: animal.id,
                          child: Text('${animal.name} (${animal.code})'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAnimalId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveFinancialRecord,
          style: ElevatedButton.styleFrom(
            backgroundColor: _type == 'receita' 
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _saveFinancialRecord() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      
      final financialRecord = {
        'type': _type,
        'category': _category,
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'amount': amount,
        'date': _date.toIso8601String().split('T')[0],
        'animal_id': _selectedAnimalId,
      };

      await SupabaseService.createFinancialRecord(financialRecord);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_type == "receita" ? "Receita" : "Despesa"} registrada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar ${_type}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}