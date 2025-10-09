import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Plus, Check, Trash2, Pencil } from 'lucide-react';
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
import { Badge } from '@/components/ui/badge';

interface AccountsReceivableProps {
  onUpdate?: () => void;
}

export default function AccountsReceivable({ onUpdate }: AccountsReceivableProps) {
  const [accounts, setAccounts] = useState<FinancialAccount[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingAccount, setEditingAccount] = useState<FinancialAccount | undefined>();

  const loadAccounts = () => {
    const allAccounts = localFinancialAccounts.all();
    setAccounts(allAccounts.filter(a => a.type === 'receita').sort((a, b) => a.due_date.localeCompare(b.due_date)));
    onUpdate?.();
  };

  useEffect(() => {
    loadAccounts();
  }, []);

  const handleMarkAsPaid = (id: string) => {
    localFinancialAccounts.markAsPaid(id, format(new Date(), 'yyyy-MM-dd'));
    toast.success('Conta marcada como recebida');
    loadAccounts();
  };

  const handleDelete = (id: string) => {
    if (confirm('Deseja realmente excluir esta conta?')) {
      localFinancialAccounts.delete(id);
      toast.success('Conta excluída');
      loadAccounts();
    }
  };

  const getStatusBadge = (status: string) => {
    const variants: Record<string, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      'Pendente': 'outline',
      'Pago': 'default',
      'Vencido': 'destructive',
      'Cancelado': 'secondary',
    };
    return <Badge variant={variants[status] || 'default'}>{status}</Badge>;
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-center">
          <CardTitle>Contas a Receber</CardTitle>
          <Button onClick={() => { setEditingAccount(undefined); setShowForm(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Nova Receita
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Vencimento</TableHead>
              <TableHead>Categoria</TableHead>
              <TableHead>Descrição</TableHead>
              <TableHead>Cliente</TableHead>
              <TableHead>Valor</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {accounts.map((account) => (
              <TableRow key={account.id}>
                <TableCell>{format(new Date(account.due_date), 'dd/MM/yyyy')}</TableCell>
                <TableCell>{account.category}</TableCell>
                <TableCell>{account.description}</TableCell>
                <TableCell>{account.supplier_customer || '-'}</TableCell>
                <TableCell>R$ {account.amount.toFixed(2)}</TableCell>
                <TableCell>{getStatusBadge(account.status)}</TableCell>
                <TableCell>
                  <div className="flex gap-2">
                    {account.status !== 'Pago' && (
                      <Button size="sm" variant="outline" onClick={() => handleMarkAsPaid(account.id)}>
                        <Check className="h-4 w-4" />
                      </Button>
                    )}
                    <Button size="sm" variant="outline" onClick={() => { setEditingAccount(account); setShowForm(true); }}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button size="sm" variant="outline" onClick={() => handleDelete(account.id)}>
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        {showForm && (
          <FinancialAccountForm
            type="receita"
            account={editingAccount}
            onClose={() => { setShowForm(false); setEditingAccount(undefined); }}
            onSave={() => { loadAccounts(); setShowForm(false); setEditingAccount(undefined); }}
          />
        )}
      </CardContent>
    </Card>
  );
}
