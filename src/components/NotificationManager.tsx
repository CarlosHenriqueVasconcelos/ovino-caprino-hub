import { useState, useEffect } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { Badge } from "./ui/badge";
import { Switch } from "./ui/switch";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { 
  Bell, 
  BellRing, 
  Calendar, 
  Heart, 
  Pill, 
  AlertTriangle,
  Settings,
  Smartphone
} from "lucide-react";

interface NotificationSettings {
  enabled: boolean;
  vaccinations: boolean;
  births: boolean;
  health: boolean;
  financial: boolean;
  sound: boolean;
  time: string;
}

interface PendingNotification {
  id: string;
  type: 'vaccination' | 'birth' | 'health' | 'financial';
  title: string;
  message: string;
  date: string;
  priority: 'low' | 'medium' | 'high';
  read: boolean;
}

export function NotificationManager() {
  const { toast } = useToast();
  const [settings, setSettings] = useState<NotificationSettings>({
    enabled: true,
    vaccinations: true,
    births: true,
    health: true,
    financial: false,
    sound: true,
    time: '08:00'
  });

  const [notifications, setNotifications] = useState<PendingNotification[]>([]);
  const [pushPermission, setPushPermission] = useState<NotificationPermission>('default');

  useEffect(() => {
    checkNotificationPermission();
    loadNotifications();
  }, []);

  const checkNotificationPermission = async () => {
    if ('Notification' in window) {
      setPushPermission(Notification.permission);
    }
  };

  const requestNotificationPermission = async () => {
    if ('Notification' in window) {
      const permission = await Notification.requestPermission();
      setPushPermission(permission);
      
      if (permission === 'granted') {
        toast({
          title: "Notificações habilitadas!",
          description: "Você receberá alertas importantes sobre seus animais."
        });
      } else {
        toast({
          title: "Notificações negadas",
          description: "Você pode habilitá-las nas configurações do navegador.",
          variant: "destructive"
        });
      }
    }
  };

  const loadNotifications = () => {
    // Mock data - em produção viria do Supabase
    const mockNotifications: PendingNotification[] = [
      {
        id: '1',
        type: 'vaccination',
        title: 'Vacinação Pendente',
        message: 'Benedita (OV001) - Vacina contra Clostridiose vence hoje',
        date: '2024-01-15',
        priority: 'high',
        read: false
      },
      {
        id: '2',
        type: 'birth',
        title: 'Parto Próximo',
        message: 'Esperança (OV003) - Previsão de parto em 3 dias',
        date: '2024-01-18',
        priority: 'medium',
        read: false
      },
      {
        id: '3',
        type: 'health',
        title: 'Atenção Veterinária',
        message: 'Joaquim (CP002) - Consulta de rotina agendada para amanhã',
        date: '2024-01-16',
        priority: 'medium',
        read: true
      }
    ];
    setNotifications(mockNotifications);
  };

  const sendTestNotification = () => {
    if ('Notification' in window && pushPermission === 'granted') {
      new Notification('BEGO Agritech - Teste', {
        body: 'Suas notificações estão funcionando perfeitamente!',
        icon: '/favicon.ico',
        badge: '/favicon.ico'
      });
    }
    
    toast({
      title: "Notificação de teste enviada!",
      description: "Verifique se recebeu a notificação no sistema."
    });
  };

  const markAsRead = (id: string) => {
    setNotifications(prev => 
      prev.map(notif => 
        notif.id === id ? { ...notif, read: true } : notif
      )
    );
  };

  const updateSettings = (key: keyof NotificationSettings, value: boolean | string) => {
    setSettings(prev => ({ ...prev, [key]: value }));
    toast({
      title: "Configurações atualizadas!",
      description: "Suas preferências de notificação foram salvas."
    });
  };

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'vaccination': return <Pill className="h-4 w-4" />;
      case 'birth': return <Heart className="h-4 w-4" />;
      case 'health': return <AlertTriangle className="h-4 w-4" />;
      case 'financial': return <Calendar className="h-4 w-4" />;
      default: return <Bell className="h-4 w-4" />;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'destructive';
      case 'medium': return 'secondary';
      case 'low': return 'outline';
      default: return 'outline';
    }
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <div className="space-y-6">
      {/* Status das Notificações */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Status</p>
                <p className="text-lg font-bold">
                  {pushPermission === 'granted' ? 'Ativo' : 'Inativo'}
                </p>
              </div>
              <div className={`w-3 h-3 rounded-full ${
                pushPermission === 'granted' ? 'bg-green-500' : 'bg-red-500'
              }`} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Não Lidas</p>
                <p className="text-lg font-bold">{unreadCount}</p>
              </div>
              <BellRing className="h-8 w-8 text-orange-500" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Total</p>
                <p className="text-lg font-bold">{notifications.length}</p>
              </div>
              <Bell className="h-8 w-8" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Configurações */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Settings className="h-5 w-5" />
            Configurações de Notificação
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Permissão do Sistema */}
          {pushPermission !== 'granted' && (
            <div className="p-4 border border-orange-200 rounded-lg bg-orange-50">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Smartphone className="h-5 w-5 text-orange-600" />
                  <div>
                    <p className="font-medium text-orange-800">
                      Permissão Necessária
                    </p>
                    <p className="text-sm text-orange-600">
                      Habilite as notificações para receber alertas importantes
                    </p>
                  </div>
                </div>
                <Button onClick={requestNotificationPermission} size="sm">
                  Habilitar
                </Button>
              </div>
            </div>
          )}

          {/* Configurações Gerais */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="notifications-enabled">Notificações Ativas</Label>
                <p className="text-sm text-muted-foreground">
                  Receber notificações do sistema
                </p>
              </div>
              <Switch
                id="notifications-enabled"
                checked={settings.enabled}
                onCheckedChange={(checked) => updateSettings('enabled', checked)}
              />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="sound-enabled">Som</Label>
                <p className="text-sm text-muted-foreground">
                  Reproduzir som nas notificações
                </p>
              </div>
              <Switch
                id="sound-enabled"
                checked={settings.sound}
                onCheckedChange={(checked) => updateSettings('sound', checked)}
                disabled={!settings.enabled}
              />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label>Horário Preferido</Label>
                <p className="text-sm text-muted-foreground">
                  Melhor horário para receber notificações
                </p>
              </div>
              <Select 
                value={settings.time} 
                onValueChange={(value) => updateSettings('time', value)}
                disabled={!settings.enabled}
              >
                <SelectTrigger className="w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="06:00">06:00</SelectItem>
                  <SelectItem value="08:00">08:00</SelectItem>
                  <SelectItem value="10:00">10:00</SelectItem>
                  <SelectItem value="14:00">14:00</SelectItem>
                  <SelectItem value="18:00">18:00</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Tipos de Notificação */}
          <div className="space-y-4">
            <h3 className="font-medium">Tipos de Notificação</h3>
            
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Pill className="h-4 w-4 text-blue-600" />
                  <div>
                    <Label>Vacinações</Label>
                    <p className="text-sm text-muted-foreground">
                      Lembretes de vacinas vencidas ou próximas
                    </p>
                  </div>
                </div>
                <Switch
                  checked={settings.vaccinations}
                  onCheckedChange={(checked) => updateSettings('vaccinations', checked)}
                  disabled={!settings.enabled}
                />
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Heart className="h-4 w-4 text-pink-600" />
                  <div>
                    <Label>Reprodução</Label>
                    <p className="text-sm text-muted-foreground">
                      Partos próximos e ciclos reprodutivos
                    </p>
                  </div>
                </div>
                <Switch
                  checked={settings.births}
                  onCheckedChange={(checked) => updateSettings('births', checked)}
                  disabled={!settings.enabled}
                />
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <AlertTriangle className="h-4 w-4 text-orange-600" />
                  <div>
                    <Label>Saúde</Label>
                    <p className="text-sm text-muted-foreground">
                      Problemas de saúde e consultas veterinárias
                    </p>
                  </div>
                </div>
                <Switch
                  checked={settings.health}
                  onCheckedChange={(checked) => updateSettings('health', checked)}
                  disabled={!settings.enabled}
                />
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-green-600" />
                  <div>
                    <Label>Financeiro</Label>
                    <p className="text-sm text-muted-foreground">
                      Relatórios e alertas financeiros
                    </p>
                  </div>
                </div>
                <Switch
                  checked={settings.financial}
                  onCheckedChange={(checked) => updateSettings('financial', checked)}
                  disabled={!settings.enabled}
                />
              </div>
            </div>
          </div>

          <Button onClick={sendTestNotification} variant="outline" className="w-full">
            <Bell className="h-4 w-4 mr-2" />
            Enviar Notificação de Teste
          </Button>
        </CardContent>
      </Card>

      {/* Lista de Notificações */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BellRing className="h-5 w-5" />
            Notificações Recentes
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {notifications.length === 0 ? (
              <p className="text-center text-muted-foreground py-4">
                Nenhuma notificação pendente
              </p>
            ) : (
              notifications.map((notification) => (
                <div 
                  key={notification.id} 
                  className={`p-3 border rounded-lg cursor-pointer transition-colors hover:bg-muted/50 ${
                    !notification.read ? 'border-orange-200 bg-orange-50' : ''
                  }`}
                  onClick={() => markAsRead(notification.id)}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3">
                      {getNotificationIcon(notification.type)}
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <p className="font-medium">{notification.title}</p>
                          {!notification.read && (
                            <div className="w-2 h-2 bg-orange-500 rounded-full" />
                          )}
                        </div>
                        <p className="text-sm text-muted-foreground mb-2">
                          {notification.message}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          {new Date(notification.date).toLocaleDateString('pt-BR')}
                        </p>
                      </div>
                    </div>
                    <Badge variant={getPriorityColor(notification.priority) as any}>
                      {notification.priority === 'high' ? 'Alta' : 
                       notification.priority === 'medium' ? 'Média' : 'Baixa'}
                    </Badge>
                  </div>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}