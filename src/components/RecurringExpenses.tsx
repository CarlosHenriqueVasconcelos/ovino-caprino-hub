import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Plus, Trash2 } from 'lucide-react';
import { localFinancialAccounts } from '@/lib/financial-service';
import { FinancialAccount } from '@/lib/types';
import FinancialAccountForm from './FinancialAccountForm';
import { format } from 'date-fns';
import { toast } from 'sonner';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

interface RecurringExpensesProps {
  onUpdate?: () => void;
}

export default function RecurringExpenses({ onUpdate }: RecurringExpensesProps) {
  const [accounts, setAccounts] = useState<FinancialAccount[]>([]);
  const [showForm, setShowForm] = useState(false);

  const loadAccounts = () => {
    const allAccounts = localFinancialAccounts.all();
    setAccounts(allAccounts.filter(a => a.is_recurring && !a.parent_id));
    onUpdate?.();
  };

  useEffect(() => {
    loadAccounts();
  }, []);

  const handleDelete = (id: string) => {
    if (confirm('Deseja realmente excluir esta despesa recorrente? Isso não afetará as contas já geradas.')) {
      localFinancialAccounts.delete(id);
      toast.success('Despesa recorrente excluída');
      loadAccounts();
    }
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-center">
          <CardTitle>Despesas Recorrentes</CardTitle>
          <Button onClick={() => setShowForm(true)}>
            <Plus className="mr-2 h-4 w-4" /> Nova Recorrente
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Categoria</TableHead>
              <TableHead>Descrição</TableHead>
              <TableHead>Valor</TableHead>
              <TableHead>Frequência</TableHead>
              <TableHead>Início</TableHead>
              <TableHead>Fim</TableHead>
              <TableHead>Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {accounts.map((account) => (
              <TableRow key={account.id}>
                <TableCell>{account.category}</TableCell>
                <TableCell>{account.description}</TableCell>
                <TableCell>R$ {account.amount.toFixed(2)}</TableCell>
                <TableCell>{account.recurrence_frequency}</TableCell>
                <TableCell>{format(new Date(account.due_date), 'dd/MM/yyyy')}</TableCell>
                <TableCell>{account.recurrence_end_date ? format(new Date(account.recurrence_end_date), 'dd/MM/yyyy') : 'Indefinido'}</TableCell>
                <TableCell>
                  <Button size="sm" variant="outline" onClick={() => handleDelete(account.id)}>
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        {showForm && (
          <FinancialAccountForm
            type="despesa"
            onClose={() => setShowForm(false)}
            onSave={() => { loadAccounts(); setShowForm(false); }}
          />
        )}
      </CardContent>
    </Card>
  );
}
