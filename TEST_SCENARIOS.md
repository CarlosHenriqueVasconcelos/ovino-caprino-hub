# Roteiro de testes (manual ou base para automação)

Formato sugerido: cada cenário tem Objetivo, Passos e Resultado Esperado. Inclui casos de sucesso e de erro para achar quebras antes do build Android.

## Animais
- Criar animal simples  
  Passos: abrir formulário de animal, preencher campos obrigatórios (nome, cor, categoria, sexo, data de nascimento), salvar.  
  Esperado: registro criado, aparece em listagens e histórico.
- Unicidade adulto (bloqueio)  
  Passos: criar animal adulto A; tentar criar outro com mesmo Nome+Cor.  
  Esperado: erro informando duplicidade.
- Limite de borregos por lote (bloqueio)  
  Passos: criar 2 borregos com Nome+Cor+Lote iguais; tentar o 3º.  
  Esperado: erro de limite (máximo 2).
- Atualizar status para “Óbito”  
  Passos: editar animal e marcar status Óbito.  
  Esperado: removido da lista principal, aparece em óbitos, alertas/estatísticas atualizados.
- Busca/paginação  
  Passos: navegar no rebanho/peso/histórico com pesquisa; verificar que muda de página sem carregar tudo.

## Reprodução
- Registrar cobertura (fêmea obrigatória, macho opcional)  
  Passos: abrir diálogo, selecionar fêmea elegível (não gestante), macho opcional, salvar.  
  Esperado: registro criado, histórico atualizado.
- Bloqueio fêmea em reprodução/gestante  
  Passos: iniciar cobertura com fêmea já gestante ou em estágio ativo.  
  Esperado: bloqueio/mensagem.
- Ultrassom confirmado e não confirmado  
  Passos: registrar ultrassom “Confirmada” → fêmea vira gestante; registrar “Não confirmada” → fêmea volta saudável.  
  Esperado: campos de gestação atualizados.
- Parto com cria(s)  
  Passos: registrar parto, informar nº de crias 1 e 2 em execuções separadas; preencher formulário de cria.  
  Esperado: fêmea deixa de estar gestante, crias ligadas a mãe/pai, histórico ok.
- Cancelar encabritamento  
  Passos: cancelar registro em andamento.  
  Esperado: registro removido, listas/alertas atualizados.
- Importar registro existente  
  Passos: usar diálogo de importação com fêmea/macho válidos; marcar ultrassom confirmada.  
  Esperado: registro criado, fêmea marcada gestante.

## Vacinação e Medicação
- Agendar vacinação  
  Passos: abrir formulário, selecionar animal, preencher nome/tipo/data, salvar.  
  Esperado: status Agendada, aparece em alertas/lista.
- Aplicar vacinação  
  Passos: marcar como Aplicada, definir applied_date.  
  Esperado: sai dos alertas pendentes, status aplicado.
- Agendar medicação com estoque  
  Passos: selecionar item de farmácia disponível, animal, datas, salvar.  
  Esperado: agendamento criado, vinculado ao estoque.
- Cancelar/Remarcar  
  Passos: cancelar ou alterar data/status de uma vacina/medicação.  
  Esperado: alertas/contadores atualizados.
- Busca/paginação  
  Passos: usar filtros (espécie/categoria/status) e rolar para carregar mais.  
  Esperado: sem travar, dados coerentes.
- Erro: animal inexistente  
  Passos: tentar aplicar/abrir detalhes de registro com animal removido.  
  Esperado: mensagem de “Animal não encontrado”, operação bloqueada.

## Farmácia
- Criar/editar estoque  
  Passos: novo item com quantidade/validade/alerta mínimo; editar campos.  
  Esperado: dados salvos, cores/status corretos (vencido, baixo, ok).
- Movimentação de entrada/saída  
  Passos: registrar entrada, depois saída; conferir saldo.  
  Esperado: total ajustado conforme movimentos.
