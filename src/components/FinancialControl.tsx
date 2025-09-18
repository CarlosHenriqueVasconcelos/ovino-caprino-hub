import { useState, useEffect } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { Textarea } from "./ui/textarea";
import { Badge } from "./ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { Plus, DollarSign, TrendingUp, TrendingDown, Calculator } from "lucide-react";
import { AnimalService } from "@/lib/animal-service";
import type { FinancialRecord } from "@/lib/types";

export function FinancialControl() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [records, setRecords] = useState<FinancialRecord[]>([]);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    type: 'receita' as 'receita' | 'despesa',
    category: '',
    description: '',
    amount: 0,
    date: new Date().toISOString().split('T')[0],
    animal_id: ''
  });

  const revenueCategories = [
    'Venda de Animais',
    'Venda de Leite',
    'Venda de Lã',
    'Reprodução',
    'Outros'
  ];

  const expenseCategories = [
    'Ração',
    'Medicamentos',
    'Vacinação',
    'Veterinário',
    'Manutenção',
    'Equipamentos',
    'Outros'
  ];

  useEffect(() => {
    loadFinancialRecords();
  }, []);

  const loadFinancialRecords = async () => {
    try {
      setLoading(true);
      const data = await animalService.getFinancialRecords();
      setRecords(data);
    } catch (error) {
      toast({
        title: "Erro ao carregar registros financeiros",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      await animalService.createFinancialRecord({
        type: formData.type,
        category: formData.category,
        description: formData.description,
        amount: formData.amount,
        date: formData.date,
        animal_id: formData.animal_id || undefined
      });
      
      toast({ 
        title: `${formData.type === 'receita' ? 'Receita' : 'Despesa'} registrada com sucesso!` 
      });
      
      setFormData({
        type: 'receita',
        category: '',
        description: '',
        amount: 0,
        date: new Date().toISOString().split('T')[0],
        animal_id: ''
      });
      
      setIsDialogOpen(false);
      loadFinancialRecords();
    } catch (error) {
      toast({
        title: "Erro ao registrar lançamento",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const deleteRecord = async (id: string) => {
    try {
      await animalService.deleteFinancialRecord(id);
      toast({ title: "Registro excluído com sucesso!" });
      loadFinancialRecords();
    } catch (error) {
      toast({
        title: "Erro ao excluir registro",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const totalRevenue = records
    .filter(r => r.type === 'receita')
    .reduce((sum, r) => sum + r.amount, 0);

  const totalExpenses = records
    .filter(r => r.type === 'despesa')
    .reduce((sum, r) => sum + r.amount, 0);

  const balance = totalRevenue - totalExpenses;

  return (
    <div className="space-y-6">
      {/* Resumo Financeiro */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Receitas</p>
                <p className="text-2xl font-bold text-green-600">
                  R$ {totalRevenue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                </p>
              </div>
              <TrendingUp className="h-8 w-8 text-green-600" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Despesas</p>
                <p className="text-2xl font-bold text-red-600">
                  R$ {totalExpenses.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                </p>
              </div>
              <TrendingDown className="h-8 w-8 text-red-600" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Saldo</p>
                <p className={`text-2xl font-bold ${balance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                  R$ {balance.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                </p>
              </div>
              <Calculator className="h-8 w-8" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
              <DialogTrigger asChild>
                <Button className="w-full">
                  <Plus className="h-4 w-4 mr-2" />
                  Novo Lançamento
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-md">
                <DialogHeader>
                  <DialogTitle>Registrar Lançamento</DialogTitle>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="space-y-2">
                    <Label>Tipo *</Label>
                    <Select value={formData.type} onValueChange={(value: 'receita' | 'despesa') => 
                      setFormData({...formData, type: value, category: ''})}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="receita">💰 Receita</SelectItem>
                        <SelectItem value="despesa">💸 Despesa</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Categoria *</Label>
                    <Select value={formData.category} onValueChange={(value) => 
                      setFormData({...formData, category: value})}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione a categoria" />
                      </SelectTrigger>
                      <SelectContent>
                        {(formData.type === 'receita' ? revenueCategories : expenseCategories).map((cat) => (
                          <SelectItem key={cat} value={cat}>{cat}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Descrição *</Label>
                    <Textarea
                      id="description"
                      value={formData.description}
                      onChange={(e) => setFormData({...formData, description: e.target.value})}
                      placeholder="Descreva o lançamento"
                      required
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="amount">Valor (R$) *</Label>
                      <Input
                        id="amount"
                        type="number"
                        step="0.01"
                        value={formData.amount}
                        onChange={(e) => setFormData({...formData, amount: parseFloat(e.target.value)})}
                        required
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="date">Data *</Label>
                      <Input
                        id="date"
                        type="date"
                        value={formData.date}
                        onChange={(e) => setFormData({...formData, date: e.target.value})}
                        required
                      />
                    </div>
                  </div>

                  <div className="flex justify-end space-x-2 pt-4">
                    <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>
                      Cancelar
                    </Button>
                    <Button type="submit" disabled={loading}>
                      {loading ? 'Salvando...' : 'Registrar'}
                    </Button>
                  </div>
                </form>
              </DialogContent>
            </Dialog>
          </CardContent>
        </Card>
      </div>

      {/* Lista de Lançamentos */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <DollarSign className="h-5 w-5" />
            Últimos Lançamentos
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {records.length === 0 ? (
              <p className="text-center text-muted-foreground py-4">
                Nenhum lançamento registrado
              </p>
            ) : (
              records.map((record) => (
                <div key={record.id} className="flex items-center justify-between p-3 border rounded-lg">
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <Badge variant={record.type === 'receita' ? 'default' : 'destructive'}>
                        {record.type === 'receita' ? '💰' : '💸'} {record.category}
                      </Badge>
                      <span className="text-sm text-muted-foreground">
                        {new Date(record.date).toLocaleDateString('pt-BR')}
                      </span>
                    </div>
                    <p className="text-sm mt-1">{record.description}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className={`text-lg font-bold ${
                      record.type === 'receita' ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {record.type === 'despesa' ? '-' : '+'}R$ {record.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </div>
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => deleteRecord(record.id)}
                    >
                      Excluir
                    </Button>
                  </div>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}