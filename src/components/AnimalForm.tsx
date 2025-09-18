import { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Textarea } from "./ui/textarea";
import { Switch } from "./ui/switch";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { AnimalService } from "@/lib/animal-service";
import type { Animal } from "@/lib/types";

interface AnimalFormProps {
  animal?: Animal;
  onSuccess: () => void;
  onCancel: () => void;
}

export function AnimalForm({ animal, onSuccess, onCancel }: AnimalFormProps) {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [loading, setLoading] = useState(false);
  
  const [formData, setFormData] = useState({
    code: animal?.code || '',
    name: animal?.name || '',
    species: animal?.species || 'Ovino' as 'Ovino' | 'Caprino',
    breed: animal?.breed || '',
    gender: animal?.gender || 'Fêmea' as 'Macho' | 'Fêmea',
    birth_date: animal?.birth_date ? animal.birth_date.split('T')[0] : '',
    weight: animal?.weight || 0,
    status: animal?.status || 'Saudável',
    location: animal?.location || '',
    last_vaccination: animal?.last_vaccination ? animal.last_vaccination.split('T')[0] : '',
    pregnant: animal?.pregnant || false,
    expected_delivery: animal?.expected_delivery ? animal.expected_delivery.split('T')[0] : '',
    health_issue: animal?.health_issue || ''
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (animal) {
        await animalService.updateAnimal(animal.id, formData);
        toast({ title: "Animal atualizado com sucesso!" });
      } else {
        await animalService.createAnimal(formData);
        toast({ title: "Animal cadastrado com sucesso!" });
      }
      onSuccess();
    } catch (error) {
      toast({
        title: "Erro ao salvar animal",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>{animal ? 'Editar Animal' : 'Cadastrar Novo Animal'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="code">Código *</Label>
              <Input
                id="code"
                value={formData.code}
                onChange={(e) => setFormData({...formData, code: e.target.value})}
                placeholder="Ex: OV001"
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="name">Nome *</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                placeholder="Nome do animal"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Espécie *</Label>
              <Select value={formData.species} onValueChange={(value: 'Ovino' | 'Caprino') => 
                setFormData({...formData, species: value})}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Ovino">🐑 Ovino</SelectItem>
                  <SelectItem value="Caprino">🐐 Caprino</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="breed">Raça *</Label>
              <Input
                id="breed"
                value={formData.breed}
                onChange={(e) => setFormData({...formData, breed: e.target.value})}
                placeholder="Ex: Santa Inês"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label>Sexo *</Label>
              <Select value={formData.gender} onValueChange={(value: 'Macho' | 'Fêmea') => 
                setFormData({...formData, gender: value})}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Macho">♂️ Macho</SelectItem>
                  <SelectItem value="Fêmea">♀️ Fêmea</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="birth_date">Data de Nascimento *</Label>
              <Input
                id="birth_date"
                type="date"
                value={formData.birth_date}
                onChange={(e) => setFormData({...formData, birth_date: e.target.value})}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="weight">Peso (kg) *</Label>
              <Input
                id="weight"
                type="number"
                step="0.1"
                value={formData.weight}
                onChange={(e) => setFormData({...formData, weight: parseFloat(e.target.value)})}
                placeholder="0.0"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="status">Status</Label>
              <Input
                id="status"
                value={formData.status}
                onChange={(e) => setFormData({...formData, status: e.target.value})}
                placeholder="Ex: Saudável"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="location">Localização *</Label>
              <Input
                id="location"
                value={formData.location}
                onChange={(e) => setFormData({...formData, location: e.target.value})}
                placeholder="Ex: Pasto A1"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="last_vaccination">Última Vacinação</Label>
            <Input
              id="last_vaccination"
              type="date"
              value={formData.last_vaccination}
              onChange={(e) => setFormData({...formData, last_vaccination: e.target.value})}
            />
          </div>

          {formData.gender === 'Fêmea' && (
            <div className="space-y-4 p-4 border rounded-lg">
              <div className="flex items-center space-x-2">
                <Switch
                  checked={formData.pregnant}
                  onCheckedChange={(checked) => setFormData({...formData, pregnant: checked})}
                />
                <Label>Animal prenhe</Label>
              </div>
              
              {formData.pregnant && (
                <div className="space-y-2">
                  <Label htmlFor="expected_delivery">Data Prevista do Parto</Label>
                  <Input
                    id="expected_delivery"
                    type="date"
                    value={formData.expected_delivery}
                    onChange={(e) => setFormData({...formData, expected_delivery: e.target.value})}
                  />
                </div>
              )}
            </div>
          )}

          <div className="space-y-2">
            <Label htmlFor="health_issue">Problemas de Saúde</Label>
            <Textarea
              id="health_issue"
              value={formData.health_issue}
              onChange={(e) => setFormData({...formData, health_issue: e.target.value})}
              placeholder="Descreva problemas de saúde, se houver"
            />
          </div>

          <div className="flex justify-end space-x-2 pt-4">
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancelar
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Salvando...' : animal ? 'Atualizar' : 'Cadastrar'}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}