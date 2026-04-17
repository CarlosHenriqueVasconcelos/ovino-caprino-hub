# Casos de Uso Operacionais (Criacao, Edicao, Registro, Agendamento)

Data de atualizacao: 2026-04-16
Fonte: codigo em `lib/features/**/presentation` + `integration_test/ui_crawler_test.dart`.

## Convencoes

- Tipos: `CRIACAO`, `EDICAO`, `REGISTRO`, `AGENDAMENTO`, `STATUS`, `EXCLUSAO`.
- Cobertura automatica:
  - `AUTO_OK`: coberto diretamente no `integration_test/ui_crawler_test.dart`.
  - `AUTO_PARCIAL`: coberto de forma generica/smoke (sem validacao profunda de regra).
  - `AUTO_NAO`: ainda sem cobertura automatizada no teste funcional atual.

## Matriz de modulos cobertos

- Autenticacao
- Dashboard (atalhos)
- Rebanho
- Manejo > Alimentacao
- Manejo > Peso
- Manejo > Reproducao
- Manejo > Matrizes
- Manejo > Vacinas/Medicamentos
- Manejo > Anotacoes
- Manejo > Farmacia
- Financeiro
- Mais > Relatorios
- Mais > Sistema

## Casos de uso detalhados

| ID | Modulo | Tipo | Caso de uso | Pre-condicao | Dados minimos | Resultado esperado | Cobertura |
|---|---|---|---|---|---|---|---|
| UC-AUTH-REGISTRO-001 | Autenticacao | REGISTRO | Login com e-mail e senha | Usuario ativo | e-mail, senha | Sessao autenticada e dashboard carregado | AUTO_PARCIAL |
| UC-DASH-CRIACAO-001 | Dashboard | CRIACAO | Cadastrar animal via atalho | Usuario logado | nome, codigo, sexo, especie | Novo animal salvo | AUTO_NAO |
| UC-DASH-REGISTRO-001 | Dashboard | REGISTRO | Abrir fluxo de vacinacao via atalho "Vacinar" | Usuario logado | selecao de animal e vacina | Vacinacao registrada/agendada | AUTO_NAO |
| UC-DASH-AGENDAMENTO-001 | Dashboard | AGENDAMENTO | Agendar medicamento via atalho "Medicamento" | Usuario logado e estoque disponivel | animal, medicamento, data | Agenda de medicamento criada | AUTO_NAO |
| UC-HERD-CRIACAO-001 | Rebanho | CRIACAO | Criar novo animal | Usuario logado no modulo Rebanho | nome, codigo, sexo, especie | Animal aparece na listagem | AUTO_OK |
| UC-HERD-EDICAO-001 | Rebanho | EDICAO | Editar cadastro de animal | Animal existente | alteracao de 1+ campo | Dados atualizados no card/historico | AUTO_OK |
| UC-HERD-REGISTRO-001 | Rebanho | REGISTRO | Registrar obito do animal | Animal ativo | confirmacao de obito | Animal movido para lista de obitos | AUTO_NAO |
| UC-HERD-EXCLUSAO-001 | Rebanho | EXCLUSAO | Excluir animal com cascata de registros | Animal existente | confirmacao de exclusao | Animal e registros relacionados removidos | AUTO_NAO |
| UC-HERD-REGISTRO-002 | Rebanho | REGISTRO | Abrir historico completo do animal | Animal existente | selecao do animal | Historico consolidado exibido | AUTO_NAO |
| UC-FEED-CRIACAO-001 | Alimentacao | CRIACAO | Cadastrar nova baia | Usuario no modulo Alimentacao | nome da baia | Baia criada com sucesso | AUTO_PARCIAL |
| UC-FEED-EDICAO-001 | Alimentacao | EDICAO | Editar baia existente | Baia existente | alteracao de nome/numero/obs | Baia atualizada | AUTO_NAO |
| UC-FEED-EXCLUSAO-001 | Alimentacao | EXCLUSAO | Excluir baia | Baia existente | confirmacao | Baia e tratos associados removidos | AUTO_NAO |
| UC-FEED-CRIACAO-002 | Alimentacao | CRIACAO | Adicionar trato/racao na baia | Baia existente | tipo, quantidade, vezes/dia, horario | Trato criado | AUTO_PARCIAL |
| UC-FEED-EDICAO-002 | Alimentacao | EDICAO | Editar trato/racao | Trato existente | alteracao de campos | Trato atualizado | AUTO_NAO |
| UC-FEED-EXCLUSAO-002 | Alimentacao | EXCLUSAO | Excluir trato/racao | Trato existente | confirmacao | Trato removido | AUTO_NAO |
| UC-WEIGHT-REGISTRO-001 | Peso (Adultos) | REGISTRO | Registrar pesagem mensal de adulto (M1..M24) | Animal adulto existente | mes, peso (kg) | Peso mensal salvo e peso atual atualizado | AUTO_NAO |
| UC-WEIGHT-REGISTRO-002 | Peso (Borregos) | REGISTRO | Registrar marco de peso (+ Registrar) | Borrego com marco atingido | peso do marco | Marco salvo no historico | AUTO_NAO |
| UC-WEIGHT-EDICAO-001 | Peso (Borregos) | EDICAO | Editar pesos de borrego (nascimento, 30d, 60d, 90d, 120d) | Borrego existente | 1+ pesos ajustados | Pesos atualizados e historico consistente | AUTO_NAO |
| UC-WEIGHT-STATUS-001 | Peso (Borregos) | STATUS | Promover borrego para Reprodutor/Adulto | Borrego apto | confirmacao | Categoria atualizada no cadastro | AUTO_NAO |
| UC-BREED-REGISTRO-001 | Reproducao | REGISTRO | Registrar nova cobertura (wizard/form) | Femea selecionavel | femea, macho opcional, data | Registro criado em Encabritamento | AUTO_NAO |
| UC-BREED-REGISTRO-002 | Reproducao | REGISTRO | Importar registro de reproducao existente | Dados historicos disponiveis | femea, datas-base, status/resultado | Registro importado no estagio correto | AUTO_NAO |
| UC-BREED-REGISTRO-003 | Reproducao | REGISTRO | Separar animais no ciclo reprodutivo | Registro em encabritamento | acao "Separar Animais" | Registro avanca para aguardando ultrassom | AUTO_NAO |
| UC-BREED-REGISTRO-004 | Reproducao | REGISTRO | Registrar resultado de ultrassom | Registro aguardando ultrassom | confirmada ou nao confirmada | Registro atualizado (gestante/falhou) | AUTO_NAO |
| UC-BREED-REGISTRO-005 | Reproducao | REGISTRO | Registrar nascimento (1 ou 2 crias) | Registro em gestacao confirmada | qtd crias, dados das crias | Parto registrado e crias cadastradas | AUTO_NAO |
| UC-BREED-EXCLUSAO-001 | Reproducao | EXCLUSAO | Cancelar encabritamento | Registro ativo | confirmacao | Registro cancelado/removido | AUTO_NAO |
| UC-MATRIX-CRIACAO-001 | Matrizes | CRIACAO | Criar avaliacao de matriz | Animal elegivel | campos zootecnicos da avaliacao | Nova avaliacao incluida no ranking | AUTO_NAO |
| UC-MATRIX-EDICAO-001 | Matrizes | EDICAO | Editar avaliacao de matriz | Avaliacao existente | alteracao de score/campos | Ranking recalculado | AUTO_NAO |
| UC-MATRIX-EXCLUSAO-001 | Matrizes | EXCLUSAO | Excluir avaliacao de matriz | Avaliacao existente | confirmacao | Avaliacao removida do ranking | AUTO_NAO |
| UC-MED-AGENDAMENTO-001 | Vacinas/Medicamentos | AGENDAMENTO | Agendar vacinacao | Animal existente | animal, nome vacina, data | Vacinacao criada com status Agendada | AUTO_PARCIAL |
| UC-MED-AGENDAMENTO-002 | Vacinas/Medicamentos | AGENDAMENTO | Agendar medicamento com integracao farmacia | Animal e estoque disponivel | animal, item farmacia, data, dosagem | Medicamento criado com status Agendado | AUTO_PARCIAL |
| UC-MED-STATUS-001 | Vacinas/Medicamentos | STATUS | Marcar vacinacao como aplicada | Vacinacao agendada/atrasada | data aplicacao (quando exigido) | Status alterado para Aplicada | AUTO_NAO |
| UC-MED-STATUS-002 | Vacinas/Medicamentos | STATUS | Remarcar vacinacao | Vacinacao existente | nova data | Nova data gravada | AUTO_NAO |
| UC-MED-STATUS-003 | Vacinas/Medicamentos | STATUS | Cancelar vacinacao | Vacinacao existente | confirmacao | Status alterado para Cancelada | AUTO_NAO |
| UC-MED-STATUS-004 | Vacinas/Medicamentos | STATUS | Marcar medicamento como aplicado | Medicamento agendado/atrasado | data aplicacao (quando exigido) | Status alterado para Aplicado | AUTO_NAO |
| UC-MED-STATUS-005 | Vacinas/Medicamentos | STATUS | Remarcar medicamento | Medicamento existente | nova data | Nova data gravada | AUTO_NAO |
| UC-MED-STATUS-006 | Vacinas/Medicamentos | STATUS | Cancelar medicamento | Medicamento existente | confirmacao | Status alterado para Cancelado | AUTO_NAO |
| UC-MED-REGISTRO-001 | Vacinas/Medicamentos | REGISTRO | Registrar dose/vacinacao pelo formulario dedicado | Animal existente | animal, vacina, tipo, data | Registro de vacinacao persistido | AUTO_NAO |
| UC-NOTE-CRIACAO-001 | Anotacoes | CRIACAO | Criar nova anotacao | Usuario no modulo Anotacoes | titulo, conteudo (animal opcional) | Anotacao criada na lista | AUTO_PARCIAL |
| UC-NOTE-STATUS-001 | Anotacoes | STATUS | Marcar anotacao como lida | Anotacao nao lida | acao "Marcar como lida" | Campo de leitura atualizado | AUTO_NAO |
| UC-NOTE-EXCLUSAO-001 | Anotacoes | EXCLUSAO | Excluir anotacao | Anotacao existente | confirmacao | Anotacao removida | AUTO_NAO |
| UC-PHARM-CRIACAO-001 | Farmacia | CRIACAO | Cadastrar novo medicamento em estoque | Usuario no modulo Farmacia | nome, tipo, unidade, estoque inicial | Item criado no estoque | AUTO_PARCIAL |
| UC-PHARM-EDICAO-001 | Farmacia | EDICAO | Editar medicamento em estoque | Item existente | alteracao de campos | Item atualizado | AUTO_NAO |
| UC-PHARM-REGISTRO-001 | Farmacia | REGISTRO | Registrar entrada de estoque | Item existente | quantidade, motivo | Estoque incrementado e movimento registrado | AUTO_NAO |
| UC-PHARM-REGISTRO-002 | Farmacia | REGISTRO | Registrar saida de estoque | Item existente | quantidade, motivo | Estoque decrementado e movimento registrado | AUTO_NAO |
| UC-PHARM-EXCLUSAO-001 | Farmacia | EXCLUSAO | Excluir medicamento do estoque | Item existente | confirmacao | Item removido | AUTO_NAO |
| UC-FIN-CRIACAO-001 | Financeiro | CRIACAO | Criar receita | Area financeira desbloqueada | categoria, valor, vencimento | Conta a receber criada | AUTO_OK |
| UC-FIN-CRIACAO-002 | Financeiro | CRIACAO | Criar despesa | Area financeira desbloqueada | categoria, valor, vencimento | Conta a pagar criada | AUTO_OK |
| UC-FIN-EDICAO-001 | Financeiro | EDICAO | Editar conta (receita/despesa) | Conta existente | alteracao de 1+ campos | Conta atualizada | AUTO_NAO |
| UC-FIN-STATUS-001 | Financeiro | STATUS | Marcar despesa como paga | Conta de despesa pendente | acao de confirmacao | Status alterado para Pago | AUTO_NAO |
| UC-FIN-STATUS-002 | Financeiro | STATUS | Marcar receita como recebida | Conta de receita pendente | acao de confirmacao | Status alterado para Recebido/Pago | AUTO_NAO |
| UC-FIN-EXCLUSAO-001 | Financeiro | EXCLUSAO | Excluir conta financeira | Conta existente | confirmacao | Conta removida | AUTO_NAO |
| UC-FIN-CRIACAO-003 | Financeiro | CRIACAO | Cadastrar recorrencia financeira | Area financeira desbloqueada | tipo, categoria, valor, frequencia | Recorrencia criada | AUTO_NAO |
| UC-FIN-EXCLUSAO-002 | Financeiro | EXCLUSAO | Excluir recorrencia financeira | Recorrencia existente | confirmacao | Recorrencia removida (com cascata de futuras, quando aplicavel) | AUTO_NAO |
| UC-FIN-REGISTRO-001 | Financeiro | REGISTRO | Registrar receita de venda de animal | Animal selecionavel e categoria "Venda de Animais" | animal, valor, vencimento | Conta criada e fluxo de venda aplicado | AUTO_NAO |
| UC-REP-REGISTRO-001 | Relatorios | REGISTRO | Salvar relatorio configurado | Usuario em Mais > Relatorios | tipo de relatorio + filtros | Relatorio salvo na base local | AUTO_NAO |
| UC-REP-REGISTRO-002 | Relatorios | REGISTRO | Exportar relatorio em CSV | Dados filtrados disponiveis | tipo de relatorio + filtros | CSV gerado/exportado | AUTO_NAO |
| UC-SYS-EDICAO-001 | Sistema | EDICAO | Alterar preferencias de notificacao | Usuario em Mais > Sistema | flags de notificacao | Configuracoes persistidas | AUTO_NAO |
| UC-SYS-EDICAO-002 | Sistema | EDICAO | Alterar regra genetica (bloquear primos) | Usuario em Mais > Sistema | flag de regra genetica | Regra salva em configuracoes | AUTO_NAO |
| UC-SYS-REGISTRO-001 | Sistema | REGISTRO | Executar backup manual (Supabase) | Conexao e credenciais validas | acao de backup | Backup concluido com log de progresso | AUTO_NAO |
| UC-SYS-REGISTRO-002 | Sistema | REGISTRO | Executar restauracao de backup | Backup remoto disponivel | confirmacao de restauracao | Dados locais substituidos por backup | AUTO_NAO |
| UC-SYS-STATUS-001 | Sistema | STATUS | Ativar/desativar sincronizacao automatica | Usuario em Mais > Sistema | toggle de sync | Estado de sync atualizado | AUTO_PARCIAL |
| UC-SYS-REGISTRO-003 | Sistema | REGISTRO | Sincronizar manualmente | Sync habilitado | acao "Sincronizar" | Nova tentativa de sync executada | AUTO_PARCIAL |
| UC-SYS-REGISTRO-004 | Sistema | REGISTRO | Exportar logs do sistema | Logs existentes | acao de exportar | Arquivo de logs exportado | AUTO_NAO |
| UC-SYS-EXCLUSAO-001 | Sistema | EXCLUSAO | Limpar logs do sistema | Logs existentes | confirmacao | Logs removidos | AUTO_NAO |
| UC-SYS-EXCLUSAO-002 | Sistema | EXCLUSAO | Limpar todos os dados locais | Confirmacao explicita do usuario | confirmacao dupla | Base local resetada | AUTO_NAO |

