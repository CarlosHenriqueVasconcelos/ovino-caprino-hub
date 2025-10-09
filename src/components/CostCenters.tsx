import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Plus, Trash2 } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { localCostCenters } from '@/lib/financial-service';
import { CostCenter } from '@/lib/types';
import { toast } from 'sonner';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

export default function CostCenters() {
  const [costCenters, setCostCenters] = useState<CostCenter[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({ name: '', description: '' });

  const loadCostCenters = () => {
    setCostCenters(localCostCenters.all());
  };

  useEffect(() => {
    loadCostCenters();
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.name) {
      toast.error('Digite o nome do centro de custo');
      return;
    }

    localCostCenters.create({
      name: formData.name,
      description: formData.description,
      active: true,
    });

    toast.success('Centro de custo criado');
    setFormData({ name: '', description: '' });
    setShowForm(false);
    loadCostCenters();
  };

  const handleDelete = (id: string) => {
    if (confirm('Deseja realmente excluir este centro de custo?')) {
      localCostCenters.delete(id);
      toast.success('Centro de custo excluído');
      loadCostCenters();
    }
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-center">
          <CardTitle>Centros de Custo</CardTitle>
          <Button onClick={() => setShowForm(true)}>
            <Plus className="mr-2 h-4 w-4" /> Novo Centro de Custo
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Nome</TableHead>
              <TableHead>Descrição</TableHead>
              <TableHead>Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {costCenters.map((cc) => (
              <TableRow key={cc.id}>
                <TableCell className="font-medium">{cc.name}</TableCell>
                <TableCell>{cc.description || '-'}</TableCell>
                <TableCell>
                  <Button size="sm" variant="outline" onClick={() => handleDelete(cc.id)}>
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        {showForm && (
          <Dialog open onOpenChange={setShowForm}>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Novo Centro de Custo</DialogTitle>
              </DialogHeader>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <Label htmlFor="name">Nome *</Label>
                  <Input
                    id="name"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  />
                </div>

                <div>
                  <Label htmlFor="description">Descrição</Label>
                  <Textarea
                    id="description"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  />
                </div>

                <div className="flex justify-end gap-2">
                  <Button type="button" variant="outline" onClick={() => setShowForm(false)}>Cancelar</Button>
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
