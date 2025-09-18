-- Add RLS policies for notes table
CREATE POLICY "Notas visíveis para todos" ON public.notes
  FOR SELECT USING (true);
CREATE POLICY "Permite inserir notas" ON public.notes
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Permite atualizar notas" ON public.notes
  FOR UPDATE USING (true);
CREATE POLICY "Permite deletar notas" ON public.notes
  FOR DELETE USING (true);

-- Add RLS policies for breeding_records table
CREATE POLICY "Registros de reprodução visíveis para todos" ON public.breeding_records
  FOR SELECT USING (true);
CREATE POLICY "Permite inserir reprodução" ON public.breeding_records
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Permite atualizar reprodução" ON public.breeding_records
  FOR UPDATE USING (true);
CREATE POLICY "Permite deletar reprodução" ON public.breeding_records
  FOR DELETE USING (true);

-- Add RLS policies for financial_records table
CREATE POLICY "Registros financeiros visíveis para todos" ON public.financial_records
  FOR SELECT USING (true);
CREATE POLICY "Permite inserir registros financeiros" ON public.financial_records
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Permite atualizar registros financeiros" ON public.financial_records
  FOR UPDATE USING (true);
CREATE POLICY "Permite deletar registros financeiros" ON public.financial_records
  FOR DELETE USING (true);

-- Add RLS policies for push_tokens table
CREATE POLICY "Tokens visíveis para todos" ON public.push_tokens
  FOR SELECT USING (true);
CREATE POLICY "Permite inserir tokens" ON public.push_tokens
  FOR INSERT WITH CHECK (true);

-- Add triggers for updated_at columns
CREATE TRIGGER update_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_breeding_records_updated_at
  BEFORE UPDATE ON public.breeding_records
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_financial_records_updated_at
  BEFORE UPDATE ON public.financial_records
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();