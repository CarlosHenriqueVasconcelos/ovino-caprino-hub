import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/feeding_service.dart';
import '../models/feeding_pen.dart';
import 'pen_details_screen.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedingService>(context, listen: false).loadPens();
    });
  }

  Future<void> _showAddPenDialog() async {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar Nova Baia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Baia *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              final feedingService =
                  Provider.of<FeedingService>(context, listen: false);
              final now = DateTime.now().toIso8601String();
              final pen = FeedingPen(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                number: numberController.text.trim().isEmpty
                    ? null
                    : numberController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                createdAt: DateTime.parse(now),
                updatedAt: DateTime.parse(now),
              );

              await feedingService.addPen(pen);

              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPenDialog(FeedingPen pen) async {
    final nameController = TextEditingController(text: pen.name);
    final numberController = TextEditingController(text: pen.number ?? '');
    final notesController = TextEditingController(text: pen.notes ?? '');

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Baia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Baia *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              final feedingService =
                  Provider.of<FeedingService>(context, listen: false);
              final updatedPen = FeedingPen(
                id: pen.id,
                name: nameController.text.trim(),
                number: numberController.text.trim().isEmpty
                    ? null
                    : numberController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                createdAt: pen.createdAt,
                updatedAt: DateTime.now(),
              );

              await feedingService.updatePen(updatedPen);

              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePen(FeedingPen pen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Baia'),
        content: Text(
            'Deseja realmente excluir a baia "${pen.name}"? Todos os tratos associados também serão excluídos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final feedingService =
          Provider.of<FeedingService>(context, listen: false);
      await feedingService.deletePen(pen.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Baia "${pen.name}" excluída com sucesso')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar Baia',
            onPressed: _showAddPenDialog,
          ),
        ],
      ),
      body: Consumer<FeedingService>(
        builder: (context, feedingService, _) {
          if (feedingService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pens = feedingService.pens;

          if (pens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma baia cadastrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddPenDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar Primeira Baia'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: pens.length,
            itemBuilder: (context, index) {
              final pen = pens[index];
              return _buildPenCard(pen);
            },
          );
        },
      ),
    );
  }

  Widget _buildPenCard(FeedingPen pen) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PenDetailsScreen(pen: pen),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade100,
                    Colors.green.shade300,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.agriculture,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pen.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (pen.number != null && pen.number!.isNotEmpty)
                    Text(
                      'Nº ${pen.number}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditPenDialog(pen);
                  } else if (value == 'delete') {
                    _confirmDeletePen(pen);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