## Casos derivados dos pontos observados (UX/Rebanho/Peso)

| ID | Modulo | Tipo | Caso de uso | Pre-condicao | Dados minimos | Resultado esperado | Cobertura |
|---|---|---|---|---|---|---|---|
| UC-HERD-INSIGHT-001 | Rebanho | STATUS | Exibir cards de insight por status/categoria/sexo | Base com animais ativos/vendidos/obitos | dados de rebanho | Cards com totais (ativos, saudaveis, tratamento, feridos, matrizes, gestantes, machos reprodutores, machos borregos, femeas borregas, vendidos, obitos) | AUTO_NAO |
| UC-HERD-INSIGHT-002 | Rebanho | REGISTRO | Aplicar filtro ao tocar no card de insight | Cards de insight visiveis | toque em card | Lista filtrada + busca ativa na mesma aba | AUTO_NAO |
| UC-HERD-FILTRO-001 | Rebanho | STATUS | Exibir filtros primarios completos | Tela Rebanho aberta | nenhum | Chips com: Todos, Adulto, Borrego, Matriz, Reprodutor, Venda | AUTO_NAO |
| UC-HERD-I18N-001 | Rebanho | EDICAO | Exibir cores de parentesco em portugues | Animal com mae/pai e cor preenchida | abrir historico/parentesco | Cor de mae/pai e prole em PT-BR | AUTO_NAO |
| UC-HERD-CARD-001 | Rebanho | STATUS | Exibir sexo do animal no card e circulo para numero de crias | Animal em lista com dados de prole | nenhum | Indicador principal representa sexo do animal e bolha circular mostra total de crias | AUTO_NAO |
| UC-FORM-UX-001 | Formularios | REGISTRO | Manter formulario aberto apos salvar com sucesso | Formulario de cadastro aberto | dados validos | Formulario continua aberto sem limpar campos | AUTO_NAO |
| UC-FORM-UX-002 | Formularios | STATUS | Mostrar mensagens de erro/sucesso por cima do formulario | Formulario aberto | erro de validacao ou sucesso no save | Mensagem modal visivel em primeiro plano | AUTO_NAO |
| UC-WEIGHT-REGRA-001 | Peso | STATUS | Tratar borrego e borrega nas regras de pendencia | Animal com categoria borrego/borrega | nascimento + sem peso do marco | Marco devido aparece como pendente quando atingido | AUTO_NAO |
| UC-WEIGHT-UX-001 | Peso (Adultos) | REGISTRO | Clicar em celula Mx abre registro no mes selecionado | Grade mensal M1..M24 visivel | clique em Mx | Dialog abre com mes X preselecionado | AUTO_NAO |
| UC-WEIGHT-CICLO-001 | Peso (Adultos) | REGISTRO | Reiniciar ciclo mensal apos M24 | Animal com ciclo mensal completo | novo registro apos M24 | Pesos mensais reiniciados e ciclo recomeca em M1 | AUTO_NAO |

