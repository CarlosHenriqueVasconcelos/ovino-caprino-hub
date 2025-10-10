-- Adicionar coluna active na tabela cost_centers
ALTER TABLE public.cost_centers 
ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_cost_centers_active ON public.cost_centers(active);
CREATE INDEX IF NOT EXISTS idx_financial_accounts_status ON public.financial_accounts(status);
CREATE INDEX IF NOT EXISTS idx_financial_accounts_type ON public.financial_accounts(type);
CREATE INDEX IF NOT EXISTS idx_financial_accounts_due_date ON public.financial_accounts(due_date);
CREATE INDEX IF NOT EXISTS idx_budgets_period ON public.budgets(period, start_date, end_date);