- Descarte de recipiente aberto  
  Passos: descartar item aberto com quantidade >0.  
  Esperado: aberto zerado, movimento criado.
- Paginação histórico de movimentos  
  Passos: rolar lista de movimentos até carregar mais.  
  Esperado: sem travar, mais registros carregados.
- Excluir estoque  
  Passos: deletar item com/sem movimentações.  
  Esperado: removido e não aparece em seletores.

## Peso (Adultos e Borregos)
- Listar com paginação e busca  
  Passos: filtrar por nome/código e navegar páginas adultos/borregos.  
  Esperado: lista responde sem travar, totais corretos.
- Registrar pesagem  
  Passos: adicionar pesagem a um animal; editar pesagem.  
  Esperado: valores atualizados em tabela e histórico.
- Alertas de pesagem (se configurados)  
  Passos: criar borrego e verificar alertas de 30/60/90/120 dias ou mensal.  
  Esperado: alertas surgem e somem ao marcar como feito.

## Financeiro
- Criar despesa/receita  
  Passos: preencher categoria, valor, data, forma de pagamento.  
  Esperado: aparece em listas e dashboards.
- Receita “Venda de Animais”  
  Passos: selecionar categoria Venda de Animais, escolher animal.  
  Esperado: status do animal vira “Vendido”; registro salvo.
- Recorrência (se houver)  
  Passos: criar lançamento recorrente, verificar gerações.  
  Esperado: parcelas criadas corretamente.

## Notas
- Criar nota sem animal  
  Passos: título/conteúdo, salvar.  
  Esperado: nota listada, sem vínculo.
- Criar nota com animal (autocomplete)  
  Passos: selecionar animal via busca, salvar.  
  Esperado: vínculo aparece no card.
- Marcar como lida/não lida e excluir  
  Passos: alternar status, remover.  
  Esperado: contadores e listas atualizados.

## Dashboard / Alertas
- Ver alertas de vacina/medicação e pesagem  
  Passos: abrir dashboard, conferir contadores; aplicar/cancelar item.  
  Esperado: alertas reduzem; sem itens “fantasma”.
- Quick actions (agendar medicação)  
  Passos: abrir ação rápida, buscar animal, salvar.  
  Esperado: cria agendamento válido, sem travar.

## Relatórios / Exportação
- Gerar cada relatório (animais, pesagem, reprodução, vacinas, medicações, finanças, notas) com filtros  
  Passos: escolher período/filtros, navegar páginas.  
  Esperado: total/paginação coerentes.
- Exportar CSV  
  Passos: exportar relatório grande; abrir CSV e conferir cabeçalhos e linhas.  
  Esperado: dados completos, sem truncar.

## Backup / Restore (se aplicável)
- Exportar backup local e importar em base limpa  
  Passos: gerar backup, limpar base ou outro device, restaurar.  
  Esperado: dados íntegros (animais, reprodução, vacinas/medicações, finanças, notas).

## Acessibilidade e UX rápida
- Campos obrigatórios sinalizados; mensagens de erro claras.
- Navegação com teclado nos autocompletes; botões de limpar campos funcionam.
- Estados de carregamento exibidos (spinners) e não bloqueiam indefinidamente.

## Idéias para script automatizado (opcional)
- Representar cenários em JSON/YAML: operação, dados de entrada, asserts (ex.: contagem de registros, campos esperados).  
- Rodar via integration_test com um seed inicial:  
  1) Cria animal válido e tenta duplicado (assert erro).  
  2) Cobertura → ultrassom confirmada → parto com cria.  
  3) Agendar/aplicar vacina e medicação (assert alertas).  
  4) Movimentar estoque entrada/saída/descartar.  
  5) Receita “Venda de Animais” e assert status vendido.  
  6) Criar nota vinculada e filtrar por animal.  
  7) Exportar relatório e verificar arquivo gerado não vazio.  
- Incluir limpeza/reset de base entre cenários para isolá-los.