## Checklist rapido (execucao)

Marque os IDs abaixo para controlar o progresso da checagem:

- [ ] Rebanho: `UC-HERD-CRIACAO-001`, `UC-HERD-EDICAO-001`, `UC-HERD-REGISTRO-001`, `UC-HERD-EXCLUSAO-001`
- [ ] Alimentacao: `UC-FEED-CRIACAO-001`, `UC-FEED-EDICAO-001`, `UC-FEED-CRIACAO-002`, `UC-FEED-EDICAO-002`
- [ ] Peso: `UC-WEIGHT-REGISTRO-001`, `UC-WEIGHT-REGISTRO-002`, `UC-WEIGHT-EDICAO-001`, `UC-WEIGHT-STATUS-001`
- [ ] Reproducao: `UC-BREED-REGISTRO-001`, `UC-BREED-REGISTRO-004`, `UC-BREED-REGISTRO-005`, `UC-BREED-EXCLUSAO-001`
- [ ] Matrizes: `UC-MATRIX-CRIACAO-001`, `UC-MATRIX-EDICAO-001`, `UC-MATRIX-EXCLUSAO-001`
- [ ] Vacinas/Medicamentos: `UC-MED-AGENDAMENTO-001`, `UC-MED-AGENDAMENTO-002`, `UC-MED-STATUS-001`, `UC-MED-STATUS-004`
- [ ] Anotacoes: `UC-NOTE-CRIACAO-001`, `UC-NOTE-STATUS-001`, `UC-NOTE-EXCLUSAO-001`
- [ ] Farmacia: `UC-PHARM-CRIACAO-001`, `UC-PHARM-EDICAO-001`, `UC-PHARM-REGISTRO-001`, `UC-PHARM-REGISTRO-002`
- [ ] Financeiro: `UC-FIN-CRIACAO-001`, `UC-FIN-CRIACAO-002`, `UC-FIN-EDICAO-001`, `UC-FIN-STATUS-001`, `UC-FIN-CRIACAO-003`
- [ ] Relatorios/Sistema: `UC-REP-REGISTRO-001`, `UC-REP-REGISTRO-002`, `UC-SYS-REGISTRO-001`, `UC-SYS-REGISTRO-002`

