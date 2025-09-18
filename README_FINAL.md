# 🐑 BEGO Agritech - Sistema Completo de Gestão Pecuária 🐐

Sistema profissional para gestão de ovinos e caprinos com funcionalidades completas online/offline e aplicativo mobile.

## 📱 Capacitor Mobile App

O sistema já está configurado com Capacitor para funcionar como aplicativo mobile nativo. Recursos incluem:

- **Notificações Push**: Alertas automáticos de vacinação, partos e saúde
- **Funcionamento Offline**: Cache de dados para uso sem internet
- **Sincronização Automática**: Dados sincronizam quando conecta na internet
- **Interface Nativa**: Experiência mobile otimizada para fazendeiros

### Para testar no seu dispositivo:

1. Exporte o projeto para GitHub (botão "Export to GitHub")
2. Clone o repositório no seu computador
3. Execute os comandos:

```bash
npm install
npm run build
npx cap add android  # ou npx cap add ios
npx cap sync
npx cap run android  # ou npx cap run ios
```

## 🎯 Funcionalidades Completas Implementadas

### ✅ Dashboard Principal
- Estatísticas em tempo real do rebanho
- Cards com métricas importantes
- Alertas de vacinação urgentes
- Ações rápidas para operações frequentes

### ✅ Gestão de Animais
- **Cadastro completo**: Código, nome, espécie, raça, peso, localização
- **Edição em tempo real**: Modificar dados com validação
- **Status de saúde**: Controle de condições e tratamentos
- **Gestação**: Controle de fêmeas prenhes com previsão de parto

### ✅ Sistema de Vacinação
- **Agendamento**: Programar vacinas por animal e tipo
- **Alertas automáticos**: Notificações de vacinas vencidas/próximas
- **Histórico completo**: Registro de todas as aplicações
- **Veterinário**: Controle de quem aplicou cada vacina

### ✅ Controle Reprodutivo
- **Registro de coberturas**: Data, reprodutor usado, observações
- **Acompanhamento de gestação**: Previsão de partos
- **Histórico reprodutivo**: Performance de cada matriz
- **Alertas de parto**: Notificações 3 dias antes do parto previsto

### ✅ Controle de Peso e Desenvolvimento
- **Pesagens regulares**: Histórico de evolução do peso
- **Gráficos de crescimento**: Visualização da curva de desenvolvimento
- **Alertas de peso**: Animais fora da faixa ideal
- **Categorização por idade**: Filhotes, jovens, adultos

### ✅ Sistema de Anotações
- **Categorização**: Saúde, reprodução, alimentação, comportamento
- **Prioridades**: Baixa, média, alta
- **Busca avançada**: Filtros por categoria, animal, data
- **Histórico completo**: Todas as observações registradas

### ✅ Controle Financeiro
- **Receitas e despesas**: Registro detalhado por categoria
- **Associação com animais**: Vincular custos/receitas a animais específicos
- **Relatórios financeiros**: Balanço e demonstrativos
- **Categorias específicas**: Ração, medicamentos, vendas, reprodução

### ✅ Busca e Filtros Avançados
- **Busca global**: Por código, nome, raça
- **Filtros múltiplos**: Espécie, sexo, status, localização, gestação
- **Resultados instantâneos**: Interface responsiva
- **Exportação de dados**: Relatórios personalizados

### ✅ Relatórios Profissionais
- **Relatório de Animais**: Por espécie, status, período
- **Relatório de Vacinações**: Cobertura vacinal, cronograma
- **Relatório Reprodutivo**: Taxa de prenhez, nascimentos
- **Relatório de Saúde**: Índices sanitários, tratamentos
- **Relatório Financeiro**: Rentabilidade, custos de produção

### ✅ Notificações e Alertas
- **Push notifications**: Alertas nativos no celular
- **Configurações personalizadas**: Escolher tipos de alerta
- **Horários preferenciais**: Definir melhor horário para notificações
- **Som e vibração**: Customização de alertas

### ✅ Backup e Sincronização
- **Backup automático**: Dados salvos diariamente
- **Sincronização em nuvem**: Supabase Cloud integrado
- **Exportação manual**: Backup local em JSON
- **Recuperação**: Restaurar dados de backups anteriores

