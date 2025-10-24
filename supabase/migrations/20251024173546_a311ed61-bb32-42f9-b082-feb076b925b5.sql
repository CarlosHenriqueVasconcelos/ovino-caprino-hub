-- Adicionar campo milestone na tabela animal_weights
ALTER TABLE animal_weights ADD COLUMN IF NOT EXISTS milestone TEXT;

COMMENT ON COLUMN animal_weights.milestone IS 'Tipo de marco de pesagem: birth, 30d, 60d, 90d, monthly_1 a monthly_5, manual';

-- Criar tabela weight_alerts para alertas de pesagem
CREATE TABLE IF NOT EXISTS weight_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID NOT NULL,
  alert_type TEXT NOT NULL,
  due_date DATE NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

COMMENT ON TABLE weight_alerts IS 'Alertas de pesagem para borregos e animais adultos';
COMMENT ON COLUMN weight_alerts.alert_type IS 'Tipo: 30d, 60d, 90d, monthly';

-- Enable RLS
ALTER TABLE weight_alerts ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Alertas de peso visíveis para todos" 
ON weight_alerts 
FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir alertas de peso" 
ON weight_alerts 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar alertas de peso" 
ON weight_alerts 
FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar alertas de peso" 
ON weight_alerts 
FOR DELETE 
USING (true);

-- Create trigger for automatic timestamp updates
CREATE TRIGGER update_weight_alerts_updated_at
BEFORE UPDATE ON weight_alerts
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();