## Observacao para automacao

- O arquivo foi estruturado com IDs estaveis para servir de entrada de geracao de cenarios automatizados.
- Sugestao: usar o campo `Cobertura` para priorizar implementacao de novos testes (comecar por todos os `AUTO_NAO`).

## Auditoria de cobertura: Relatorios (2026-04-16)

Tipos atualmente disponiveis no Hub de Relatorios:
- `Animais`
- `Pesos`
- `Vacinações`
- `Medicações`
- `Alimentação`
- `Farmácia`
- `Reprodução`
- `Financeiro`
- `Anotações`

Tabelas efetivamente consultadas pelos relatorios atuais:
- `animals`
- `animal_weights`
- `vaccinations`
- `medications`
- `feeding_pens`
- `feeding_schedules`
- `pharmacy_stock`
- `pharmacy_stock_movements`
- `breeding_records`
- `financial_accounts` (fallbacks: `financial_records`, etc.)
- `notes`

Lacunas em relacao aos modulos/tabelas do app:
- Sem relatorio dedicado para `matrix_evaluations` (Matrizes).
- Sem relatorio dedicado para `sold_animals` e `deceased_animals`.
- Sem relatorio dedicado para `weight_alerts` (pendencias/atrasos de pesagem).

Correcao aplicada nesta auditoria:
- Ajustada contagem de status em resumo de Vacinações/Medicações para aceitar variacoes masculino/feminino (`Agendado/Agendada`, `Aplicado/Aplicada`, `Cancelado/Cancelada`).
- Ajustado filtro `Status animal` no relatorio Financeiro (agora respeitado).

