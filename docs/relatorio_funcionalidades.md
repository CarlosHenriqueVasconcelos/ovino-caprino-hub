# Relatorio de funcionalidades do aplicativo

Este relatorio foi montado a partir do codigo atual da aplicacao Flutter (telas em `lib/features/.../presentation`).

## 1) Mapa geral de navegacao

Abas principais da navegacao inferior:

- Inicio
- Rebanho
- Manejo
- Financeiro
- Mais

Referencia:

- `lib/features/navigation/dashboard_tabs.dart`
- `lib/app/presentation/complete_dashboard_screen.dart`

## 2) Funcionalidades por tela

### 2.1 Autenticacao

**Tela: Login**

- Login por e-mail e senha.
- Validacao de campos (e-mail valido, senha minima).
- Tratamento de erros comuns:
  - credenciais invalidas
  - falta de internet
  - conta sem fazenda vinculada
- Alternancia mostrar/ocultar senha.

Referencia: `lib/features/auth/presentation/login_screen.dart`

### 2.2 Inicio (Dashboard)

**Tela: Inicio / Dashboard**

- KPIs principais do rebanho.
- Alertas compactos com atalho para modulos (peso, vacinas, reproducao).
- Acoes rapidas:
  - Cadastrar animal
  - Registrar peso (atalho para modulo de Peso)
  - Vacinar (abre formulario)
  - Nova cobertura (atalho para Reproducao)
  - Medicamento (agendamento rapido)
- Atualizacao automatica apos sincronizacao.

Referencias:

- `lib/features/dashboard/presentation/dashboard_tab.dart`
- `lib/features/dashboard/widgets/dashboard_quick_actions.dart`
- `lib/features/dashboard/widgets/dashboard_alerts_compact.dart`

### 2.3 Rebanho

**Tela: Rebanho**

- Listagem principal de animais.
- Busca por nome/codigo.
- Filtros por:
  - status sanitario (Saudavel, Em tratamento, Ferido, Vendido, Obito)
  - cor
  - categoria
- Modo especial de visualizacao para Vendidos e Obitos.
- Paginacao/listagem incremental.
- Cadastro de novo animal.
- Edicao de animal.
- Registro de obito (move para lista de obitos).
- Exclusao em cascata (animal + pesos + vacinas + medicacoes + anotacoes + financeiro + reproducao).
- Historico completo do animal em dialog dedicado.

Referencias:

- `lib/features/herd/presentation/herd_tab.dart`
- `lib/features/herd/presentation/widgets/animal_card.dart`
- `lib/features/herd/presentation/widgets/animal_history_dialog.dart`

### 2.4 Manejo (Hub)

**Tela: Hub de Manejo**

- Visao geral dos modulos de manejo com cards.
- KPIs do manejo (pendencias, vacinas atrasadas, peso pendente, etc.).
- Abertura direta dos modulos:
  - Alimentacao
  - Peso
  - Reproducao
  - Matrizes
  - Vacinas
  - Anotacoes
  - Farmacia

Referencia: `lib/features/management/presentation/management_hub_screen.dart`

### 2.5 Manejo - Alimentacao

**Tela: Alimentacao (lista de baias)**

- Cadastro de baia.
- Edicao de baia.
- Exclusao de baia.
- KPI de baias, racoes e kg/dia.
- Acesso ao detalhe da baia.

**Tela: Detalhe da baia**

- Lista de racoes/tratos da baia.
- Adicionar trato/racao.
- Editar trato.
- Excluir trato.
- KPIs por baia (racoes, kg/dia, frequencia diaria).

**Dialog: Formulario de trato**

- Campos: tipo, quantidade, vezes por dia, horarios, observacoes.
- Adicao de multiplos horarios.
- Validacoes de preenchimento.

Referencias:

- `lib/features/feeding/presentation/feeding_screen.dart`
- `lib/features/feeding/presentation/widgets/pen_details_screen.dart`
- `lib/features/feeding/presentation/widgets/feeding_form_dialog.dart`

### 2.6 Manejo - Peso

**Tela: Peso**

- Subabas:
  - Adultos
  - Borregos
- KPI de adultos, borregos e alertas de pesagem.

**Subaba: Adultos**

- Busca por nome/codigo.
- Controle mensal de pesagem (janela de 24 meses).
- Registro de pesagem mensal por mes (M1..M24).
- Atualizacao do peso atual do animal.
- Paginacao.

**Subaba: Borregos**

- Busca por nome/codigo.
- Controle de marcos de peso (nascimento, 30d, 60d, 90d, 120d).
- Registro/edicao de pesos por marco.
- Promocao de borrego para adulto/reprodutor.
- Paginacao.

