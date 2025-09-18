import { useState, useEffect } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Textarea } from "./ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { AnimalService } from "@/lib/animal-service";
import type { Animal, Vaccination } from "@/lib/types";

interface VaccinationFormProps {
  vaccination?: Vaccination;
  animalId?: string;
  onSuccess: () => void;
  onCancel: () => void;
}

export function VaccinationForm({ vaccination, animalId, onSuccess, onCancel }: VaccinationFormProps) {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [loading, setLoading] = useState(false);
  const [animals, setAnimals] = useState<Animal[]>([]);
  
  const [formData, setFormData] = useState({
    animal_id: vaccination?.animal_id || animalId || '',
    vaccine_name: vaccination?.vaccine_name || '',
    vaccine_type: vaccination?.vaccine_type || 'Preventiva',
    scheduled_date: vaccination?.scheduled_date ? vaccination.scheduled_date.split('T')[0] : '',
    applied_date: vaccination?.applied_date ? vaccination.applied_date.split('T')[0] : '',
    veterinarian: vaccination?.veterinarian || '',
    notes: vaccination?.notes || '',
    status: vaccination?.status || 'Agendada' as 'Agendada' | 'Aplicada' | 'Cancelada'
  });

  useEffect(() => {
    loadAnimals();
  }, []);

  const loadAnimals = async () => {
    try {
      const data = await animalService.getAnimals();
      setAnimals(data);
    } catch (error) {
      toast({
        title: "Erro ao carregar animais",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (vaccination) {
        await animalService.updateVaccination(vaccination.id, formData);
        toast({ title: "Vacinação atualizada com sucesso!" });
      } else {
        await animalService.createVaccination(formData);
        toast({ title: "Vacinação agendada com sucesso!" });
      }
      onSuccess();
    } catch (error) {
      toast({
        title: "Erro ao salvar vacinação",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const vaccines = [
    'Clostridiose',
    'Raiva',
    'Febre Aftosa',
    'Brucelose',
    'Carbúnculo',
    'Pneumonia',
    'Verminose',
    'Leptospirose'
  ];

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>{vaccination ? 'Editar Vacinação' : 'Agendar Nova Vacinação'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Animal *</Label>
            <Select 
              value={formData.animal_id} 
              onValueChange={(value) => setFormData({...formData, animal_id: value})}
              disabled={!!animalId}
            >
              <SelectTrigger>
                <SelectValue placeholder="Selecione o animal" />
              </SelectTrigger>
              <SelectContent>
                {animals.map((animal) => (
                  <SelectItem key={animal.id} value={animal.id}>
                    {animal.code} - {animal.name} ({animal.species === 'Ovino' ? '🐑' : '🐐'})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Vacina *</Label>
              <Select 
                value={formData.vaccine_name} 
                onValueChange={(value) => setFormData({...formData, vaccine_name: value})}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Selecione a vacina" />
                </SelectTrigger>
                <SelectContent>
                  {vaccines.map((vaccine) => (
                    <SelectItem key={vaccine} value={vaccine}>
                      {vaccine}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label>Tipo *</Label>
              <Select 
                value={formData.vaccine_type} 
                onValueChange={(value) => setFormData({...formData, vaccine_type: value})}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Preventiva">🛡️ Preventiva</SelectItem>
                  <SelectItem value="Terapêutica">💊 Terapêutica</SelectItem>
                  <SelectItem value="Reforço">🔄 Reforço</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="scheduled_date">Data Agendada *</Label>
              <Input
                id="scheduled_date"
                type="date"
                value={formData.scheduled_date}
                onChange={(e) => setFormData({...formData, scheduled_date: e.target.value})}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label>Status</Label>
              <Select 
                value={formData.status} 
                onValueChange={(value: 'Agendada' | 'Aplicada' | 'Cancelada') => 
                  setFormData({...formData, status: value})}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Agendada">📅 Agendada</SelectItem>
                  <SelectItem value="Aplicada">✅ Aplicada</SelectItem>
                  <SelectItem value="Cancelada">❌ Cancelada</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {formData.status === 'Aplicada' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="applied_date">Data de Aplicação</Label>
                <Input
                  id="applied_date"
                  type="date"
                  value={formData.applied_date}
                  onChange={(e) => setFormData({...formData, applied_date: e.target.value})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="veterinarian">Veterinário</Label>
                <Input
                  id="veterinarian"
                  value={formData.veterinarian}
                  onChange={(e) => setFormData({...formData, veterinarian: e.target.value})}
                  placeholder="Nome do veterinário"
                />
              </div>
            </div>
          )}

          <div className="space-y-2">
            <Label htmlFor="notes">Observações</Label>
            <Textarea
              id="notes"
              value={formData.notes}
              onChange={(e) => setFormData({...formData, notes: e.target.value})}
              placeholder="Observações sobre a vacinação"
            />
          </div>

          <div className="flex justify-end space-x-2 pt-4">
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancelar
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Salvando...' : vaccination ? 'Atualizar' : 'Agendar'}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}