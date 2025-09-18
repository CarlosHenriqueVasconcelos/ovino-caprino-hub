import { useState } from "react";
import { BegoDashboard } from "./BegoDashboard";
import { BreedingManagement } from "./BreedingManagement";
import { WeightTracking } from "./WeightTracking";
import { NotesManager } from "./NotesManager";
import { FinancialControl } from "./FinancialControl";
import { BackupManager } from "./BackupManager";
import { NotificationManager } from "./NotificationManager";
import { Button } from "./ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { 
  Home, 
  Heart, 
  Scale, 
  FileText, 
  PawPrint,
  BarChart3,
  Settings
} from "lucide-react";

export function CompleteDashboard() {
  const [activeTab, setActiveTab] = useState("dashboard");

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-amber-50">
      <div className="container mx-auto p-4">
        {/* Header */}
        <div className="mb-8 text-center">
          <h1 className="text-4xl font-bold text-emerald-800 mb-2">
            🐑 BEGO Agritech 🐐
          </h1>
          <p className="text-emerald-600 text-lg">
            Sistema Completo de Gestão para Ovinocultura e Caprinocultura
          </p>
        </div>

        {/* Navigation */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-7 mb-8">
            <TabsTrigger value="dashboard" className="flex items-center gap-2">
              <Home className="h-4 w-4" />
              Dashboard
            </TabsTrigger>
            <TabsTrigger value="breeding" className="flex items-center gap-2">
              <Heart className="h-4 w-4" />
              Reprodução
            </TabsTrigger>
            <TabsTrigger value="weight" className="flex items-center gap-2">
              <Scale className="h-4 w-4" />
              Peso & Crescimento
            </TabsTrigger>
            <TabsTrigger value="notes" className="flex items-center gap-2">
              <FileText className="h-4 w-4" />
              Anotações
            </TabsTrigger>
            <TabsTrigger value="reports" className="flex items-center gap-2">
              <BarChart3 className="h-4 w-4" />
              Relatórios
            </TabsTrigger>
            <TabsTrigger value="financial" className="flex items-center gap-2">
              <PawPrint className="h-4 w-4" />
              Financeiro
            </TabsTrigger>
            <TabsTrigger value="system" className="flex items-center gap-2">
              <Settings className="h-4 w-4" />
              Sistema
            </TabsTrigger>
          </TabsList>

          <TabsContent value="dashboard">
            <BegoDashboard />
          </TabsContent>

          <TabsContent value="breeding">
            <div className="space-y-6">
              <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6">
                <h2 className="text-2xl font-bold text-emerald-800 mb-4 flex items-center gap-2">
                  <Heart className="h-6 w-6" />
                  Manejo Reprodutivo
                </h2>
                <p className="text-muted-foreground mb-6">
                  Controle completo do ciclo reprodutivo, desde a cobertura até o nascimento dos filhotes.
                  Acompanhe fêmeas prenhes, calcule previsões de parto e registre nascimentos.
                </p>
                <BreedingManagement />
              </div>
            </div>
          </TabsContent>

          <TabsContent value="weight">
            <div className="space-y-6">
              <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6">
                <h2 className="text-2xl font-bold text-emerald-800 mb-4 flex items-center gap-2">
                  <Scale className="h-6 w-6" />
                  Controle de Peso e Desenvolvimento
                </h2>
                <p className="text-muted-foreground mb-6">
                  Monitore o desenvolvimento dos animais através do controle de peso.
                  Acompanhe o crescimento por categoria de idade e identifique animais com peso inadequado.
                </p>
                <WeightTracking />
              </div>
            </div>
          </TabsContent>

          <TabsContent value="notes">
            <div className="space-y-6">
              <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6">
                <h2 className="text-2xl font-bold text-emerald-800 mb-4 flex items-center gap-2">
                  <FileText className="h-6 w-6" />
                  Anotações e Observações
                </h2>
                <p className="text-muted-foreground mb-6">
                  Registre observações importantes sobre saúde, comportamento, alimentação e reprodução.
                  Organize por categoria e prioridade para um acompanhamento eficiente.
                </p>
                <NotesManager />
              </div>
            </div>
          </TabsContent>

          <TabsContent value="reports">
            <div className="space-y-6">
              <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6 text-center">
                <BarChart3 className="h-16 w-16 mx-auto mb-4 text-emerald-600" />
                <h2 className="text-2xl font-bold text-emerald-800 mb-4">
                  Relatórios Avançados
                </h2>
                <p className="text-muted-foreground mb-6">
                  Acesse relatórios detalhados sobre produtividade, saúde do rebanho, 
                  performance reprodutiva e análises financeiras através do dashboard principal.
                </p>
                <Button onClick={() => setActiveTab("dashboard")} className="bg-emerald-600 hover:bg-emerald-700">
                  Ir para Dashboard Principal
                </Button>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="financial">
            <div className="space-y-6">
              <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6">
                <h2 className="text-2xl font-bold text-emerald-800 mb-4 flex items-center gap-2">
                  <PawPrint className="h-6 w-6" />
                  Controle Financeiro
                </h2>
                <p className="text-muted-foreground mb-6">
                  Gerencie receitas e despesas, controle custos de produção e acompanhe 
                  a rentabilidade do seu rebanho de ovinos e caprinos.
                </p>
                <FinancialControl />
              </div>
            </div>
          </TabsContent>

          <TabsContent value="system">
            <div className="space-y-6">
              <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6">
                <h2 className="text-2xl font-bold text-emerald-800 mb-4 flex items-center gap-2">
                  <Settings className="h-6 w-6" />
                  Configurações do Sistema
                </h2>
                <p className="text-muted-foreground mb-6">
                  Configure notificações, gerencie backups e mantenha seus dados sempre seguros.
                </p>
                
                <Tabs defaultValue="notifications" className="w-full">
                  <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="notifications">Notificações</TabsTrigger>
                    <TabsTrigger value="backup">Backup & Dados</TabsTrigger>
                  </TabsList>
                  
                  <TabsContent value="notifications" className="mt-6">
                    <NotificationManager />
                  </TabsContent>
                  
                  <TabsContent value="backup" className="mt-6">
                    <BackupManager />
                  </TabsContent>
                </Tabs>
              </div>
            </div>
          </TabsContent>
        </Tabs>

        {/* Footer */}
        <div className="mt-12 text-center text-sm text-emerald-600">
          <p>BEGO Agritech - Sistema Profissional para Gestão de Ovinos e Caprinos</p>
          <p>Todas as funcionalidades integradas com banco de dados Supabase</p>
        </div>
      </div>
    </div>
  );
}