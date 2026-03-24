# 📋 Guia de Instalação - Fazenda São Petrônio Desktop

Guia completo para configurar e executar o sistema desktop da Fazenda São Petrônio.

## 🎯 Pré-requisitos

### 1. Flutter SDK
```bash
# Baixar Flutter do site oficial
https://flutter.dev/docs/get-started/install

# Adicionar ao PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalação
flutter --version
```

### 2. Habilitação Desktop
```bash
# Windows
flutter config --enable-windows-desktop

# macOS  
flutter config --enable-macos-desktop

# Linux
flutter config --enable-linux-desktop
```

### 3. Dependências por Sistema

#### Windows
- Visual Studio 2022 ou Build Tools
- Windows 10 SDK

#### macOS
- Xcode 12+
- macOS 10.14+

#### Linux
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

## 🚀 Instalação do Projeto

### Passo 1: Clonar/Acessar Projeto
```bash
cd flutter_desktop
```

### Passo 2: Instalar Dependências
```bash
flutter pub get
```

### Passo 3: Verificar Configuração
```bash
flutter doctor
```

### Passo 4: Testar Conectividade
```bash
# Teste rápido
flutter run -d windows --debug
```

## 🖥 Executando o Projeto

### Modo Desenvolvimento
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Build de Produção
```bash
# Windows - gera executável em build/windows/runner/Release/
flutter build windows --release

# macOS - gera app em build/macos/Build/Products/Release/
flutter build macos --release

# Linux - gera executável em build/linux/x64/release/bundle/
flutter build linux --release
```

## 🔌 Testando Conectividade Supabase

### 1. Verificação Automática
O app tenta conectar automaticamente ao Supabase ao iniciar:
- ✅ **Conectado**: Mostra dados reais do banco
- ❌ **Offline**: Usa dados mock locais

### 2. Indicadores Visuais
- **Badge "Online"**: Verde quando conectado
- **Badge "Offline Ready"**: Amarelo quando offline
- **Mensagens de Erro**: Detalhes de conexão

### 3. Teste Manual
```bash
# Terminal/CMD - testar URL
curl https://heueripmlmuvqdbwyxxs.supabase.co

# No app - botão "Tentar novamente" se houver erro
```

## 📱 Testando Versão Mobile

### 1. Instalar Capacitor (React)
```bash
# No diretório do projeto React
npm install @capacitor/android @capacitor/ios
npx cap init
```

### 2. Build e Sync
```bash
npm run build
npx cap sync android
npx cap sync ios
```

### 3. Executar no Dispositivo
```bash
# Android
npx cap run android

# iOS (macOS necessário)
npx cap run ios
```

### 4. Usando Emulador
```bash
# Android Studio - criar AVD
# iOS Simulator - usar Xcode

# Executar no emulador
npx cap open android
npx cap open ios
```

## 🔍 Troubleshooting

### Flutter Desktop não funciona
```bash
flutter doctor -v
flutter config --enable-windows-desktop
flutter clean && flutter pub get
```

### Erro de Conexão Supabase
- Verificar internet
- Confirmar URL e chave no código
- Testar em navegador: `https://heueripmlmuvqdbwyxxs.supabase.co`

### Build falha no Windows
```bash
# Instalar Visual Studio Build Tools
# Verificar Windows SDK
flutter doctor
```

### Build falha no macOS
```bash
# Atualizar Xcode
# Verificar certificados
sudo xcode-select --reset
```

### Build falha no Linux
```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

## 📊 Testando Funcionalidades

### 1. Dashboard
- ✅ Carregamento de estatísticas
- ✅ Exibição de animais
- ✅ Alertas funcionando

### 2. Crud de Animais
- ✅ Criar novo animal
- ✅ Editar animal existente
- ✅ Listar todos animais
- ✅ Sincronização com Supabase

### 3. Interface
- ✅ Responsividade desktop
- ✅ Modo escuro/claro
- ✅ Tema rural aplicado

### 4. Performance
- ✅ Carregamento rápido
- ✅ Transições suaves
- ✅ Uso de memória otimizado

## 🎨 Customizações

### Alterar Nome da Fazenda
```dart
// lib/screens/dashboard_screen.dart - linha 67
Text('Sua Fazenda Aqui')
```

### Modificar Cores
```dart
// lib/theme/app_theme.dart
static const Color primaryGreen = Color(0xFF22C55E);
```

### Adicionar Logo
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/logo.png
```

## 📞 Suporte

### Documentação
- [Flutter Desktop](https://flutter.dev/desktop)
- [Supabase Flutter](https://supabase.com/docs/reference/dart)
- [Material 3](https://m3.material.io/)

### Logs de Debug
```bash
flutter logs
# Ou executar com -v para verbose
flutter run -d windows -v
```

### Relatório de Issues
Se encontrar problemas:
1. Executar `flutter doctor -v`
2. Capturar logs de erro
3. Descrever passos para reproduzir
4. Informar sistema operacional

## ✅ Checklist Final

- [ ] Flutter SDK instalado
- [ ] Desktop habilitado para sua plataforma
- [ ] Dependências do sistema instaladas
- [ ] Projeto clonado/acessado
- [ ] `flutter pub get` executado
- [ ] `flutter doctor` sem erros críticos
- [ ] App executando em desenvolvimento
- [ ] Conectividade Supabase testada
- [ ] Build de produção funcionando

**🎉 Pronto! Seu sistema da Fazenda São Petrônio está funcionando!**