## Auditoria de sincronizacao: tabelas + farm_id (2026-04-16)

Tabelas atualmente sincronizadas automaticamente (`SyncService._syncTables`):
- `sync_tombstones`
- `animals`
- `sold_animals`
- `deceased_animals`
- `feeding_pens`
- `feeding_schedules`
- `financial_accounts`
- `financial_records`
- `notes`
- `matrix_evaluations`
- `pharmacy_stock`
- `pharmacy_stock_movements`
- `vaccinations`
- `medications`
- `animal_weights`
- `breeding_records`
- `weight_alerts`
- `reports`

Validacao de tenant:
- Fluxos de push/pull filtram por `farm_id`.
- Antes do sync, existe saneamento: `UPDATE <tabela> SET farm_id = ? WHERE farm_id IS NULL`.
- Resultado: as tabelas sincronizadas acima estao com isolamento por fazenda.

Tabelas com `farm_id` no Drift e fora do sync automatico atual:
- `animal_lineage`
- `animal_lineage_meta`
- `app_settings`
- `push_tokens`

Motivo tecnico:
- O sync incremental atual usa `upsert(..., onConflict: 'id')`, e as tabelas acima nao seguem o mesmo padrao de PK baseado em `id` (ou sao configuracao/dispositivo), portanto ficaram fora da malha automatica por desenho.

