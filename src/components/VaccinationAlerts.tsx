import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Alert, AlertDescription } from "./ui/alert";
import { Badge } from "./ui/badge";
import { AnimalService } from "@/lib/offline-animal-service";
import type { Vaccination, Medication, Animal } from "@/lib/types";
import { useToast } from "./ui/use-toast";
import { Calendar, AlertTriangle, Clock, CheckCircle, Pill } from "lucide-react";

interface AlertItem {
  id: string;
  type: 'vaccination' | 'medication';
  animal: Animal;
  title: string;
  subtitle: string;
  scheduledDate: string;
  daysUntilDue: number;
  urgency: 'overdue' | 'urgent' | 'upcoming' | 'normal';
  notes?: string;
}

export function VaccinationAlerts() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [alerts, setAlerts] = useState<AlertItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadVaccinationAlerts();

    // Listen for data updates
    const handleDataUpdate = (e: CustomEvent) => {
      if (e.detail?.type === 'vaccination' || e.detail?.type === 'medication') {
        loadVaccinationAlerts();
      }
    };

    window.addEventListener('bego-data-update', handleDataUpdate as EventListener);
    return () => window.removeEventListener('bego-data-update', handleDataUpdate as EventListener);
  }, []);

  const loadVaccinationAlerts = async () => {
    try {
      setLoading(true);
      const [vaccinations, medications, animals] = await Promise.all([
        animalService.getVaccinations(),
        animalService.getMedications(),
        animalService.getAnimals()
      ]);

      const animalMap = new Map(animals.map(animal => [animal.id, animal]));
      const now = new Date();

      // Process vaccinations
      const vaccinationAlerts: AlertItem[] = vaccinations
        .filter(vac => vac.status === 'Agendada')
        .map(vaccination => {
          const animal = animalMap.get(vaccination.animal_id);
          if (!animal) return null;

          const scheduledDate = new Date(vaccination.scheduled_date);
          const diffTime = scheduledDate.getTime() - now.getTime();
          const daysUntilDue = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

          let urgency: 'overdue' | 'urgent' | 'upcoming' | 'normal' = 'normal';
          if (daysUntilDue < 0) urgency = 'overdue';
          else if (daysUntilDue <= 3) urgency = 'urgent';
          else if (daysUntilDue <= 7) urgency = 'upcoming';

          return {
            id: vaccination.id,
            type: 'vaccination' as const,
            animal,
            title: vaccination.vaccine_name,
            subtitle: vaccination.vaccine_type,
            scheduledDate: vaccination.scheduled_date,
            daysUntilDue,
            urgency,
            notes: vaccination.notes
          };
        })
        .filter(Boolean) as AlertItem[];

      // Process medications
      const medicationAlerts: AlertItem[] = medications
        .filter(med => med.status === 'Agendado')
        .map(medication => {
          const animal = animalMap.get(medication.animal_id);
          if (!animal) return null;

          const scheduledDate = new Date(medication.date);
          const diffTime = scheduledDate.getTime() - now.getTime();
          const daysUntilDue = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

          let urgency: 'overdue' | 'urgent' | 'upcoming' | 'normal' = 'normal';
          if (daysUntilDue < 0) urgency = 'overdue';
          else if (daysUntilDue <= 3) urgency = 'urgent';
          else if (daysUntilDue <= 7) urgency = 'upcoming';

          return {
            id: medication.id,
            type: 'medication' as const,
            animal,
            title: medication.medication_name,
            subtitle: medication.dosage || 'Medicamento',
            scheduledDate: medication.date,
            daysUntilDue,
            urgency,
            notes: medication.notes
          };
        })
        .filter(Boolean) as AlertItem[];

      // Combine and sort by due date
      const allAlerts = [...vaccinationAlerts, ...medicationAlerts]
        .sort((a, b) => a.daysUntilDue - b.daysUntilDue);

      setAlerts(allAlerts);
    } catch (error) {
      toast({
        title: "Erro ao carregar alertas",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };


  const getUrgencyColor = (urgency: string) => {
    switch (urgency) {
      case 'overdue': return 'destructive';
      case 'urgent': return 'destructive';
      case 'upcoming': return 'default';
      default: return 'secondary';
    }
  };

  const getAlertIcon = (type: 'vaccination' | 'medication', urgency: string) => {
    if (type === 'medication') {
      return <Pill className="h-4 w-4" />;
    }
    switch (urgency) {
      case 'overdue': return <AlertTriangle className="h-4 w-4" />;
      case 'urgent': return <Clock className="h-4 w-4" />;
      case 'upcoming': return <Calendar className="h-4 w-4" />;
      default: return <Calendar className="h-4 w-4" />;
    }
  };

  const getUrgencyText = (daysUntilDue: number) => {
    if (daysUntilDue < 0) return `${Math.abs(daysUntilDue)} dias em atraso`;
    if (daysUntilDue === 0) return "Hoje";
    if (daysUntilDue === 1) return "Amanhã";
    return `Em ${daysUntilDue} dias`;
  };

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar className="h-5 w-5" />
            Alertas de Vacinação
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">Carregando alertas...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Calendar className="h-5 w-5" />
          Alertas de Vacinação e Medicação
          {alerts.length > 0 && (
            <Badge variant={alerts.some(a => a.urgency === 'overdue' || a.urgency === 'urgent') ? 'destructive' : 'default'}>
              {alerts.length}
            </Badge>
          )}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {alerts.length === 0 ? (
          <Alert>
            <CheckCircle className="h-4 w-4" />
            <AlertDescription>
              Todas as vacinações e medicações estão em dia! 🎉
            </AlertDescription>
          </Alert>
        ) : (
          alerts.map((alert) => (
            <Alert key={alert.id} className="border-l-4 border-l-primary">
              <div className="flex items-start gap-3">
                {getAlertIcon(alert.type, alert.urgency)}
                <div className="flex-1 space-y-2">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">
                        {alert.animal.code} - {alert.animal.name}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {alert.title} - {alert.subtitle}
                      </p>
                      <Badge variant="outline" className="mt-1">
                        {alert.type === 'vaccination' ? 'Vacina' : 'Medicamento'}
                      </Badge>
                    </div>
                    <Badge variant={getUrgencyColor(alert.urgency)}>
                      {getUrgencyText(alert.daysUntilDue)}
                    </Badge>
                  </div>
                  
                  <p className="text-sm text-muted-foreground">
                    Data agendada: {new Date(alert.scheduledDate).toLocaleDateString('pt-BR')}
                  </p>
                  
                  {alert.notes && (
                    <p className="text-xs text-muted-foreground italic">
                      Obs: {alert.notes}
                    </p>
                  )}
                </div>
              </div>
            </Alert>
          ))
        )}
      </CardContent>
    </Card>
  );
}