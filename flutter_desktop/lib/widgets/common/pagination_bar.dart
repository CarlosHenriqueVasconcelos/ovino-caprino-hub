import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/responsive_utils.dart';

/// Barra de paginação universal com controles completos
/// - Navegação entre páginas (anterior/próximo)
/// - Ir para página específica
/// - Seletor de itens por página (25/50/100)
/// - Contador "Página X de Y"
class PaginationBar extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int> itemsPerPageOptions;
  final bool compact;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
    this.itemsPerPageOptions = const [25, 50, 100],
    this.compact = false,
  });

  @override
  State<PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar> {
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showGoToPageDialog() {
    _pageController.text = (widget.currentPage + 1).toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir para página'),
        content: TextField(
          controller: _pageController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Número da página',
            hintText: '1 - ${widget.totalPages}',
            prefixIcon: const Icon(Icons.tag),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _goToPage(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _goToPage(context),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  void _goToPage(BuildContext dialogContext) {
    final pageNumber = int.tryParse(_pageController.text);
    if (pageNumber == null || pageNumber < 1 || pageNumber > widget.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite um número entre 1 e ${widget.totalPages}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    Navigator.of(dialogContext).pop();
    widget.onPageChanged(pageNumber - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mobile sempre usa versão compacta
    if (widget.compact || ResponsiveUtils.isMobile(context)) {
      return _buildCompactBar(theme);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Navegação
          Row(
            children: [
              IconButton.filled(
                icon: const Icon(Icons.first_page),
                onPressed: widget.currentPage > 0 
                    ? () => widget.onPageChanged(0) 
                    : null,
                tooltip: 'Primeira página',
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.chevron_left),
                onPressed: widget.currentPage > 0
                    ? () => widget.onPageChanged(widget.currentPage - 1)
                    : null,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: 16),
              
              // Contador + botão "Ir para"
              InkWell(
                onTap: _showGoToPageDialog,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Página ${widget.currentPage + 1} de ${widget.totalPages}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              IconButton.filled(
                icon: const Icon(Icons.chevron_right),
                onPressed: widget.currentPage < widget.totalPages - 1
                    ? () => widget.onPageChanged(widget.currentPage + 1)
                    : null,
                tooltip: 'Próxima página',
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.last_page),
                onPressed: widget.currentPage < widget.totalPages - 1
                    ? () => widget.onPageChanged(widget.totalPages - 1)
                    : null,
                tooltip: 'Última página',
              ),
            ],
          ),
          
          // Seletor de itens por página
          if (widget.onItemsPerPageChanged != null)
            Row(
              children: [
                Text(
                  'Itens por página:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: widget.itemsPerPage,
                      items: widget.itemsPerPageOptions
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) widget.onItemsPerPageChanged!(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactBar(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: widget.currentPage > 0
              ? () => widget.onPageChanged(widget.currentPage - 1)
              : null,
        ),
        InkWell(
          onTap: _showGoToPageDialog,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Página ${widget.currentPage + 1} de ${widget.totalPages}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: widget.currentPage < widget.totalPages - 1
              ? () => widget.onPageChanged(widget.currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
