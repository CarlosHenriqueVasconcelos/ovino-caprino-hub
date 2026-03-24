enum StockStatusFilter { all, lowStock, expiring, expired }

extension StockStatusFilterLabel on StockStatusFilter {
  String get label {
    switch (this) {
      case StockStatusFilter.lowStock:
        return 'Estoque baixo';
      case StockStatusFilter.expiring:
        return 'Vencendo';
      case StockStatusFilter.expired:
        return 'Vencidos';
      case StockStatusFilter.all:
        return 'Todos';
    }
  }
}
