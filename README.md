# Ovino Caprino Hub

Projeto principal da Fazenda Sao Petronio, com app Flutter (desktop/mobile), banco local SQLite e sincronizacao com Supabase.

## Estrutura do repositorio

- `flutter_desktop/`
  App Flutter principal (desktop + Android), com arquitetura em camadas (`models`, `data`, `services`, `widgets`).
- `supabase/`
  Migrations SQL e artefatos de schema remoto.
- `src/`
  Front-end web auxiliar (quando usado no fluxo atual).

## Caminhos importantes (Flutter)

- Entrada do app: `flutter_desktop/lib/main.dart`
- Banco local e schema: `flutter_desktop/lib/data/local_db.dart`
- Migracoes locais: `flutter_desktop/lib/services/migration_service.dart`
- Backup/restore Supabase: `flutter_desktop/lib/data/backup_repository.dart`
- Dominio de animais: `flutter_desktop/lib/data/animal_repository.dart`
- Fluxo de venda/obito: `flutter_desktop/lib/data/animal_lifecycle_repository.dart`
- Reproducao e parentesco: `flutter_desktop/lib/services/breeding_service.dart`
- Matriz e ranking: `flutter_desktop/lib/widgets/breeding/matrix_selection_tab.dart`
- Teste de fluxo: `flutter_desktop/integration_test/ui_crawler_test.dart`

## Requisitos

- Flutter SDK compativel com o projeto
- Android SDK (para build mobile)
- Dispositivo Android com depuracao USB habilitada
- Supabase URL e chave configuradas no app

## Comandos principais (Windows)

No PowerShell, a partir da raiz:

```powershell
cd flutter_desktop
flutter pub get
flutter run -d windows
flutter run -d <ANDROID_DEVICE_ID>
flutter test
flutter analyze
```

## Build e execucao Android

1. Conectar dispositivo (`adb devices`).
2. Rodar:

```powershell
cd flutter_desktop
flutter run -d <DEVICE_ID>
```

Observacao: `flutter run` atualiza o app e, em regra, preserva o banco local do app enquanto o pacote/assinatura nao mudarem e sem desinstalacao.

## Banco local x Supabase

- Local: SQLite no sandbox do app.
- Remoto: Supabase (Postgres + PostgREST).
- Sincronizacao de backup:
  - Upload local -> remoto (espelhamento)
  - Restore remoto -> local

Tabelas criticas no fluxo atual:

- `animals`, `sold_animals`, `deceased_animals`
- `animal_weights`, `weight_alerts`
- `breeding_records`, `animal_lineage`, `animal_lineage_meta`
- `matrix_evaluations`
- `notes`, `vaccinations`, `medications`
- `app_settings`, `reports`, `push_tokens`

## Regras funcionais atuais (resumo)

- Categoria e status sanitario foram separados de status reprodutivo.
- Venda e obito movem registro para tabelas historicas sem perder vinculos importantes.
- Parentesco em reproducao possui bloqueios com grau explicito.
- Historico de pesos preserva marcos iniciais.
- Matrizes possuem avaliacao tecnica e score com recomendacao.

## Troubleshooting rapido

- Erro `Failed host lookup`:
  Validar URL do Supabase e conectividade DNS do dispositivo.
- Erro de coluna inexistente no backup:
  Schema remoto desatualizado em relacao ao local. Aplicar migrations pendentes.
- Warnings Gradle/AGP/Kotlin:
  Nao bloqueiam imediato, mas devem ser atualizados para versoes suportadas.
- Ambiente WSL com `bash\r` no wrapper:
  Ajustar fim de linha dos scripts (`LF`) para executar `flutter analyze` localmente.

## Fluxo recomendado antes de publicar

1. `flutter analyze`
2. `flutter test`
3. Smoke test manual (rebanho, reproducao, matrizes, backup/restore)
4. Verificar schema Supabase alinhado ao local
5. Validar backup e restore em base de homologacao

## Observacao sobre documentacao

Este README consolida a documentacao operacional da raiz do projeto.
Se precisar, podemos recriar documentos detalhados por modulo dentro de `docs/` sem poluir a raiz.

