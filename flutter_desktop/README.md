# Fazenda São Petrônio Desktop - Flutter

Sistema de Gestão Pecuária para Desktop com integração Supabase, focado no gerenciamento completo de ovinos e caprinos.

## ✨ Funcionalidades Implementadas

### ✅ Dashboard Completo
- **Estatísticas em tempo real**: Total de animais, saudáveis, gestantes e receita mensal
- **Alertas importantes**: Vacinações pendentes, partos previstos  
- **Ações rápidas**: Registrar nascimentos, agendar vacinações, movimentar animais
- **Grid de animais**: Visualização completa do rebanho com filtros
- **Integração Supabase**: Dados sincronizados com banco online

### ✅ Gestão de Animais
- **Cadastro completo**: Código, nome, espécie, raça, peso, localização
- **Gestão de gestação**: Controle de fêmeas gestantes e previsão de partos
- **Status detalhado**: Saudável, em tratamento, reprodutor
- **Edição e exclusão**: Interface intuitiva para gerenciar dados
- **Sincronização automática**: Dados salvos no Supabase

### ✅ Sistema de Design
- **Tema rural/natureza**: Cores verdes, marrons e douradas inspiradas no campo
- **Modo claro/escuro**: Adaptação automática ao sistema
- **Interface desktop**: Otimizada para telas grandes e produtividade
- **Componentes Material 3**: Design moderno e consistente

## 🛠️ Tecnologias Utilizadas

- **Flutter 3.0+**: Framework multiplataforma
- **Supabase Flutter 2.0+**: Backend como serviço (BaaS)
- **Provider**: Gerenciamento de estado reativo
- **Material Design 3**: Sistema de design moderno
- **Intl**: Formatação de datas e números (pt-BR)

## 🗄️ Integração com Supabase

O aplicativo está totalmente integrado com o Supabase:

- **URL**: `https://heueripmlmuvqdbwyxxs.supabase.co`
- **Tabelas**: animals, vaccinations, financial_records, notes, breeding_records
- **Fallback offline**: Dados mock quando não há conexão
- **Sincronização automática**: Dados salvos online em tempo real

## 📱 Executar o Projeto

### Pré-requisitos
- Flutter SDK 3.0 ou superior
- Dart SDK
- IDE (VS Code, Android Studio)

### Comandos

```bash
# Navegar para o diretório
cd flutter_desktop

# Instalar dependências (incluindo Supabase)
flutter pub get

# Verificar configuração
flutter doctor

# Executar no desktop
flutter run -d windows    # Windows
flutter run -d macos      # macOS  
flutter run -d linux      # Linux

# Build para produção
flutter build windows --release     # Windows
flutter build macos --release       # macOS
flutter build linux --release       # Linux
```

## 📦 Estrutura do Projeto

```
flutter_desktop/
├── lib/
│   ├── main.dart                    # Ponto de entrada + config Supabase
│   ├── models/
│   │   └── animal.dart              # Modelo de dados com JSON
│   ├── services/
│   │   ├── animal_service.dart      # Gerenciamento de estado
│   │   └── supabase_service.dart    # Integração Supabase
│   ├── screens/
│   │   └── dashboard_screen.dart    # Tela principal
│   ├── widgets/
│   │   ├── animal_card.dart         # Card do animal
│   │   ├── animal_form.dart         # Formulário completo
│   │   ├── stats_card.dart          # Card de estatísticas
│   │   └── alert_card.dart          # Card de alertas
│   └── theme/
│       └── app_theme.dart           # Tema rural/natureza
├── pubspec.yaml                     # Dependências + Supabase
├── README.md                        # Este arquivo
└── GUIA_INSTALACAO.md              # Guia detalhado
```

## 🎯 Funcionalidades Online/Offline

### ✅ Modo Online (Supabase)
- Dados sincronizados em tempo real
- Backup automático na nuvem
- Acesso de múltiplos dispositivos
- Estatísticas precisas
- Crud completo de animais

### ✅ Modo Offline (Fallback)
- Dados mock para demonstração
- Interface totalmente funcional  
- Transição suave online/offline
- Indicador visual de conexão

## 🔄 Comparação com React

Este projeto Flutter espelha as funcionalidades da versão React web:

- ✅ **Dashboard idêntico** com estatísticas
- ✅ **Gestão de animais** completa
- ✅ **Integração Supabase** compatível
- ✅ **Design consistente** entre plataformas
- ✅ **Funcionalidades offline** robustas

## 🚀 Sobre React para Desktop

Para converter o projeto React em executável desktop:

### Electron (Mais popular)
```bash
npm install electron electron-builder
# Build para Windows/macOS/Linux
```

### Tauri (Mais leve)
```bash  
npm install @tauri-apps/cli @tauri-apps/api
# Build nativo com Rust
```

### Alternativas
- **Neutralino.js**: Mais leve que Electron
- **NodeGUI**: Interface nativa com Qt
- **PWA**: Instalável como app via navegador

## 🔧 Próximos Passos

### Já Implementado ✅
- [x] Dashboard completo
- [x] Cadastro de animais
- [x] Integração Supabase
- [x] Interface desktop
- [x] Tema rural
- [x] Modo offline

### Em Desenvolvimento 🚧
- [ ] Relatórios PDF
- [ ] Sistema de notificações
- [ ] Upload de fotos
- [ ] Backup/restore
- [ ] Multi-fazendas
- [ ] QR Codes

## 📋 Testando o Sistema

1. **Conectividade**: App testa Supabase automaticamente
2. **Fallback**: Se offline, usa dados mock
3. **Interface**: Totalmente responsiva para desktop
4. **Performance**: Otimizado para produtividade

## 🎨 Customização

### Alterar Nome da Fazenda
```dart
// lib/screens/dashboard_screen.dart
Text('Fazenda São Petrônio') // Alterar aqui
```

### Modificar Cores do Tema
```dart
// lib/theme/app_theme.dart
static const Color primaryGreen = Color(0xFF22C55E); // Alterar cores
```

---

**Fazenda São Petrônio** - Tecnologia a serviço da pecuária brasileira 🐑🐐

*Sistema completo com integração Supabase para gestão moderna do rebanho*