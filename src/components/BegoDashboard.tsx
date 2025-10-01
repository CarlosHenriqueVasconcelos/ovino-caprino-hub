import { useState, useEffect } from "react";
import { AnimalCard } from "./AnimalCard";
import { StatsCard } from "./StatsCard";
import { AnimalForm } from "./AnimalForm";
import { VaccinationForm } from "./VaccinationForm";
import { ReportsGenerator } from "./ReportsGenerator";
import { VaccinationAlerts } from "./VaccinationAlerts";
import { SearchAnimals } from "./SearchAnimals";
import { Dialog, DialogContent } from "./ui/dialog";
import { AnimalService } from "@/lib/offline-animal-service";
import type { Animal, AnimalStats } from "@/lib/types";
import { useToast } from "./ui/use-toast";
import { Button } from "./ui/button";
import { PawPrint, Heart, Baby, AlertTriangle, Plus, Syringe, FileText, Search } from "lucide-react";

export function BegoDashboard() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  
  const [animals, setAnimals] = useState<Animal[]>([]);
  const [stats, setStats] = useState<AnimalStats | null>(null);
  const [loading, setLoading] = useState(true);
  
  // Modal states
  const [showAnimalForm, setShowAnimalForm] = useState(false);
  const [showVaccinationForm, setShowVaccinationForm] = useState(false);
  const [showReports, setShowReports] = useState(false);
  const [showSearch, setShowSearch] = useState(false);
  const [editingAnimal, setEditingAnimal] = useState<Animal | undefined>();

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [animalsData, statsData] = await Promise.all([
        animalService.getAnimals(),
        animalService.getStats()
      ]);
      setAnimals(animalsData.slice(0, 6));
      setStats(statsData);
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

  const calculateAge = (birthDate: string): string => {
    const now = new Date();
    const birth = new Date(birthDate);
    const ageInMonths = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth());
    
    if (ageInMonths < 12) {
      return `${ageInMonths} meses`;
    } else {
      const years = Math.floor(ageInMonths / 12);
      const remainingMonths = ageInMonths % 12;
      return remainingMonths > 0 ? `${years}a ${remainingMonths}m` : `${years} anos`;
    }
  };

  const formatAnimalForCard = (animal: Animal) => ({
    id: animal.id,
    name: animal.name,
    species: animal.species,
    breed: animal.breed,
    gender: animal.gender,
    age: calculateAge(animal.birth_date),
    weight: animal.weight,
    status: animal.status,
    location: animal.location,
    lastVaccination: animal.last_vaccination ? new Date(animal.last_vaccination).toLocaleDateString('pt-BR') : 'Nunca',
    pregnant: animal.pregnant,
    expectedDelivery: animal.expected_delivery ? new Date(animal.expected_delivery).toLocaleDateString('pt-BR') : undefined,
    healthIssue: animal.health_issue
  });

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-amber-50 p-4 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin text-4xl mb-4">🐑</div>
          <p className="text-emerald-600">Carregando dados da fazenda...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-amber-50 p-4">
      <div className="mx-auto max-w-7xl">
        {/* Header */}
        <div className="mb-8 text-center">
          <h1 className="text-4xl font-bold text-emerald-800 mb-2">
            🐑 BEGO Agritech 🐐
          </h1>
          <p className="text-emerald-600 text-lg">
            Sistema de Gestão para Ovinocultura e Caprinocultura
          </p>
        </div>

        {/* Stats Cards */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <StatsCard
              title="Total de Animais"
              value={stats.totalAnimals}
              icon={PawPrint}
              color="primary"
            />
            <StatsCard
              title="Animais Saudáveis"
              value={stats.healthy}
              icon={Heart}
              color="secondary"
            />
            <StatsCard
              title="Fêmeas Prenhes"
              value={stats.pregnant}
              icon={Baby}
              color="accent"
            />
            <StatsCard
              title="Em Tratamento"
              value={stats.underTreatment}
              icon={AlertTriangle}
              color="destructive"
            />
          </div>
        )}

        {/* Vaccination Alerts */}
        <div className="mb-8">
          <VaccinationAlerts />
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <Button 
            onClick={() => setShowAnimalForm(true)}
            className="h-auto p-4 flex-col gap-2 bg-emerald-600 hover:bg-emerald-700"
          >
            <Plus className="h-5 w-5" />
            Novo Animal
          </Button>
          <Button 
            onClick={() => setShowVaccinationForm(true)}
            className="h-auto p-4 flex-col gap-2 bg-blue-600 hover:bg-blue-700"
          >
            <Syringe className="h-5 w-5" />
            Agendar Vacinação
          </Button>
          <Button 
            onClick={() => setShowReports(true)}
            className="h-auto p-4 flex-col gap-2 bg-purple-600 hover:bg-purple-700"
          >
            <FileText className="h-5 w-5" />
            Gerar Relatório
          </Button>
          <Button 
            onClick={() => setShowSearch(true)}
            className="h-auto p-4 flex-col gap-2 bg-orange-600 hover:bg-orange-700"
          >
            <Search className="h-5 w-5" />
            Pesquisar
          </Button>
        </div>

        {/* Animals Grid */}
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-emerald-800 mb-4">
            🐑 Animais Recentes
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {animals.map((animal) => (
              <AnimalCard 
                key={animal.id} 
                animal={formatAnimalForCard(animal)}
                onEdit={() => {
                  setEditingAnimal(animal);
                  setShowAnimalForm(true);
                }}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Modals */}
      <Dialog open={showAnimalForm} onOpenChange={setShowAnimalForm}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <AnimalForm
            animal={editingAnimal}
            onSuccess={() => {
              setShowAnimalForm(false);
              setEditingAnimal(undefined);
              loadData();
            }}
            onCancel={() => {
              setShowAnimalForm(false);
              setEditingAnimal(undefined);
            }}
          />
        </DialogContent>
      </Dialog>

      <Dialog open={showVaccinationForm} onOpenChange={setShowVaccinationForm}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <VaccinationForm
            onSuccess={() => {
              setShowVaccinationForm(false);
              loadData();
            }}
            onCancel={() => setShowVaccinationForm(false)}
          />
        </DialogContent>
      </Dialog>

      <Dialog open={showReports} onOpenChange={setShowReports}>
        <DialogContent className="max-w-6xl max-h-[90vh] overflow-y-auto">
          <ReportsGenerator onClose={() => setShowReports(false)} />
        </DialogContent>
      </Dialog>

      <SearchAnimals 
        open={showSearch} 
        onOpenChange={setShowSearch}
        onEditAnimal={(animal) => {
          setEditingAnimal(animal);
          setShowAnimalForm(true);
          setShowSearch(false);
        }}
      />
    </div>
  );
}