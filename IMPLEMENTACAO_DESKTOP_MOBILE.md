# BEGO Agritech - Guia de Implementação Desktop/Mobile

## 🎯 Visão Geral
Sistema de gestão de ovinos e caprinos com funcionalidade **offline-first** real através de aplicativos nativos para desktop e mobile.

## 📱 Configuração Mobile (iOS/Android)

### Pré-requisitos
- Node.js instalado
- Android Studio (para Android)
- Xcode (para iOS - apenas no Mac)

### Passos para Deploy Mobile:

1. **Clone o projeto do GitHub**
   ```bash
   git clone [seu-repositorio]
   cd bego-ovino-caprino
   npm install
   ```

2. **Build do projeto**
   ```bash
   npm run build
   ```

3. **Adicionar plataformas**
   ```bash
   # Para Android
   npx cap add android
   
   # Para iOS (apenas no Mac)  
   npx cap add ios
   ```

4. **Sincronizar o projeto**
   ```bash
   npx cap sync
   ```

5. **Executar no dispositivo**
   ```bash
   # Android
   npx cap run android
   
   # iOS
   npx cap run ios
   ```

## 🖥️ Configuração Desktop

### Opção 1: Electron (Recomendado)
```bash
npm install electron electron-builder --save-dev
```

Criar `electron.js`:
```javascript
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  
  win.loadFile('dist/index.html');
}

app.whenReady().then(createWindow);
```

### Opção 2: Tauri (Rust - Mais Leve)
```bash
npm install @tauri-apps/cli --save-dev
npx tauri init
```

## 🗄️ Banco de Dados Offline

### Implementação Atual (Demo)
- **LocalStorage**: Para prototipação rápida
- **Dados simulados**: Animais, vacinações, pesos

### Produção Recomendada
```bash
# Para Capacitor (Mobile)
npm install @capacitor-community/sqlite

# Para Electron (Desktop)  
npm install sqlite3 better-sqlite3
```

### Schema SQL Sugerido:
```sql
-- Animais
CREATE TABLE animals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  species TEXT CHECK(species IN ('Ovino', 'Caprino')),
  breed TEXT,
  gender TEXT CHECK(gender IN ('Macho', 'Fêmea')),
  birth_date DATE,
  weight REAL,
  status TEXT,
  location TEXT,
  pregnant BOOLEAN DEFAULT FALSE,
  sync_status TEXT DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Vacinações
CREATE TABLE vaccinations (
  id TEXT PRIMARY KEY,
  animal_id TEXT REFERENCES animals(id),
  vaccine_name TEXT NOT NULL,
  application_date DATE,
  next_due DATE,
  sync_status TEXT DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pesos históricos
CREATE TABLE weight_records (
  id TEXT PRIMARY KEY,
  animal_id TEXT REFERENCES animals(id),
  weight REAL NOT NULL,
  measure_date DATE,
  sync_status TEXT DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 🔄 Sistema de Sincronização

### Estratégia Offline-First:
1. **Armazenamento Local**: Todas as operações são salvas localmente primeiro
2. **Sync Flags**: Cada registro tem status (pending/synced/error)
3. **Conflict Resolution**: Last-write-wins ou merge inteligente
4. **Background Sync**: Quando há conexão disponível

### Implementação da Sincronização:
```typescript
class SyncService {
  async syncWhenOnline() {
    if (!navigator.onLine) return;
    
    const pending = await begoDb.getPendingSync();
    
    // Upload dados locais
    await this.uploadPendingData(pending);
    
    // Download atualizações do servidor
    await this.downloadServerUpdates();
    
    // Marcar como sincronizado
    await begoDb.updateLastSyncDate();
  }
}
```

## 🌐 API Backend (Opcional)

### Stack Sugerida:
- **Node.js + Express** ou **Python + FastAPI**
- **PostgreSQL** para produção
- **JWT** para autenticação
- **WebSockets** para sync em tempo real

### Endpoints Básicos:
```
POST /api/animals          # Criar animal
GET  /api/animals          # Listar animais
PUT  /api/animals/:id      # Atualizar animal
POST /api/sync             # Sincronização bulk
GET  /api/sync/changes     # Buscar mudanças desde timestamp
```

## 📊 Funcionalidades Implementadas

### ✅ Atual (v1.0)
- Dashboard com estatísticas
- Listagem de animais com cards visuais
- Dados simulados offline
- Interface responsiva
- Design system rural/natureza

### 🔄 Próximas Iterações
- Formulário cadastro de animais
- Controle de vacinações
- Relatórios de reprodução
- Controle financeiro básico
- Sincronização com servidor
- Notificações push
- Backup automático

## 🚀 Comandos de Deploy

### Development
```bash
npm run dev          # Desenvolvimento web
npx cap run android  # Teste Android
npx cap run ios      # Teste iOS
```

### Production Build
```bash
npm run build        # Build web
npx cap sync         # Sync mobile
electron-builder     # Build desktop
```

## 📋 Checklist de Implementação

### Mobile App:
- [ ] Configurar Capacitor
- [ ] Testar em emulador
- [ ] Implementar SQLite
- [ ] Configurar ícones/splash
- [ ] Testar offline real
- [ ] Deploy na loja

### Desktop App:
- [ ] Configurar Electron
- [ ] Implementar auto-updater
- [ ] Configurar instalador
- [ ] Testar multiplataforma
- [ ] Assinatura digital

### Backend (Opcional):
- [ ] Configurar servidor
- [ ] Implementar autenticação
- [ ] APIs de sincronização
- [ ] Backup automático
- [ ] Monitoramento

## 🔧 Troubleshooting

### Problemas Comuns:
1. **Capacitor não funciona**: Verificar se o build foi executado
2. **SQLite não conecta**: Verificar permissões do app
3. **Sync falha**: Verificar conectividade e endpoints
4. **Performance**: Implementar paginação e lazy loading

---

**Nota**: Este sistema foi projetado para funcionar 100% offline. A sincronização é um add-on para backup e colaboração entre dispositivos.