import { useState } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { Badge } from "./ui/badge";
import { Progress } from "./ui/progress";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { 
  Download, 
  Upload, 
  Database, 
  Cloud, 
  Shield, 
  Clock,
  CheckCircle,
  AlertCircle
} from "lucide-react";

interface BackupRecord {
  id: string;
  date: string;
  size: string;
  type: 'manual' | 'automatic';
  status: 'success' | 'error' | 'in_progress';
}

export function BackupManager() {
  const { toast } = useToast();
  const [backupProgress, setBackupProgress] = useState(0);
  const [isBackupRunning, setIsBackupRunning] = useState(false);
  const [isRestoreDialogOpen, setIsRestoreDialogOpen] = useState(false);

  const backupHistory: BackupRecord[] = [
    {
      id: '1',
      date: '2024-01-15 14:30:00',
      size: '2.4 MB',
      type: 'automatic',
      status: 'success'
    },
    {
      id: '2',
      date: '2024-01-14 14:30:00',
      size: '2.3 MB',
      type: 'automatic',
      status: 'success'
    },
    {
      id: '3',
      date: '2024-01-13 09:15:00',
      size: '2.2 MB',
      type: 'manual',
      status: 'success'
    }
  ];

  const handleManualBackup = async () => {
    setIsBackupRunning(true);
    setBackupProgress(0);

    try {
      // Simular processo de backup
      for (let i = 0; i <= 100; i += 10) {
        await new Promise(resolve => setTimeout(resolve, 200));
        setBackupProgress(i);
      }

      toast({
        title: "Backup criado com sucesso!",
        description: "Todos os dados foram salvos com segurança."
      });
    } catch (error) {
      toast({
        title: "Erro no backup",
        description: "Não foi possível criar o backup dos dados.",
        variant: "destructive"
      });
    } finally {
      setIsBackupRunning(false);
      setBackupProgress(0);
    }
  };

  const handleRestore = async (backupId: string) => {
    try {
      toast({
        title: "Restauração iniciada",
        description: "Os dados estão sendo restaurados..."
      });
      
      // Simular restauração
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      toast({
        title: "Dados restaurados com sucesso!",
        description: "O sistema foi restaurado para o backup selecionado."
      });
      
      setIsRestoreDialogOpen(false);
    } catch (error) {
      toast({
        title: "Erro na restauração",
        description: "Não foi possível restaurar os dados.",
        variant: "destructive"
      });
    }
  };

  const handleExportData = () => {
    // Simular exportação de dados
    const data = {
      animals: [], // dados dos animais
      vaccinations: [], // dados das vacinações
      notes: [], // anotações
      financial: [] // dados financeiros
    };

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `bego-backup-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    toast({
      title: "Dados exportados!",
      description: "O arquivo de backup foi baixado."
    });
  };

  return (
    <div className="space-y-6">
      {/* Configurações de Backup */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Backup Manual
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <p className="text-sm text-muted-foreground">
              Crie um backup completo de todos os seus dados agora mesmo.
            </p>
            
            {isBackupRunning ? (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Criando backup...</span>
                  <span>{backupProgress}%</span>
                </div>
                <Progress value={backupProgress} className="w-full" />
              </div>
            ) : (
              <div className="space-y-2">
                <Button onClick={handleManualBackup} className="w-full">
                  <Database className="h-4 w-4 mr-2" />
                  Criar Backup Agora
                </Button>
                <Button variant="outline" onClick={handleExportData} className="w-full">
                  <Download className="h-4 w-4 mr-2" />
                  Exportar Dados
                </Button>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Clock className="h-5 w-5" />
              Backup Automático
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm">Status:</span>
              <Badge className="bg-green-100 text-green-800">
                <CheckCircle className="h-3 w-3 mr-1" />
                Ativo
              </Badge>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm">Frequência:</span>
              <span className="text-sm font-medium">Diário às 14:30</span>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm">Próximo backup:</span>
              <span className="text-sm font-medium">Hoje às 14:30</span>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm">Retenção:</span>
              <span className="text-sm font-medium">30 dias</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Sincronização com Nuvem */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Cloud className="h-5 w-5" />
            Sincronização em Nuvem
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center p-4 border rounded-lg">
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-2">
                <CheckCircle className="h-6 w-6 text-green-600" />
              </div>
              <p className="font-medium">Supabase Cloud</p>
              <p className="text-sm text-muted-foreground">Conectado</p>
              <Badge className="mt-2 bg-green-100 text-green-800">Online</Badge>
            </div>
            
            <div className="text-center p-4 border rounded-lg">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-2">
                <Database className="h-6 w-6 text-blue-600" />
              </div>
              <p className="font-medium">Última Sincronização</p>
              <p className="text-sm text-muted-foreground">Há 5 minutos</p>
              <Badge className="mt-2">Automática</Badge>
            </div>
            
            <div className="text-center p-4 border rounded-lg">
              <div className="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-2">
                <Shield className="h-6 w-6 text-yellow-600" />
              </div>
              <p className="font-medium">Dados Protegidos</p>
              <p className="text-sm text-muted-foreground">Criptografia AES-256</p>
              <Badge className="mt-2 bg-yellow-100 text-yellow-800">Seguro</Badge>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Histórico de Backups */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Database className="h-5 w-5" />
              Histórico de Backups
            </div>
            <Dialog open={isRestoreDialogOpen} onOpenChange={setIsRestoreDialogOpen}>
              <DialogTrigger asChild>
                <Button variant="outline" size="sm">
                  <Upload className="h-4 w-4 mr-2" />
                  Restaurar
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Restaurar Backup</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                  {backupHistory.map((backup) => (
                    <div key={backup.id} className="flex items-center justify-between p-3 border rounded-lg">
                      <div>
                        <p className="font-medium">
                          {new Date(backup.date).toLocaleString('pt-BR')}
                        </p>
                        <p className="text-sm text-muted-foreground">
                          {backup.size} • {backup.type === 'manual' ? 'Manual' : 'Automático'}
                        </p>
                      </div>
                      <Button 
                        size="sm" 
                        onClick={() => handleRestore(backup.id)}
                      >
                        Restaurar
                      </Button>
                    </div>
                  ))}
                </div>
              </DialogContent>
            </Dialog>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {backupHistory.map((backup) => (
              <div key={backup.id} className="flex items-center justify-between p-3 border rounded-lg">
                <div className="flex items-center gap-3">
                  {backup.status === 'success' ? (
                    <CheckCircle className="h-5 w-5 text-green-600" />
                  ) : backup.status === 'error' ? (
                    <AlertCircle className="h-5 w-5 text-red-600" />
                  ) : (
                    <Clock className="h-5 w-5 text-yellow-600" />
                  )}
                  <div>
                    <p className="font-medium">
                      {new Date(backup.date).toLocaleString('pt-BR')}
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {backup.size} • {backup.type === 'manual' ? 'Manual' : 'Automático'}
                    </p>
                  </div>
                </div>
                <Badge 
                  variant={backup.status === 'success' ? 'default' : 
                          backup.status === 'error' ? 'destructive' : 'secondary'}
                >
                  {backup.status === 'success' ? 'Sucesso' : 
                   backup.status === 'error' ? 'Erro' : 'Em progresso'}
                </Badge>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}