Correcao aplicada no bug de "obito perdido em outro emulador":
- O problema principal era reconciliacao de ciclo de vida (`animals` -> `deceased_animals`/`sold_animals`) sem propagacao de remocao.
- Ajuste no `SyncService`:
  - Push: remove da tabela remota `animals` todos os IDs ja existentes em `sold_animals` ou `deceased_animals` locais.
  - Pull: remove da tabela local `animals` qualquer ID que ja exista em `sold_animals` ou `deceased_animals`.
  - Auto-sync: adicionado ciclo periodico a cada 2 minutos (alem de reconexao/manual/entrada no dashboard).
  - LWW por horario (`updated_at`):
    - Push: antes do `upsert`, compara timestamp local x remoto por `id`; sobe apenas quando local >= remoto.
    - Pull: antes do `INSERT OR REPLACE`, compara timestamp remoto x local por `id`; aplica apenas quando remoto >= local.
  - Tombstones de exclusao:
    - Infra local criada (`sync_tombstones`) com triggers `AFTER DELETE` nas tabelas sincronizadas.
    - Push de tombstones + aplicacao de delete remoto por `table_name` + `record_id`.
    - Pull de tombstones + delete local com supressao de trigger para evitar loop.
    - Filtro anti-ressurreicao no pull: registro remoto e ignorado quando existe tombstone local mais recente/igual.
- Efeito esperado: ao marcar obito/venda em um dispositivo, o outro nao deve mais "ressuscitar" o animal ativo apos sincronizar.

Pendencia para fechar o fluxo end-to-end em producao:
- Aplicar no Supabase o script [docs/sql/supabase_sync_tombstones.sql](/mnt/d/Facul/ovino-caprino-hub/docs/sql/supabase_sync_tombstones.sql) para criar a tabela remota e politicas de acesso.
