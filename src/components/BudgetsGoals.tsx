import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Plus, Trash2, Pencil } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { localBudgets, localCostCenters } from '@/lib/financial-service';
import { Budget } from '@/lib/types';
import { toast } from 'sonner';
import { Progress } from '@/components/ui/progress';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

export default function BudgetsGoals() {
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [costCenters, setCostCenters] = useState(localCostCenters.all());
  const [showForm, setShowForm] = useState(false);
  const [editingBudget, setEditingBudget] = useState<Budget | undefined>();
  const [formData, setFormData] = useState({
    category: '',
    cost_center: '',
    amount: '',
    period: 'Mensal',
    year: new Date().getFullYear().toString(),
    month: (new Date().getMonth() + 1).toString(),
  });

  const loadBudgets = () => {
    const allBudgets = localBudgets.all();
    setBudgets(allBudgets);

    // Load analysis for each budget
    allBudgets.forEach(budget => {
      const analysis = localBudgets.getAnalysis(
        budget.category,
        budget.year,
        budget.month || undefined
      );
      // Store analysis somewhere or display inline
    });
  };

  useEffect(() => {
    loadBudgets();
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.category || !formData.amount || !formData.period || !formData.year) {
      toast.error('Preencha os campos obrigatórios');
      return;
    }

    const budgetData = {
      category: formData.category,
      cost_center: formData.cost_center || undefined,
      amount: parseFloat(formData.amount),
      period: formData.period as any,
      year: parseInt(formData.year),
      month: formData.period === 'Mensal' ? parseInt(formData.month) : undefined,
    };

    if (editingBudget) {
      localBudgets.update(editingBudget.id, budgetData);
      toast.success('Orçamento atualizado');
    } else {
      localBudgets.create(budgetData);
      toast.success('Orçamento criado');
    }

    setFormData({
      category: '',
      cost_center: '',
      amount: '',
      period: 'Mensal',
      year: new Date().getFullYear().toString(),
      month: (new Date().getMonth() + 1).toString(),
    });
    setShowForm(false);
    setEditingBudget(undefined);
    loadBudgets();
  };

  const handleDelete = (id: string) => {
    if (confirm('Deseja realmente excluir este orçamento?')) {
      localBudgets.delete(id);
      toast.success('Orçamento excluído');
      loadBudgets();
    }
  };

  const getBudgetProgress = (budget: Budget) => {
    const analysis = localBudgets.getAnalysis(budget.category, budget.year, budget.month || undefined);
    const percentage = (analysis.spent / budget.amount) * 100;
    return { spent: analysis.spent, percentage: Math.min(percentage, 100) };
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-center">
          <CardTitle>Orçamentos e Metas</CardTitle>
          <Button onClick={() => { setEditingBudget(undefined); setShowForm(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Novo Orçamento
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {budgets.map((budget) => {
            const { spent, percentage } = getBudgetProgress(budget);
            return (
              <div key={budget.id} className="border rounded-lg p-4">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <h4 className="font-semibold">{budget.category}</h4>
                    <p className="text-sm text-muted-foreground">
                      {budget.period} - {budget.month ? `${budget.month}/` : ''}{budget.year}
                      {budget.cost_center && ` • ${budget.cost_center}`}
                    </p>
                  </div>
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" onClick={() => { setEditingBudget(budget); setFormData({
                      category: budget.category,
                      cost_center: budget.cost_center || '',
                      amount: budget.amount.toString(),
                      period: budget.period,
                      year: budget.year.toString(),
                      month: budget.month?.toString() || '',
                    }); setShowForm(true); }}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button size="sm" variant="outline" onClick={() => handleDelete(budget.id)}>
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Gasto: R$ {spent.toFixed(2)}</span>
                    <span>Orçado: R$ {budget.amount.toFixed(2)}</span>
                  </div>
                  <Progress value={percentage} className={percentage > 100 ? 'bg-red-200' : ''} />
                  <p className="text-xs text-muted-foreground">
                    {percentage > 100 ? `Excedeu em ${(percentage - 100).toFixed(1)}%` : `${percentage.toFixed(1)}% utilizado`}
                  </p>
                </div>
              </div>
            );
          })}
        </div>

        {showForm && (
          <Dialog open onOpenChange={(open) => { setShowForm(open); if (!open) setEditingBudget(undefined); }}>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>{editingBudget ? 'Editar' : 'Novo'} Orçamento</DialogTitle>
              </DialogHeader>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <Label htmlFor="category">Categoria *</Label>
                  <Input
                    id="category"
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  />
                </div>

                <div>
                  <Label htmlFor="amount">Valor *</Label>
                  <Input
                    id="amount"
                    type="number"
                    step="0.01"
                    value={formData.amount}
                    onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                  />
                </div>

                <div>
                  <Label htmlFor="period">Período *</Label>
                  <Select value={formData.period} onValueChange={(v) => setFormData({ ...formData, period: v })}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Mensal">Mensal</SelectItem>
                      <SelectItem value="Trimestral">Trimestral</SelectItem>
                      <SelectItem value="Anual">Anual</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="year">Ano *</Label>
                    <Input
                      id="year"
                      type="number"
                      value={formData.year}
                      onChange={(e) => setFormData({ ...formData, year: e.target.value })}
                    />
                  </div>

                  {formData.period === 'Mensal' && (
                    <div>
                      <Label htmlFor="month">Mês *</Label>
                      <Select value={formData.month} onValueChange={(v) => setFormData({ ...formData, month: v })}>
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {Array.from({ length: 12 }, (_, i) => i + 1).map(m => (
                            <SelectItem key={m} value={m.toString()}>{m}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  )}
                </div>

                <div>
                  <Label htmlFor="cost_center">Centro de Custo</Label>
                  <Select value={formData.cost_center} onValueChange={(v) => setFormData({ ...formData, cost_center: v })}>
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione" />
                    </SelectTrigger>
                    <SelectContent>
                      {costCenters.map((cc) => (
                        <SelectItem key={cc.id} value={cc.name}>{cc.name}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="flex justify-end gap-2">
                  <Button type="button" variant="outline" onClick={() => { setShowForm(false); setEditingBudget(undefined); }}>Cancelar</Button>
                  <Button type="submit">Salvar</Button>
                </div>
              </form>
            </DialogContent>
          </Dialog>
        )}
      </CardContent>
    </Card>
  );
}
