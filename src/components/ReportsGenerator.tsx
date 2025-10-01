import { useState } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Label } from "./ui/label";
import { Input } from "./ui/input";
import { useToast } from "./ui/use-toast";
import { AnimalService } from "@/lib/offline-animal-service";
import { FileText, Download, Calendar, TrendingUp, Shield, Heart, DollarSign } from "lucide-react";

interface ReportsGeneratorProps {
  onClose: () => void;
}

export function ReportsGenerator({ onClose }: ReportsGeneratorProps) {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState<any>(null);
  
  const [formData, setFormData] = useState({
    report_type: 'Animais' as 'Animais' | 'Vacinações' | 'Reprodução' | 'Saúde' | 'Financeiro',
    start_date: '',
    end_date: '',
    species: 'Todos',
    status: 'Todos'
  });

  const reportTypes = [
    { value: 'Animais', label: '🐑 Relatório de Animais', icon: FileText },
    { value: 'Vacinações', label: '💉 Relatório de Vacinações', icon: Shield },
    { value: 'Reprodução', label: '🤱 Relatório de Reprodução', icon: Heart },
    { value: 'Saúde', label: '🏥 Relatório de Saúde', icon: TrendingUp },
    { value: 'Financeiro', label: '💰 Relatório Financeiro', icon: DollarSign }
  ];

  const generateReport = async () => {
    setLoading(true);
    try {
      const animals = await animalService.getAnimals();
      const vaccinations = await animalService.getVaccinations();
      const stats = await animalService.getStats();

      let filteredData;
      let reportContent;

      switch (formData.report_type) {
        case 'Animais':
          filteredData = animals.filter(animal => {
            if (formData.species !== 'Todos' && animal.species !== formData.species) return false;
            if (formData.status !== 'Todos' && animal.status !== formData.status) return false;
            return true;
          });
          reportContent = {
            title: `Relatório de Animais - ${new Date().toLocaleDateString('pt-BR')}`,
            summary: {
              total: filteredData.length,
              healthy: filteredData.filter(a => a.status === 'Saudável').length,
              treatment: filteredData.filter(a => a.status === 'Em tratamento').length,
              avgWeight: filteredData.reduce((sum, a) => sum + a.weight, 0) / filteredData.length || 0
            },
            data: filteredData
          };
          break;

        case 'Vacinações':
          const startDate = formData.start_date ? new Date(formData.start_date) : new Date(0);
          const endDate = formData.end_date ? new Date(formData.end_date) : new Date();
          
          filteredData = vaccinations.filter(v => {
            const schedDate = new Date(v.scheduled_date);
            return schedDate >= startDate && schedDate <= endDate;
          });
          
          reportContent = {
            title: `Relatório de Vacinações - ${new Date().toLocaleDateString('pt-BR')}`,
            period: `${startDate.toLocaleDateString('pt-BR')} a ${endDate.toLocaleDateString('pt-BR')}`,
            summary: {
              total: filteredData.length,
              scheduled: filteredData.filter(v => v.status === 'Agendada').length,
              applied: filteredData.filter(v => v.status === 'Aplicada').length,
              cancelled: filteredData.filter(v => v.status === 'Cancelada').length
            },
            data: filteredData
          };
          break;

        case 'Reprodução':
          const pregnantAnimals = animals.filter(a => a.pregnant);
          const recentBirths = animals.filter(a => {
            const birthDate = new Date(a.birth_date);
            const threeMonthsAgo = new Date();
            threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
            return birthDate >= threeMonthsAgo;
          });
          
          reportContent = {
            title: `Relatório de Reprodução - ${new Date().toLocaleDateString('pt-BR')}`,
            summary: {
              pregnant: pregnantAnimals.length,
              recentBirths: recentBirths.length,
              expectedDeliveries: pregnantAnimals.filter(a => a.expected_delivery).length,
              reproductionRate: ((recentBirths.length / animals.filter(a => a.gender === 'Fêmea').length) * 100) || 0
            },
            pregnant: pregnantAnimals,
            recentBirths: recentBirths
          };
          break;

        case 'Saúde':
          const healthyAnimals = animals.filter(a => a.status === 'Saudável');
          const sickAnimals = animals.filter(a => a.status === 'Em tratamento');
          
          reportContent = {
            title: `Relatório de Saúde - ${new Date().toLocaleDateString('pt-BR')}`,
            summary: {
              healthy: healthyAnimals.length,
              sick: sickAnimals.length,
              healthRate: ((healthyAnimals.length / animals.length) * 100) || 0,
              avgWeight: stats.avgWeight
            },
            healthyAnimals,
            sickAnimals
          };
          break;

        case 'Financeiro':
          const estimatedValue = animals.length * 350; // R$ 350 por animal
          const vaccinationCosts = vaccinations.filter(v => v.status === 'Aplicada').length * 25;
          
          reportContent = {
            title: `Relatório Financeiro - ${new Date().toLocaleDateString('pt-BR')}`,
            summary: {
              totalAnimals: animals.length,
              estimatedValue,
              vaccinationCosts,
              netValue: estimatedValue - vaccinationCosts,
              avgValuePerAnimal: estimatedValue / animals.length || 0
            }
          };
          break;
      }

      // Salvar o relatório no banco
      await animalService.createReport({
        title: reportContent.title,
        report_type: formData.report_type,
        parameters: formData,
        generated_by: 'Sistema'
      });

      setReportData(reportContent);
      toast({ title: "Relatório gerado com sucesso!" });
    } catch (error) {
      toast({
        title: "Erro ao gerar relatório",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const exportToPDF = () => {
    // Simular exportação para PDF
    const content = JSON.stringify(reportData, null, 2);
    const blob = new Blob([content], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${reportData.title}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    toast({ title: "Relatório exportado com sucesso!" });
  };

  return (
    <div className="w-full max-w-4xl mx-auto">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Gerador de Relatórios
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {!reportData ? (
            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Tipo de Relatório *</Label>
                  <Select 
                    value={formData.report_type} 
                    onValueChange={(value: any) => setFormData({...formData, report_type: value})}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {reportTypes.map((type) => (
                        <SelectItem key={type.value} value={type.value}>
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                
                {formData.report_type === 'Animais' && (
                  <>
                    <div className="space-y-2">
                      <Label>Espécie</Label>
                      <Select 
                        value={formData.species} 
                        onValueChange={(value) => setFormData({...formData, species: value})}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Todos">Todas as espécies</SelectItem>
                          <SelectItem value="Ovino">🐑 Ovino</SelectItem>
                          <SelectItem value="Caprino">🐐 Caprino</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    
                    <div className="space-y-2">
                      <Label>Status</Label>
                      <Select 
                        value={formData.status} 
                        onValueChange={(value) => setFormData({...formData, status: value})}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Todos">Todos os status</SelectItem>
                          <SelectItem value="Saudável">Saudável</SelectItem>
                          <SelectItem value="Em tratamento">Em tratamento</SelectItem>
                          <SelectItem value="Reprodutor">Reprodutor</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </>
                )}
              </div>

              {formData.report_type === 'Vacinações' && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="start_date">Data Inicial</Label>
                    <Input
                      id="start_date"
                      type="date"
                      value={formData.start_date}
                      onChange={(e) => setFormData({...formData, start_date: e.target.value})}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="end_date">Data Final</Label>
                    <Input
                      id="end_date"
                      type="date"
                      value={formData.end_date}
                      onChange={(e) => setFormData({...formData, end_date: e.target.value})}
                    />
                  </div>
                </div>
              )}

              <div className="flex justify-end space-x-2">
                <Button variant="outline" onClick={onClose}>
                  Cancelar
                </Button>
                <Button onClick={generateReport} disabled={loading}>
                  {loading ? 'Gerando...' : 'Gerar Relatório'}
                </Button>
              </div>
            </div>
          ) : (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">{reportData.title}</h3>
                <div className="flex space-x-2">
                  <Button onClick={exportToPDF} className="flex items-center gap-2">
                    <Download className="h-4 w-4" />
                    Exportar
                  </Button>
                  <Button variant="outline" onClick={() => setReportData(null)}>
                    Novo Relatório
                  </Button>
                  <Button variant="outline" onClick={onClose}>
                    Fechar
                  </Button>
                </div>
              </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {Object.entries(reportData.summary || {}).map(([key, value]) => (
                <div key={key} className="bg-white p-4 rounded-lg border">
                  <div className="text-sm text-gray-600 capitalize">
                    {key.replace(/([A-Z])/g, ' $1').trim()}
                  </div>
                  <div className="text-2xl font-bold">
                    {typeof value === 'number' && key.includes('Rate') ? 
                      `${value.toFixed(1)}%` : 
                      typeof value === 'number' && key.includes('Value') ?
                      `R$ ${value.toFixed(2)}` :
                      typeof value === 'number' && key.includes('Weight') ?
                      `${value.toFixed(1)} kg` :
                      String(value)
                    }
                  </div>
                </div>
              ))}
            </div>

              {reportData.period && (
                <Card>
                  <CardContent className="p-4">
                    <div className="flex items-center gap-2">
                      <Calendar className="h-4 w-4" />
                      <span className="text-sm text-muted-foreground">Período:</span>
                      <span className="font-medium">{reportData.period}</span>
                    </div>
                  </CardContent>
                </Card>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}