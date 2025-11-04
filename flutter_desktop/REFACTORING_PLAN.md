# Plano de Refatoração MVC - BEGO Agritech

## Status Atual: Fase 0 - Preparação ✅

### Objetivo Geral
Migrar de uma arquitetura com acesso direto ao banco em widgets para uma arquitetura MVC limpa:
- **Model**: `lib/models/*`
- **Data (Repository)**: `lib/data/*`
- **Service/Controller**: `lib/services/*`
- **View**: `lib/screens/*` + `lib/widgets/*`

---

## Roteiro de Testes Manuais

### ✅ Cadastro/Edição de Animal
- [ ] Criar novo animal com nome, cor, categoria
- [ ] Editar animal existente
- [ ] Validar unicidade de nome/cor
- [ ] Deletar animal

### ✅ Reprodução
- [ ] Criar registro de encabritamento
- [ ] Avançar estágios: Cobertura → Ultrassom → Parto
- [ ] Registrar nascimento de cria
- [ ] Verificar atualização de status de prenhez

### ✅ Peso de Borregos
- [ ] Registrar peso de nascimento
- [ ] Registrar pesos 30d, 60d, 90d
- [ ] Registrar peso 120d e verificar promoção para Adulto
- [ ] Editar pesos existentes

### ✅ Peso de Adultos
- [ ] Registrar pesagem mensal
- [ ] Visualizar histórico de pesos
- [ ] Paginação funciona corretamente

### ✅ Farmácia
- [ ] Cadastrar medicamento (ml, mg, g, unidade)
- [ ] Agendar aplicação
- [ ] Aplicar medicamento e verificar desconto de estoque
- [ ] Verificar abertura de frasco/ampola
- [ ] Verificar alertas de estoque baixo

### ✅ Financeiro
- [ ] Criar receita
- [ ] Criar despesa
- [ ] Contas a pagar/receber
- [ ] Visualizar fluxo de caixa

### ✅ Alimentação (Baias e Tratos)
- [ ] Criar baia
- [ ] Adicionar trato à baia
- [ ] Editar horários de alimentação
- [ ] Deletar trato

---

## Arquitetura Atual (Antes da Refatoração)

### Problemas Identificados:
1. **11 acessos diretos ao banco em widgets**:
   - `lamb_weight_tracking.dart` (4x)
   - `adult_weight_tracking.dart` (2x)
   - `feeding_screen.dart` (2x)
   - `feeding_form_dialog.dart` (1x)
   - `pen_details_screen.dart` (2x)

2. **DatabaseService redundante**:
   - Duplica funcionalidade de repositórios
   - Dificulta manutenção

3. **Falta de injeção de dependência**:
   - AnimalService cria seu próprio DB
   - Dificulta testes

---

## Fases de Implementação

### ✅ Fase 0 - Preparação (COMPLETA)
- [x] Documentação criada
- [x] Roteiro de testes definido
- [x] Estado estável confirmado

### ✅ Fase 1 - Criar Camada de Repositórios (COMPLETA)
- [x] Criar PharmacyRepository
- [x] Criar BreedingRepository
- [x] Criar FinanceRepository
- [x] Criar FeedingRepository
- [x] Criar VaccinationRepository
- [x] Criar MedicationRepository
- [x] Criar NoteRepository
- [x] Criar DatabaseFactory (suporte multiplataforma)
- [x] Atualizar PharmacyService para usar PharmacyRepository e estender ChangeNotifier
- [x] Criar FeedingService com FeedingRepository
- [x] Atualizar todos os widgets para usar Provider em vez de chamadas estáticas
- [x] Atualizar main.dart com todos os Providers

### ✅ Fase 2 - Limpar Widgets (COMPLETA)
- [x] Criar WeightService usando AnimalRepository
- [x] Atualizar lamb_weight_tracking.dart para usar WeightService
- [x] Atualizar adult_weight_tracking.dart para usar WeightService
- [x] Atualizar feeding_screen.dart para usar FeedingService
- [x] Atualizar feeding_form_dialog.dart para usar FeedingService
- [x] Atualizar pen_details_screen.dart para usar FeedingService
- [x] Atualizar main.dart com WeightService provider
- [x] Remover todos os 11 acessos diretos ao banco em widgets

### 🚧 Fase 3 - Consolidar Farmácia (COMPLETA)
- [x] Criar MedicationService usando MedicationRepository
- [x] Criar VaccinationService usando VaccinationRepository
- [x] Atualizar MedicationManagementScreen para usar MedicationService e VaccinationService
- [x] Adicionar MedicationService e VaccinationService providers no main.dart
- [x] Remover dependências diretas de DatabaseService para medicações e vacinações

### ⏳ Fase 4 - Peso & Crescimento (PRÓXIMA)
### ⏳ Fase 4 - Peso & Crescimento (PENDENTE)
### ⏳ Fase 5 - Preparar para Mobile (PENDENTE)
### ⏳ Fase 6 - Micro Otimizações (PENDENTE)
### ⏳ Fase 7 - Validação Final (PENDENTE)

---

## Estrutura Final Esperada

```
lib/
├── data/                    # Camada de Dados (Repository)
│   ├── local_db.dart
│   ├── database_factory.dart
│   ├── animal_repository.dart
│   ├── pharmacy_repository.dart
│   ├── breeding_repository.dart
│   ├── finance_repository.dart
│   ├── feeding_repository.dart
│   ├── vaccination_repository.dart
│   └── medication_repository.dart
│
├── models/                  # Modelos de Dados
│   └── *.dart
│
├── services/                # Lógica de Negócio (Controller)
│   ├── animal_service.dart
│   ├── pharmacy_service.dart
│   ├── breeding_service.dart
│   ├── financial_service.dart
│   ├── feeding_service.dart
│   └── ...
│
├── screens/                 # Telas Principais
│   └── *.dart
│
├── widgets/                 # Componentes (View)
│   └── *.dart
│
└── main.dart
```

---

## Benefícios Esperados

✅ Testabilidade (repositórios isolados)  
✅ Manutenibilidade (mudanças isoladas)  
✅ Multiplataforma (Desktop + Mobile)  
✅ Performance (menos rebuilds)  
✅ Escalabilidade (adicionar features é simples)
