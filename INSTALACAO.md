# 📱 INSTALAÇÃO - BEGO Agritech Flutter Desktop

## 🔧 Configuração do Ambiente

### 1. Instalar Flutter
```bash
# Windows
# Baixar Flutter SDK em: https://flutter.dev/docs/get-started/install/windows
# Extrair para C:\flutter
# Adicionar C:\flutter\bin ao PATH

# Linux/macOS
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalação
flutter doctor
```

### 2. Configurar Desktop
```bash
# Habilitar suporte desktop
flutter config --enable-windows-desktop  # Windows
flutter config --enable-macos-desktop    # macOS  
flutter config --enable-linux-desktop    # Linux

# Verificar suporte
flutter devices
```

### 3. Dependências do Sistema

#### Windows
- Visual Studio 2022 com "Desktop development with C++"
- Windows 10/11

#### macOS  
- Xcode 12.0 ou superior
- macOS 10.14 ou superior

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Fedora
sudo dnf install clang cmake ninja-build pkg-config gtk3-devel xz-devel
```

## 🚀 Executar o Projeto

### 1. Clonar e Configurar
```bash
# Navegar para o diretório
cd flutter_desktop

# Instalar dependências
flutter pub get

# Verificar se está tudo OK
flutter doctor
```

### 2. Executar em Desenvolvimento
```bash
# Executar no desktop (detecta automaticamente)
flutter run

# Executar em dispositivo específico
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Hot reload durante desenvolvimento
# Pressione 'r' no terminal para recarregar
# Pressione 'R' para restart completo
```

### 3. Build para Produção
```bash
# Windows
flutter build windows --release
# Executável estará em: build/windows/runner/Release/

# macOS
flutter build macos --release  
# App estará em: build/macos/Build/Products/Release/

# Linux
flutter build linux --release
# Executável estará em: build/linux/x64/release/bundle/
```

## 🎯 Funcionalidades Disponíveis

### ✅ Funcionando Offline
- Dashboard completo com estatísticas
- Lista de animais com dados mockados  
- Cards detalhados de cada animal
- Sistema de alertas e ações rápidas
- Tema rural com cores naturais
- Modo claro/escuro automático

### 🔄 Próximas Implementações
- Integração com Supabase (online)
- Cadastro e edição de animais
- Sistema de sincronização offline/online
- Upload de fotos dos animais
- Relatórios em PDF
- QR Codes para identificação

## 🐛 Solução de Problemas

### Flutter Doctor Issues
```bash
# Se aparecer problemas no flutter doctor
flutter doctor --android-licenses  # Android (opcional)
flutter upgrade                    # Atualizar Flutter
flutter clean                      # Limpar cache
flutter pub get                    # Reinstalar dependências
```

### Problemas de Build
```bash
# Limpar e reconstruir
flutter clean
flutter pub get
flutter run

# Se persistir, deletar pasta build
rm -rf build/  # Linux/macOS
rmdir /s build # Windows
```

### Performance Desktop
- **Windows**: Use Release mode para melhor performance
- **macOS**: Verifique permissões do Xcode
- **Linux**: Instale todas as dependências GTK

## 📊 Dados de Teste

O sistema inclui dados mockados para testes:
- **3 animais exemplo**: Benedita, Joaquim, Esperança
- **Estatísticas realistas**: 45 animais, métricas de saúde
- **Alertas funcionais**: Vacinações, partos previstos

## 🔧 Personalização

### Alterar Cores do Tema
Edite `lib/theme/app_theme.dart`:
```dart
static const Color primaryGreen = Color(0xFF22C55E); // Sua cor principal
static const Color accentGold = Color(0xFFEAB308);   // Cor de destaque
```

### Adicionar Novos Animais
Edite `lib/services/animal_service.dart`:
```dart
Animal(
  id: "SEU_ID",
  name: "Nome do Animal",
  species: "Ovino", // ou "Caprino"
  // ... outros campos
),
```

## 📞 Suporte

- **Documentação Flutter**: https://flutter.dev/docs
- **Material Design 3**: https://m3.material.io/
- **Provider State Management**: https://pub.dev/packages/provider

---

**BEGO Agritech Flutter Desktop** - Gestão Pecuária Moderna 🚀