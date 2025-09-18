import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { AnimalService } from "@/lib/animal-service";
import type { Animal } from "@/lib/types";
import { useToast } from "./ui/use-toast";
import { Scale, TrendingUp, Plus, Calendar } from "lucide-react";

interface WeightRecord {
  id: string;
  animal_id: string;
  weight: number;
  date: string;
  notes?: string;
}

export function WeightTracking() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  
  const [animals, setAnimals] = useState<Animal[]>([]);
  const [selectedAnimal, setSelectedAnimal] = useState<Animal | null>(null);
  const [loading, setLoading] = useState(true);
  const [showWeightForm, setShowWeightForm] = useState(false);
  
  const [weightForm, setWeightForm] = useState({
    animal_id: '',
    weight: '',
    date: new Date().toISOString().split('T')[0],
    notes: ''
  });

  useEffect(() => {
    loadAnimals();
  }, []);

  const loadAnimals = async () => {
    try {
      setLoading(true);
      const data = await animalService.getAnimals();
      setAnimals(data);
    } catch (error) {
      toast({
        title: "Erro ao carregar animais",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const handleWeightSubmit = async () => {
    try {
      // Atualizar o peso atual do animal
      await animalService.updateAnimal(weightForm.animal_id, {
        weight: parseFloat(weightForm.weight)
      });

      toast({ title: "Peso registrado com sucesso!" });
      setShowWeightForm(false);
      setWeightForm({
        animal_id: '',
        weight: '',
        date: new Date().toISOString().split('T')[0],
        notes: ''
      });
      loadAnimals();
    } catch (error) {
      toast({
        title: "Erro ao registrar peso",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const calculateAge = (birthDate: string): number => {
    const now = new Date();
    const birth = new Date(birthDate);
    return (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth());
  };

  const getWeightCategory = (animal: Animal) => {
    const ageInMonths = calculateAge(animal.birth_date);
    const weight = animal.weight;
    
    // Categorias baseadas em idade e peso para ovinos/caprinos
    if (ageInMonths < 6) {
      return weight < 15 ? 'Abaixo do ideal' : weight > 25 ? 'Acima do ideal' : 'Ideal';
    } else if (ageInMonths < 12) {
      return weight < 25 ? 'Abaixo do ideal' : weight > 40 ? 'Acima do ideal' : 'Ideal';
    } else {
      // Adultos
      if (animal.species === 'Ovino') {
        return weight < 40 ? 'Abaixo do ideal' : weight > 80 ? 'Acima do ideal' : 'Ideal';
      } else {
        // Caprino
        return weight < 30 ? 'Abaixo do ideal' : weight > 70 ? 'Acima do ideal' : 'Ideal';
      }
    }
  };

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'Ideal': return 'secondary';
      case 'Abaixo do ideal': return 'destructive';
      case 'Acima do ideal': return 'default';
      default: return 'outline';
    }
  };

  const getAverageWeightByCategory = () => {
    const categories = {
      'Cordeiros/Cabritos (< 6 meses)': animals.filter(a => calculateAge(a.birth_date) < 6),
      'Jovens (6-12 meses)': animals.filter(a => {
        const age = calculateAge(a.birth_date);
        return age >= 6 && age < 12;
      }),
      'Adultos (> 12 meses)': animals.filter(a => calculateAge(a.birth_date) >= 12)
    };

    return Object.entries(categories).map(([name, group]) => ({
      name,
      count: group.length,
      avgWeight: group.length > 0 ? (group.reduce((sum, a) => sum + a.weight, 0) / group.length).toFixed(1) : '0'
    }));
  };

  const weightStats = getAverageWeightByCategory();

  if (loading) {
    return (
      <Card>
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin text-2xl">⚖️</div>
            <span className="ml-2">Carregando dados de peso...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <Scale className="h-5 w-5" />
            Controle de Peso e Crescimento
          </CardTitle>
          <Dialog open={showWeightForm} onOpenChange={setShowWeightForm}>
            <DialogTrigger asChild>
              <Button className="flex items-center gap-2">
                <Plus className="h-4 w-4" />
                Registrar Peso
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Registrar Novo Peso</DialogTitle>
              </DialogHeader>
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label>Animal *</Label>
                  <Select value={weightForm.animal_id} onValueChange={(value) => 
                    setWeightForm({...weightForm, animal_id: value})}>
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione o animal" />
                    </SelectTrigger>
                    <SelectContent>
                      {animals.map((animal) => (
                        <SelectItem key={animal.id} value={animal.id}>
                          {animal.code} - {animal.name} ({animal.species === 'Ovino' ? '🐑' : '🐐'}) - Atual: {animal.weight}kg
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="weight">Peso (kg) *</Label>
                    <Input
                      id="weight"
                      type="number"
                      step="0.1"
                      value={weightForm.weight}
                      onChange={(e) => setWeightForm({...weightForm, weight: e.target.value})}
                      placeholder="0.0"
                      required
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="date">Data *</Label>
                    <Input
                      id="date"
                      type="date"
                      value={weightForm.date}
                      onChange={(e) => setWeightForm({...weightForm, date: e.target.value})}
                      required
                    />
                  </div>
                </div>

                <div className="flex justify-end space-x-2">
                  <Button variant="outline" onClick={() => setShowWeightForm(false)}>
                    Cancelar
                  </Button>
                  <Button onClick={handleWeightSubmit}>
                    Registrar Peso
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
      <CardContent>
        {/* Estatísticas por categoria */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          {weightStats.map((stat) => (
            <div key={stat.name} className="bg-muted/50 p-4 rounded-lg">
              <div className="text-lg font-semibold">{stat.avgWeight} kg</div>
              <div className="text-sm text-muted-foreground">{stat.name}</div>
              <div className="text-xs text-muted-foreground">{stat.count} animais</div>
            </div>
          ))}
        </div>

        {/* Lista de animais com categorização de peso */}
        <div className="space-y-4">
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <TrendingUp className="h-5 w-5" />
            Análise de Peso por Animal
          </h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {animals.map((animal) => {
              const ageInMonths = calculateAge(animal.birth_date);
              const category = getWeightCategory(animal);
              
              return (
                <Card key={animal.id} className="border-l-4 border-l-primary">
                  <CardContent className="p-4">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <div className="font-medium flex items-center gap-2">
                          {animal.species === 'Ovino' ? '🐑' : '🐐'} {animal.code}
                        </div>
                        <div className="text-sm text-muted-foreground">{animal.name}</div>
                      </div>
                      <div className={`px-2 py-1 rounded text-xs font-medium ${
                        category === 'Ideal' ? 'bg-green-100 text-green-800' :
                        category === 'Abaixo do ideal' ? 'bg-red-100 text-red-800' :
                        'bg-yellow-100 text-yellow-800'
                      }`}>
                        {category}
                      </div>
                    </div>
                    
                    <div className="space-y-1 text-sm">
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">Peso atual:</span>
                        <span className="font-medium">{animal.weight} kg</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">Idade:</span>
                        <span>{ageInMonths < 12 ? `${ageInMonths} meses` : `${Math.floor(ageInMonths / 12)} anos`}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">Localização:</span>
                        <span>{animal.location}</span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}