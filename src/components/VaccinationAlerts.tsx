import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Alert, AlertDescription } from "./ui/alert";
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";
import { AnimalService } from "@/lib/offline-animal-service";
import type { Vaccination, Animal } from "@/lib/types";
import { useToast } from "./ui/use-toast";
import { Calendar, AlertTriangle, Clock, CheckCircle } from "lucide-react";

interface VaccinationAlert {
  vaccination: Vaccination;
  animal: Animal;
  daysUntilDue: number;
  urgency: 'overdue' | 'urgent' | 'upcoming' | 'normal';
}

export function VaccinationAlerts() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [alerts, setAlerts] = useState<VaccinationAlert[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadVaccinationAlerts();
  }, []);

  const loadVaccinationAlerts = async () => {
    try {
      setLoading(true);
      const [vaccinations, animals] = await Promise.all([
        animalService.getVaccinations(),
        animalService.getAnimals()
      ]);

      const animalMap = new Map(animals.map(animal => [animal.id, animal]));
      const now = new Date();

      const alertsData: VaccinationAlert[] = vaccinations
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
            vaccination,
            animal,
            daysUntilDue,
            urgency
          };
        })
        .filter(Boolean)
        .sort((a, b) => a!.daysUntilDue - b!.daysUntilDue) as VaccinationAlert[];

      setAlerts(alertsData);
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

  const markAsApplied = async (vaccinationId: string) => {
    try {
      await animalService.updateVaccination(vaccinationId, {
        status: 'Aplicada',
        applied_date: new Date().toISOString().split('T')[0]
      });
      toast({ title: "Vacinação marcada como aplicada!" });
      loadVaccinationAlerts();
    } catch (error) {
      toast({
        title: "Erro ao atualizar vacinação",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
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

  const getUrgencyIcon = (urgency: string) => {
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
          Alertas de Vacinação
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
              Todas as vacinações estão em dia! 🎉
            </AlertDescription>
          </Alert>
        ) : (
          alerts.map((alert) => (
            <Alert key={alert.vaccination.id} className="border-l-4 border-l-primary">
              <div className="flex items-start gap-3">
                {getUrgencyIcon(alert.urgency)}
                <div className="flex-1 space-y-2">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">
                        {alert.animal.code} - {alert.animal.name}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {alert.vaccination.vaccine_name} - {alert.vaccination.vaccine_type}
                      </p>
                    </div>
                    <Badge variant={getUrgencyColor(alert.urgency)}>
                      {getUrgencyText(alert.daysUntilDue)}
                    </Badge>
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <p className="text-sm text-muted-foreground">
                      Data agendada: {new Date(alert.vaccination.scheduled_date).toLocaleDateString('pt-BR')}
                    </p>
                    <Button 
                      size="sm" 
                      onClick={() => markAsApplied(alert.vaccination.id)}
                      className="h-7 px-3"
                    >
                      <CheckCircle className="h-3 w-3 mr-1" />
                      Aplicar
                    </Button>
                  </div>
                  
                  {alert.vaccination.notes && (
                    <p className="text-xs text-muted-foreground italic">
                      Obs: {alert.vaccination.notes}
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