import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/local_db.dart';
import '../models/feeding_pen.dart';
import 'pen_details_screen.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  List<FeedingPen> _pens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPens();
  }

  Future<void> _loadPens() async {
    setState(() => _loading = true);
    final appDb = await AppDatabase.open();
    final List<Map<String, dynamic>> maps = await appDb.db.query(
      'feeding_pens',
      orderBy: 'created_at ASC',
    );
    setState(() {
      _pens = maps.map((m) => FeedingPen.fromMap(m)).toList();
      _loading = false;
    });
  }

  Future<void> _showAddPenDialog() async {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
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

              final appDb = await AppDatabase.open();
              final now = DateTime.now().toIso8601String();
              await appDb.db.insert('feeding_pens', {
                'id': const Uuid().v4(),
                'name': nameController.text.trim(),
                'number': numberController.text.trim().isEmpty ? null : numberController.text.trim(),
                'notes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                'created_at': now,
                'updated_at': now,
              });

              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadPens();
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pens.isEmpty
              ? Center(
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
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _pens.length,
                  itemBuilder: (context, index) {
                    final pen = _pens[index];
                    return _buildPenCard(pen);
                  },
                ),
    );
  }

  Widget _buildPenCard(FeedingPen pen) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PenDetailsScreen(pen: pen),
            ),
          );
          _loadPens();
        },
        child: Container(
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
      ),
    );
  }
}
