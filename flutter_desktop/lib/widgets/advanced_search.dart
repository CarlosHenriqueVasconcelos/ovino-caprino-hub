import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../data/animal_repository.dart';
import '../models/animal.dart';
import '../widgets/animal_card.dart';
import '../widgets/animal_form.dart';
import '../services/animal_delete_cascade.dart';


class AdvancedSearchDialog extends StatefulWidget {
  const AdvancedSearchDialog({super.key});

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  final _searchController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedGender;
  String? _selectedStatus;
  String? _selectedBreed;
  bool? _pregnant;
  double? _minWeight;
  double? _maxWeight;
  int? _minAge;
  int? _maxAge;
 
  bool _includeSold = false;
  List<Animal> _filteredAnimals = [];
  bool _hasSearched = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context);
    
    // Get unique values for dropdowns
    final breeds = animalService.animals
        .map((animal) => animal.breed)
        .toSet()
        .toList()
        ..sort();

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Busca Avançada de Animais',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search Filters
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Panel
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtros',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Text Search
                              TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  labelText: 'Nome ou Código',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Species
                              DropdownButtonFormField<String>(
                                value: _selectedSpecies,
                                decoration: const InputDecoration(
                                  labelText: 'Espécie',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Todas')),
                                  const DropdownMenuItem(value: 'Ovino', child: Text('Ovino')),
                                  const DropdownMenuItem(value: 'Caprino', child: Text('Caprino')),
                                ],
                                onChanged: (value) => setState(() => _selectedSpecies = value),
                              ),
                              const SizedBox(height: 16),
                              
                              // Gender
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Sexo',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Todos')),
                                  const DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                                  const DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                                ],
                                onChanged: (value) => setState(() => _selectedGender = value),
                              ),
                              const SizedBox(height: 16),
                              
                              // Status
                              DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Todos')),
                                  const DropdownMenuItem(value: 'Saudável', child: Text('Saudável')),
                                  const DropdownMenuItem(value: 'Em tratamento', child: Text('Em tratamento')),
                                  const DropdownMenuItem(value: 'Reprodutor', child: Text('Reprodutor')),
                                  const DropdownMenuItem(value: 'Vendido', child: Text('Vendido')),
                                ],
                                onChanged: (value) => setState(() => _selectedStatus = value),
                              ),
                              const SizedBox(height: 16),
                              
                              SwitchListTile(
                                title: const Text('Incluir vendidos'),
                                value: _includeSold,
                                onChanged: (v) {
                                  setState(() => _includeSold = v);
                                  // Se você tiver algum método de recalcular, chame aqui (opcional):
                                  // _performSearch(animalService.animals);
                                },
                              ),
                              // Breed
                              DropdownButtonFormField<String>(
                                value: _selectedBreed,
                                decoration: const InputDecoration(
                                  labelText: 'Raça',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Todas')),
                                  ...breeds.map((breed) => DropdownMenuItem(
                                    value: breed,
                                    child: Text(breed),
                                  )),
                                ],
                                onChanged: (value) => setState(() => _selectedBreed = value),
                              ),
                              const SizedBox(height: 16),
                              
                              // Pregnancy Status
                              DropdownButtonFormField<bool>(
                                value: _pregnant,
                                decoration: const InputDecoration(
                                  labelText: 'Gestação',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Todas')),
                                  DropdownMenuItem(value: true, child: Text('Gestantes')),
                                  DropdownMenuItem(value: false, child: Text('Não gestantes')),
                                ],
                                onChanged: (value) => setState(() => _pregnant = value),
                              ),
                              const SizedBox(height: 16),
                              
                              // Weight Range
                              Text('Peso (kg)', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Mín',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        _minWeight = double.tryParse(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Máx',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        _maxWeight = double.tryParse(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Age Range
                              Text('Idade (meses)', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Mín',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        _minAge = int.tryParse(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Máx',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        _maxAge = int.tryParse(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _clearFilters,
                                      child: const Text('Limpar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _performSearch(animalService.animals),
                                      child: const Text('Buscar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Results Panel
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Resultados',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_hasSearched) ...[
                                  const Spacer(),
                                  Text(
                                    '${_filteredAnimals.length} animal(is) encontrado(s)',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Expanded(
                              child: !_hasSearched
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            size: 64,
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Configure os filtros e clique em Buscar',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _filteredAnimals.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                size: 64,
                                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Nenhum animal encontrado',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tente ajustar os filtros de busca',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : GridView.builder(
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.75,
                                          ),
                                          itemCount: _filteredAnimals.length,
                                          itemBuilder: (context, index) {
                                            return AnimalCard(
                                              animal: _filteredAnimals[index],
                                              repository: context.read<AnimalRepository>(),
                                              onEdit: (animal) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AnimalFormDialog(animal: animal),
                                                );
                                              },
                                               onDeleteCascade: (animal) async {
                                                await AnimalDeleteCascade.delete(animal.id);
                                                final svc = Provider.of<AnimalService>(context, listen: false);
                                                await svc.loadData();                 // recarrega
                                                setState(() {
                                                  _performSearch(svc.animals);       // re-filtra a lista
                                                });
                                              },

                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
                      ),
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

  void _performSearch(List<Animal> allAnimals) {
    final query = _searchController.text.toLowerCase();
    
    _filteredAnimals = allAnimals.where((animal) {
      // Text search
      if (query.isNotEmpty) {
        final nameMatch = animal.name.toLowerCase().contains(query);
        final codeMatch = animal.code.toLowerCase().contains(query);
        if (!nameMatch && !codeMatch) return false;
      }

      // Sold toggle
      if (!_includeSold && animal.status == 'Vendido') {
        return false;
      }
      
      // Species filter
      if (_selectedSpecies != null && animal.species != _selectedSpecies) {
        return false;
      }
      
      // Gender filter
      if (_selectedGender != null && animal.gender != _selectedGender) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus != null && animal.status != _selectedStatus) {
        return false;
      }
      
      // Breed filter
      if (_selectedBreed != null && animal.breed != _selectedBreed) {
        return false;
      }
      
      // Pregnancy filter
      if (_pregnant != null && animal.pregnant != _pregnant) {
        return false;
      }
      
      // Weight filter
      if (_minWeight != null && animal.weight < _minWeight!) {
        return false;
      }
      if (_maxWeight != null && animal.weight > _maxWeight!) {
        return false;
      }
      
      // Age filter
      if (_minAge != null || _maxAge != null) {
        final now = DateTime.now();
        final ageInMonths = (now.year - animal.birthDate.year) * 12 + 
                          (now.month - animal.birthDate.month);
        
        if (_minAge != null && ageInMonths < _minAge!) {
          return false;
        }
        if (_maxAge != null && ageInMonths > _maxAge!) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    setState(() {
      _hasSearched = true;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSpecies = null;
      _selectedGender = null;
      _selectedStatus = null;
      _selectedBreed = null;
      _pregnant = null;
      _minWeight = null;
      _maxWeight = null;
      _minAge = null;
      _maxAge = null;
      _filteredAnimals = [];
      _hasSearched = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}