Referencias:

- `lib/features/weight/presentation/weight_tracking_screen.dart`
- `lib/features/weight/presentation/widgets/adult_weight_tracking.dart`
- `lib/features/weight/presentation/widgets/lamb_weight_tracking.dart`

### 2.7 Manejo - Reproducao

**Tela: Reproducao**

- Pipeline por etapas:
  - Encabritamento
  - Ultrassom
  - Gestantes
  - Concluidos
  - Falhados
- Busca por femea.
- Card de alertas reprodutivos.
- Nova cobertura via wizard.
- Importacao de cobertura/registro.
- Ordenacao por prazo dentro das etapas.

**Acoes por etapa (card de ciclo)**

- Separar animais (transicao de etapa).
- Registrar resultado de ultrassom (confirmada/nao confirmada).
- Registrar nascimento (1 ou 2 crias) com abertura do formulario de crias.
- Cancelar encabritamento.

Referencias:

- `lib/features/breeding/presentation/breeding_management_screen.dart`
- `lib/features/breeding/presentation/widgets/breeding_stage_actions.dart`
- `lib/features/breeding/presentation/widgets/breeding_wizard_dialog.dart`
- `lib/features/breeding/presentation/widgets/breeding_import_dialog.dart`

### 2.8 Manejo - Matrizes

**Tela: Matrizes (ranking zootecnico)**

- Ranking de candidatas por score final.
- KPI de avaliadas, aprovar e descartar.
- Filtros:
  - especie
  - categoria
  - status reprodutivo
  - lote
  - itens por pagina
- Cadastro de nova avaliacao de matriz.
- Edicao da ultima avaliacao.
- Exclusao da ultima avaliacao.
- Paginacao.

Referencias:

- `lib/features/breeding/presentation/matrix_selection_tab.dart`
- `lib/features/breeding/presentation/widgets/matrix_evaluation_form_dialog.dart`

### 2.9 Manejo - Vacinas e Medicamentos

**Tela: Vacinas/Medicamentos**

- Subabas:
  - Vacinacoes
  - Medicamentos
- KPIs por status (atrasadas/agendadas/aplicadas).
- Filtro por status (inclui canceladas).
- Lista paginada com scroll infinito.

**Acoes de item (vacinacao/medicamento)**

- Ver detalhes.
- Marcar como aplicado(a).
- Remarcar data.
- Cancelar.

**Cadastro/Agendamento**

- Agendar vacinacao.
- Agendar medicamento.
- Escolha de animal (autocomplete).
- Integracao com estoque da farmacia para medicamento.
- Validacao de estoque no agendamento de medicamento.

Referencias:

- `lib/features/medication/presentation/medication_management_screen.dart`
- `lib/features/medication/presentation/widgets/vaccination_form.dart`
- `lib/features/medication/presentation/widgets/add_medication_dialog.dart`

### 2.10 Manejo - Anotacoes

**Tela: Anotacoes**

- Listagem de anotacoes com paginacao.
- Busca textual.
- Filtros por categoria, prioridade e nao lidas.
- KPIs: total, nao lidas, alta prioridade.
- Nova anotacao.
- Marcar anotacao como lida.
- Visualizar detalhes da anotacao.
- Excluir anotacao.

Referencias:

- `lib/features/notes/presentation/notes_management_screen.dart`
- `lib/features/notes/presentation/widgets/notes_form.dart`

### 2.11 Manejo - Farmacia

**Tela: Farmacia**

- Listagem de estoque de medicamentos.
- Busca por nome/apresentacao.
- Filtros:
  - Todos
  - Estoque Baixo
  - Vencendo
  - Vencidos
- Ordenacao por nome, estoque ou validade.
- KPIs de produtos/estoque baixo/vencendo.
- Cadastro de novo produto.
- Edicao de produto.
- Excluir produto.
- Detalhes do produto.
- Ajuste de estoque:
  - adicionar quantidade
  - remover quantidade
- Controle de motivo de movimentacao.

Referencias:

- `lib/features/pharmacy/presentation/pharmacy_management_screen.dart`
- `lib/features/pharmacy/presentation/widgets/pharmacy_stock_form.dart`
- `lib/features/pharmacy/presentation/widgets/pharmacy_stock_details.dart`

### 2.12 Financeiro

**Tela: Financeiro (acesso protegido por senha/PIN)**

- Bloqueio de acesso com senha.
- Desbloqueio manual da area financeira.

**Subabas do Financeiro**

