-- Remover campos não utilizados da tabela pharmacy_stock
ALTER TABLE pharmacy_stock
DROP COLUMN IF EXISTS manufacturer,
DROP COLUMN IF EXISTS batch_number,
DROP COLUMN IF EXISTS purchase_price;