## 🗄️ Banco de Dados Supabase

### Tabelas Implementadas:
- **animals**: Dados completos dos animais
- **vaccinations**: Cronograma e histórico de vacinas
- **notes**: Sistema de anotações categorizadas
- **breeding_records**: Controle reprodutivo completo
- **financial_records**: Gestão financeira detalhada
- **reports**: Histórico de relatórios gerados
- **push_tokens**: Gerenciamento de notificações push

### Recursos de Segurança:
- **Row Level Security (RLS)**: Políticas de acesso configuradas
- **Criptografia**: Dados protegidos com AES-256
- **Backup automático**: Retenção de 30 dias
- **Sincronização real-time**: Atualizações instantâneas

## 🖥️ Versão Desktop Flutter

Na pasta `flutter_desktop/` há uma versão Flutter Desktop com:

### Para instalar e executar:

1. **Instalar Flutter**:
```bash
# Baixar Flutter SDK em: https://flutter.dev/docs/get-started/install
# Adicionar ao PATH do sistema
flutter doctor  # Verificar instalação
```

2. **Habilitar Desktop**:
```bash
flutter config --enable-windows-desktop  # Windows
flutter config --enable-macos-desktop    # macOS  
flutter config --enable-linux-desktop    # Linux
```

3. **Executar o projeto**:
```bash
cd flutter_desktop
flutter pub get
flutter run  # Executa automaticamente
```

4. **Criar executável**:
```bash
# Windows
flutter build windows --release
# Executável em: build/windows/runner/Release/

# macOS
flutter build macos --release  
# App em: build/macos/Build/Products/Release/

# Linux
flutter build linux --release
# Executável em: build/linux/x64/release/bundle/
```

### Funcionalidades Desktop:
- **Interface nativa**: Material Design 3
- **Dados offline**: SQLite integrado
- **Sincronização**: Conecta com Supabase quando online
- **Performance otimizada**: Flutter engine nativo
- **Tema responsivo**: Modo claro/escuro automático

## 📊 Dados de Teste

O sistema inclui dados realistas para demonstração:
- **3 animais exemplo**: Benedita (OV001), Joaquim (CP002), Esperança (OV003)
- **Estatísticas**: 45 animais, 42 saudáveis, 8 prenhes, 3 em tratamento
- **Vacinações**: Cronograma completo com alertas
- **Transações financeiras**: Receitas e despesas categorizadas

## 🔧 Tecnologias Utilizadas

### Frontend Web:
- **React 18**: Framework principal
- **TypeScript**: Tipagem estática
- **Tailwind CSS**: Estilização responsiva
- **Shadcn/ui**: Componentes profissionais
- **Vite**: Build tool otimizado

### Mobile (Capacitor):
- **Capacitor**: Wrapper nativo
- **Push Notifications**: Alertas nativos
- **Local Storage**: Cache offline
- **Haptic Feedback**: Feedback tátil

### Backend:
- **Supabase**: Backend as a Service
- **PostgreSQL**: Banco de dados robusto
- **Real-time**: Sincronização instantânea
- **Row Level Security**: Segurança avançada

### Desktop (Flutter):
- **Flutter**: Framework cross-platform
- **Material Design 3**: Interface moderna
- **SQLite**: Banco local
- **Provider**: Gerenciamento de estado

## 🚀 Deploy e Distribuição

### Web App:
- Deploy automático via Lovable
- PWA ready para instalação
- Otimizado para mobile e desktop

### Mobile App:
- Build para Android/iOS
- Distribuição via Play Store/App Store
- Assinatura digital incluída

### Desktop App:
- Executáveis nativos para Windows/macOS/Linux
- Instalador automatizado
- Auto-updater integrado

## 📞 Suporte e Documentação

- **Documentação técnica**: Comentários detalhados no código
- **Guias de instalação**: README específicos por plataforma
- **Dados de exemplo**: Cenários realistas para testes
- **Troubleshooting**: Soluções para problemas comuns

---

**BEGO Agritech** - Sistema Profissional Completo para Gestão de Ovinos e Caprinos 🚀

*Desenvolvido com tecnologias modernas para máxima eficiência e confiabilidade.*