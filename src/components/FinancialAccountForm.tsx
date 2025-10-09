import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { Checkbox } from '@/components/ui/checkbox';
import { localFinancialAccounts, localCostCenters } from '@/lib/financial-service';
import { FinancialAccount } from '@/lib/types';
import { format } from 'date-fns';
import { toast } from 'sonner';

interface FinancialAccountFormProps {
  type: 'receita' | 'despesa';
  account?: FinancialAccount;
  onClose: () => void;
  onSave: () => void;
}

export default function FinancialAccountForm({ type, account, onClose, onSave }: FinancialAccountFormProps) {
  const [formData, setFormData] = useState({
    category: account?.category || '',
    description: account?.description || '',
    amount: account?.amount.toString() || '',
    due_date: account?.due_date || format(new Date(), 'yyyy-MM-dd'),
    payment_method: account?.payment_method || '',
    supplier_customer: account?.supplier_customer || '',
    notes: account?.notes || '',
    cost_center: account?.cost_center || '',
    installments: account?.installments?.toString() || '1',
    is_recurring: account?.is_recurring || false,
    recurrence_frequency: account?.recurrence_frequency || 'Mensal',
    recurrence_end_date: account?.recurrence_end_date || '',
  });

  const [costCenters, setCostCenters] = useState(localCostCenters.all());

  const categories = type === 'receita'
    ? ['Venda de Animais', 'Venda de Produtos', 'Serviços', 'Outros']
    : ['Ração', 'Medicamentos', 'Vacinas', 'Veterinário', 'Manutenção', 'Equipamentos', 'Outros'];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.category || !formData.amount || !formData.due_date) {
      toast.error('Preencha os campos obrigatórios');
      return;
    }

    if (account) {
      localFinancialAccounts.update(account.id, {
        category: formData.category,
        description: formData.description,
        amount: parseFloat(formData.amount),
        due_date: formData.due_date,
        payment_method: formData.payment_method,
        supplier_customer: formData.supplier_customer,
        notes: formData.notes,
        cost_center: formData.cost_center,
      });
      toast.success('Conta atualizada');
    } else {
      const accountData = {
        type,
        category: formData.category,
        description: formData.description,
        amount: parseFloat(formData.amount),
        due_date: formData.due_date,
        status: 'Pendente' as const,
        payment_method: formData.payment_method,
        supplier_customer: formData.supplier_customer,
        notes: formData.notes,
        cost_center: formData.cost_center,
        is_recurring: formData.is_recurring,
        recurrence_frequency: formData.is_recurring ? formData.recurrence_frequency as any : undefined,
        recurrence_end_date: formData.is_recurring && formData.recurrence_end_date ? formData.recurrence_end_date : undefined,
        installments: parseInt(formData.installments),
      };

      if (parseInt(formData.installments) > 1) {
        localFinancialAccounts.createInstallments(accountData);
        toast.success(`${formData.installments} parcelas criadas`);
      } else {
        localFinancialAccounts.create(accountData);
        toast.success('Conta criada');
      }
    }

    onSave();
  };

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{account ? 'Editar' : 'Nova'} {type === 'receita' ? 'Receita' : 'Despesa'}</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="category">Categoria *</Label>
              <Select value={formData.category} onValueChange={(v) => setFormData({ ...formData, category: v })}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecione" />
                </SelectTrigger>
                <SelectContent>
                  {categories.map((cat) => (
                    <SelectItem key={cat} value={cat}>{cat}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
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
          </div>

          <div>
            <Label htmlFor="description">Descrição</Label>
            <Input
              id="description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="due_date">Data de Vencimento *</Label>
              <Input
                id="due_date"
                type="date"
                value={formData.due_date}
                onChange={(e) => setFormData({ ...formData, due_date: e.target.value })}
              />
            </div>

            <div>
              <Label htmlFor="payment_method">Forma de Pagamento</Label>
              <Select value={formData.payment_method} onValueChange={(v) => setFormData({ ...formData, payment_method: v })}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecione" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Dinheiro">Dinheiro</SelectItem>
                  <SelectItem value="PIX">PIX</SelectItem>
                  <SelectItem value="Cartão">Cartão</SelectItem>
                  <SelectItem value="Boleto">Boleto</SelectItem>
                  <SelectItem value="Transferência">Transferência</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="supplier_customer">{type === 'receita' ? 'Cliente' : 'Fornecedor'}</Label>
              <Input
                id="supplier_customer"
                value={formData.supplier_customer}
                onChange={(e) => setFormData({ ...formData, supplier_customer: e.target.value })}
              />
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
          </div>

          {!account && (
            <div>
              <Label htmlFor="installments">Parcelas</Label>
              <Input
                id="installments"
                type="number"
                min="1"
                value={formData.installments}
                onChange={(e) => setFormData({ ...formData, installments: e.target.value })}
              />
            </div>
          )}

          {!account && (
            <div className="space-y-4">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="is_recurring"
                  checked={formData.is_recurring}
                  onCheckedChange={(checked) => setFormData({ ...formData, is_recurring: checked as boolean })}
                />
                <Label htmlFor="is_recurring">Despesa Recorrente</Label>
              </div>

              {formData.is_recurring && (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="recurrence_frequency">Frequência</Label>
                    <Select value={formData.recurrence_frequency} onValueChange={(v) => setFormData({ ...formData, recurrence_frequency: v as 'Mensal' | 'Semanal' | 'Anual' })}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Semanal">Semanal</SelectItem>
                        <SelectItem value="Mensal">Mensal</SelectItem>
                        <SelectItem value="Anual">Anual</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label htmlFor="recurrence_end_date">Data Final (opcional)</Label>
                    <Input
                      id="recurrence_end_date"
                      type="date"
                      value={formData.recurrence_end_date}
                      onChange={(e) => setFormData({ ...formData, recurrence_end_date: e.target.value })}
                    />
                  </div>
                </div>
              )}
            </div>
          )}

          <div>
            <Label htmlFor="notes">Observações</Label>
            <Textarea
              id="notes"
              value={formData.notes}
              onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
            />
          </div>

          <div className="flex justify-end gap-2">
            <Button type="button" variant="outline" onClick={onClose}>Cancelar</Button>
            <Button type="submit">Salvar</Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
