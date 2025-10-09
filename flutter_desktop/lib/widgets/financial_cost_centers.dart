import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/financial_account.dart';
import 'package:uuid/uuid.dart';

class FinancialCostCentersScreen extends StatefulWidget {
  final VoidCallback? onUpdate;

  const FinancialCostCentersScreen({super.key, this.onUpdate});

  @override
  State<FinancialCostCentersScreen> createState() => _FinancialCostCentersScreenState();
}

class _FinancialCostCentersScreenState extends State<FinancialCostCentersScreen> {
  final FinancialService _financialService = FinancialService();
  List<CostCenter> costCenters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCostCenters();
  }

  Future<void> _loadCostCenters() async {
    setState(() => isLoading = true);
    
    final centers = await _financialService.getAllCostCenters();
    
    setState(() {
      costCenters = centers;
      isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Centro de Custo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final costCenter = CostCenter(
        id: const Uuid().v4(),
        name: nameController.text,
        description: descriptionController.text.isEmpty ? null : descriptionController.text,
        createdAt: DateTime.now(),
      );

      await _financialService.createCostCenter(costCenter);
      await _loadCostCenters();
      widget.onUpdate?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Centro de custo criado com sucesso')),
        );
      }
    }
  }

  Future<void> _deleteCostCenter(CostCenter costCenter) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este centro de custo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _financialService.deleteCostCenter(costCenter.id);
      await _loadCostCenters();
      widget.onUpdate?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Centro de custo excluído com sucesso')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : costCenters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum centro de custo cadastrado',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Centro de Custo'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: costCenters.length,
                  itemBuilder: (context, index) {
                    final center = costCenters[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          child: const Icon(Icons.business, color: Colors.blue),
                        ),
                        title: Text(
                          center.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: center.description != null
                            ? Text(center.description!)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCostCenter(center),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: costCenters.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