- Dashboard financeiro.
- Contas a Pagar.
- Contas a Receber.
- Recorrentes.
- Fluxo de Caixa.

**Acoes principais**

- Novo lancamento rapido (receita/despesa).
- Criar/editar/excluir conta.
- Marcar conta como paga/recebida.
- Filtros por status (Todos, Pendente, Pago, Vencido) em pagar/receber.
- Recorrencias:
  - criar recorrencia
  - excluir recorrencia em cascata
- Fluxo de caixa projetado (6 meses) com receitas, despesas e saldo.

Referencias:

- `lib/features/financial/presentation/financial_complete_screen.dart`
- `lib/features/financial/presentation/widgets/financial_accounts_payable.dart`
- `lib/features/financial/presentation/widgets/financial_accounts_receivable.dart`
- `lib/features/financial/presentation/widgets/financial_recurring.dart`
- `lib/features/financial/presentation/widgets/financial_cash_flow.dart`

### 2.13 Mais (Hub)

**Tela: Hub Mais**

- Acesso organizado por:
  - Acesso Principal
  - Configuracoes e Utilidades
- Card de sincronizacao (status + acao sincronizar).
- Saida de conta.

Referencia: `lib/features/more/presentation/more_hub_screen.dart`

### 2.14 Mais - Relatorios

**Tela: Hub de Relatorios e Analises**

- Tipos de relatorio (abas):
  - Animais
  - Pesos
  - Vacinacoes
  - Medicacoes
  - Reproducao
  - Financeiro (protegido por senha)
  - Anotacoes
- Filtros dinamicos por contexto:
  - periodo (7/30/90 dias, mes atual, ano atual, personalizado)
  - especie, sexo, categoria, cor, lote
  - status animal/vacinacao/medicacao
  - status reprodutivo e etapa reprodutiva
  - tipo e categoria financeira
  - leitura/prioridade de anotacoes
- Modos de visualizacao:
  - Resumo
  - Grafico
  - Tabela
- Ordenacao e paginacao de tabela.
- Exportar CSV.
- Salvar relatorio.

Referencias:

- `lib/features/reports/presentation/reports_hub_screen.dart`
- `lib/features/reports/presentation/reports_filter_panel.dart`
- `lib/features/reports/presentation/reports_export_bar.dart`
- `lib/features/reports/presentation/reports_view_switcher.dart`

### 2.15 Mais - Historico

**Tela: Historico de Atividades**

- Consolidacao de eventos de:
  - animais
  - vacinacoes
  - medicacoes
  - reproducao
  - financeiro
  - anotacoes
- Filtro por tipo de atividade.
- Indicadores: hoje, semana, mes.
- Atualizacao manual.
- Visualizar detalhes de um item.

Observacao: opcao "Remover" no menu informa que a remocao deve ser feita no modulo de origem.

Referencia: `lib/features/system/presentation/history_screen.dart`

### 2.16 Mais - Sistema

**Tela: Configuracoes do Sistema**

- Notificacoes:
  - ativar/desativar
  - lembrete de vacinacao
  - lembrete de parto
  - monitoramento de peso
- Regra genetica:
  - bloquear cruzamento entre primos
- Backup e dados:
  - backup automatico (frequencia)
  - backup manual para Supabase
  - restauracao de backup do Supabase
- Sincronizacao:
  - ativar/desativar sync automatico
  - sincronizar manualmente
  - status da sincronizacao
- Banco local:
  - estatisticas de dados
- Logs:
  - visualizar logs
  - exportar logs
  - limpar logs
- Acoes gerais:
  - sobre, ajuda, reportar problema
  - sair da conta
  - limpar todos os dados locais (acao destrutiva)
- Ferramentas de diagnostico em modo debug.

Referencia: `lib/features/system/presentation/system_settings_screen.dart`

## 3) Resumo rapido por area de manejo

- Alimentacao: gestao de baias e racoes/tratos.
- Peso: controle de pesagem de adultos e borregos com marcos.
- Reproducao: pipeline completo do ciclo reprodutivo com acoes por etapa.
- Matrizes: ranking tecnico e avaliacao zootecnica com recomendacao.
- Vacinas/Medicamentos: agenda sanitaria com aplicacao, remarcacao e cancelamento.
- Anotacoes: registro operacional com filtros e controle de leitura.
- Farmacia: estoque, validade e movimentacao de medicamentos.

## 4) Observacoes

- O relatorio descreve funcionalidades implementadas no codigo atual.
- Algumas acoes estao presentes como placeholder visual (ex.: ajuda/reportar problema exibem mensagem local no estado atual).
