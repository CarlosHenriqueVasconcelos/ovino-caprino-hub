import { useState, useEffect } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Textarea } from "./ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { Badge } from "./ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { Plus, Heart, Calendar, Baby, CheckCircle } from "lucide-react";
import { AnimalService } from "@/lib/offline-animal-service";
import type { BreedingRecord, Animal } from "@/lib/types";

export function BreedingManagement() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [animals, setAnimals] = useState<Animal[]>([]);
  const [breedingRecords, setBreedingRecords] = useState<BreedingRecord[]>([]);
  const [pregnantFemales, setPregnantFemales] = useState<Animal[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  
  const [formData, setFormData] = useState({
    female_animal_id: '',
    male_animal_id: '',
    breeding_date: new Date().toISOString().split('T')[0],
    notes: ''
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [animalsData, breedingData] = await Promise.all([
        animalService.getAnimals(),
        animalService.getBreedingRecords()
      ]);
      
      setAnimals(animalsData);
      setBreedingRecords(breedingData);
      setPregnantFemales(animalsData.filter(animal => 
        animal.pregnant && animal.gender === 'Fêmea'
      ));
    } catch (error) {
      toast({
        title: "Erro ao carregar dados",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const calculateExpectedBirth = (breedingDate: string): string => {
    const date = new Date(breedingDate);
    date.setDate(date.getDate() + 150);
    return date.toISOString().split('T')[0];
  };

  const handleBreedingSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const expectedBirth = calculateExpectedBirth(formData.breeding_date);
      
      await animalService.createBreedingRecord({
        ...formData,
        expected_birth: expectedBirth,
        status: 'Cobertura'
      });

      await animalService.updateAnimal(formData.female_animal_id, {
        pregnant: true,
        expected_delivery: expectedBirth
      });

      toast({ title: "Cobertura registrada com sucesso!" });
      setFormData({
        female_animal_id: '',
        male_animal_id: '',
        breeding_date: new Date().toISOString().split('T')[0],
        notes: ''
      });
      setIsDialogOpen(false);
      loadData();
    } catch (error) {
      toast({
        title: "Erro ao registrar cobertura",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const markAsBirthed = async (animalId: string) => {
    try {
      await animalService.updateAnimal(animalId, {
        pregnant: false,
        expected_delivery: undefined
      });
      toast({ title: "Parto registrado com sucesso!" });
      loadData();
    } catch (error) {
      toast({
        title: "Erro ao registrar parto",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const femaleAnimals = animals.filter(a => a.gender === 'Fêmea' && !a.pregnant);
  const maleAnimals = animals.filter(a => a.gender === 'Macho');

  if (loading) {
    return (
      <Card>
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin text-2xl">🐑</div>
            <span className="ml-2">Carregando dados de reprodução...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <Heart className="h-5 w-5" />
              Controle de Reprodução
            </CardTitle>
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
              <DialogTrigger asChild>
                <Button className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  Registrar Cobertura
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Registrar Nova Cobertura</DialogTitle>
                </DialogHeader>
                <form onSubmit={handleBreedingSubmit} className="space-y-4">
                  <div className="space-y-2">
                    <Label>Fêmea *</Label>
                    <Select value={formData.female_animal_id} onValueChange={(value) => 
                      setFormData({...formData, female_animal_id: value})}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione a fêmea" />
                      </SelectTrigger>
                      <SelectContent>
                        {femaleAnimals.map((animal) => (
                          <SelectItem key={animal.id} value={animal.id}>
                            {animal.code} - {animal.name} ({animal.species === 'Ovino' ? '🐑' : '🐐'})
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Reprodutor</Label>
                    <Select value={formData.male_animal_id} onValueChange={(value) => 
                      setFormData({...formData, male_animal_id: value})}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione o reprodutor" />
                      </SelectTrigger>
                      <SelectContent>
                        {maleAnimals.map((animal) => (
                          <SelectItem key={animal.id} value={animal.id}>
                            {animal.code} - {animal.name} ({animal.species === 'Ovino' ? '🐑' : '🐐'})
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="breeding_date">Data da Cobertura *</Label>
                    <Input
                      id="breeding_date"
                      type="date"
                      value={formData.breeding_date}
                      onChange={(e) => setFormData({...formData, breeding_date: e.target.value})}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="notes">Observações</Label>
                    <Textarea
                      id="notes"
                      value={formData.notes}
                      onChange={(e) => setFormData({...formData, notes: e.target.value})}
                      placeholder="Observações sobre a cobertura"
                    />
                  </div>

                  <div className="flex justify-end space-x-2">
                    <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>
                      Cancelar
                    </Button>
                    <Button type="submit">
                      Registrar Cobertura
                    </Button>
                  </div>
                </form>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
        <CardContent>
          {pregnantFemales.length === 0 ? (
            <p className="text-center text-muted-foreground py-4">
              Nenhuma fêmea prenhe registrada
            </p>
          ) : (
            <div className="space-y-4">
              {pregnantFemales.map((animal) => (
                <div key={animal.id} className="p-4 border rounded-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="font-medium">{animal.code} - {animal.name}</h3>
                      <p className="text-sm text-muted-foreground">
                        {animal.species} {animal.breed}
                      </p>
                      {animal.expected_delivery && (
                        <p className="text-sm text-muted-foreground">
                          Parto previsto: {new Date(animal.expected_delivery).toLocaleDateString('pt-BR')}
                        </p>
                      )}
                    </div>
                    <Button
                      size="sm"
                      onClick={() => markAsBirthed(animal.id)}
                    >
                      <CheckCircle className="h-4 w-4 mr-2" />
                      Marcar como Parida
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}