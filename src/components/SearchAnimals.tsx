import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "./ui/dialog";
import { Input } from "./ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Button } from "./ui/button";
import { AnimalCard } from "./AnimalCard";
import { AnimalService } from "@/lib/animal-service";
import type { Animal } from "@/lib/types";
import { useToast } from "./ui/use-toast";
import { Search, Filter, X } from "lucide-react";

interface SearchAnimalsProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onEditAnimal: (animal: Animal) => void;
}

interface SearchFilters {
  species: string;
  status: string;
  gender: string;
  location: string;
  pregnant: string;
}

export function SearchAnimals({ open, onOpenChange, onEditAnimal }: SearchAnimalsProps) {
  const { toast } = useToast();
  const animalService = new AnimalService();
  
  const [animals, setAnimals] = useState<Animal[]>([]);
  const [filteredAnimals, setFilteredAnimals] = useState<Animal[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  
  const [filters, setFilters] = useState<SearchFilters>({
    species: "",
    status: "",
    gender: "",
    location: "",
    pregnant: ""
  });

  useEffect(() => {
    if (open) {
      loadAnimals();
    }
  }, [open]);

  useEffect(() => {
    applyFilters();
  }, [searchTerm, filters, animals]);

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

  const applyFilters = () => {
    let filtered = [...animals];

    // Filtro por termo de busca (código, nome, raça)
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(animal => 
        animal.code.toLowerCase().includes(term) ||
        animal.name.toLowerCase().includes(term) ||
        animal.breed.toLowerCase().includes(term)
      );
    }

    // Aplicar outros filtros
    if (filters.species) {
      filtered = filtered.filter(animal => animal.species === filters.species);
    }
    if (filters.status) {
      filtered = filtered.filter(animal => animal.status === filters.status);
    }
    if (filters.gender) {
      filtered = filtered.filter(animal => animal.gender === filters.gender);
    }
    if (filters.location) {
      filtered = filtered.filter(animal => 
        animal.location.toLowerCase().includes(filters.location.toLowerCase())
      );
    }
    if (filters.pregnant !== "") {
      const isPregnant = filters.pregnant === "true";
      filtered = filtered.filter(animal => animal.pregnant === isPregnant);
    }

    setFilteredAnimals(filtered);
  };

  const clearFilters = () => {
    setSearchTerm("");
    setFilters({
      species: "",
      status: "",
      gender: "",
      location: "",
      pregnant: ""
    });
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

  // Obter valores únicos para os filtros
  const uniqueValues = {
    statuses: [...new Set(animals.map(a => a.status))],
    locations: [...new Set(animals.map(a => a.location))]
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-7xl max-h-[90vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Search className="h-5 w-5" />
            Pesquisar Animais
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          {/* Barra de pesquisa */}
          <div className="relative">
            <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Pesquisar por código, nome ou raça..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>

          {/* Filtros */}
          <div className="flex flex-wrap gap-4 p-4 bg-muted/50 rounded-lg">
            <div className="flex items-center gap-2">
              <Filter className="h-4 w-4 text-muted-foreground" />
              <span className="text-sm font-medium">Filtros:</span>
            </div>
            
            <Select value={filters.species} onValueChange={(value) => 
              setFilters({...filters, species: value})}>
              <SelectTrigger className="w-32">
                <SelectValue placeholder="Espécie" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">Todas</SelectItem>
                <SelectItem value="Ovino">🐑 Ovino</SelectItem>
                <SelectItem value="Caprino">🐐 Caprino</SelectItem>
              </SelectContent>
            </Select>

            <Select value={filters.gender} onValueChange={(value) => 
              setFilters({...filters, gender: value})}>
              <SelectTrigger className="w-32">
                <SelectValue placeholder="Sexo" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">Todos</SelectItem>
                <SelectItem value="Macho">♂️ Macho</SelectItem>
                <SelectItem value="Fêmea">♀️ Fêmea</SelectItem>
              </SelectContent>
            </Select>

            <Select value={filters.status} onValueChange={(value) => 
              setFilters({...filters, status: value})}>
              <SelectTrigger className="w-40">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">Todos</SelectItem>
                {uniqueValues.statuses.map(status => (
                  <SelectItem key={status} value={status}>{status}</SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Select value={filters.pregnant} onValueChange={(value) => 
              setFilters({...filters, pregnant: value})}>
              <SelectTrigger className="w-32">
                <SelectValue placeholder="Prenhez" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">Todas</SelectItem>
                <SelectItem value="true">🤱 Prenhe</SelectItem>
                <SelectItem value="false">Não prenhe</SelectItem>
              </SelectContent>
            </Select>

            <Input
              placeholder="Localização"
              value={filters.location}
              onChange={(e) => setFilters({...filters, location: e.target.value})}
              className="w-32"
            />

            <Button 
              variant="outline" 
              size="sm" 
              onClick={clearFilters}
              className="flex items-center gap-1"
            >
              <X className="h-3 w-3" />
              Limpar
            </Button>
          </div>

          {/* Resultados */}
          <div className="flex-1 overflow-y-auto">
            <div className="mb-4 flex items-center justify-between">
              <p className="text-sm text-muted-foreground">
                {loading ? "Carregando..." : `${filteredAnimals.length} animal(is) encontrado(s)`}
              </p>
            </div>

            {loading ? (
              <div className="flex justify-center py-8">
                <div className="animate-spin text-2xl">🐑</div>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-[400px] overflow-y-auto">
                {filteredAnimals.map((animal) => (
                  <AnimalCard 
                    key={animal.id} 
                    animal={formatAnimalForCard(animal)}
                    onEdit={() => onEditAnimal(animal)}
                  />
                ))}
              </div>
            )}

            {!loading && filteredAnimals.length === 0 && (
              <div className="text-center py-8 text-muted-foreground">
                <Search className="h-12 w-12 mx-auto mb-4 opacity-50" />
                <p>Nenhum animal encontrado com os filtros aplicados.</p>
              </div>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}