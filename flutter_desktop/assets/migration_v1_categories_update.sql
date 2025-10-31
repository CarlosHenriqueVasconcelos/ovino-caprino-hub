-- Migration para atualizar as categorias de animais
-- De categorias com prefixo de gênero para categorias simplificadas

-- Atualizar Machos Reprodutores
UPDATE animals 
SET category = 'Reprodutor' 
WHERE category = 'Macho Reprodutor';

-- Atualizar Fêmeas Reprodutoras
UPDATE animals 
SET category = 'Reprodutor' 
WHERE category = 'Fêmea Reprodutora';

-- Atualizar Machos Borregos
UPDATE animals 
SET category = 'Borrego' 
WHERE category = 'Macho Borrego';

-- Atualizar Fêmeas Borregas
UPDATE animals 
SET category = 'Borrego' 
WHERE category = 'Fêmea Borrega';

-- Atualizar Fêmeas Vazias
UPDATE animals 
SET category = 'Adulto' 
WHERE category = 'Fêmea Vazia';

-- Atualizar Machos Vazios
UPDATE animals 
SET category = 'Adulto' 
WHERE category = 'Macho Vazio';

-- Atualizar animais vendidos (na tabela sold_animals)
UPDATE sold_animals 
SET category = 'Reprodutor' 
WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora');

UPDATE sold_animals 
SET category = 'Borrego' 
WHERE category IN ('Macho Borrego', 'Fêmea Borrega');

UPDATE sold_animals 
SET category = 'Adulto' 
WHERE category IN ('Fêmea Vazia', 'Macho Vazio');

-- Atualizar animais falecidos (na tabela deceased_animals)
UPDATE deceased_animals 
SET category = 'Reprodutor' 
WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora');

UPDATE deceased_animals 
SET category = 'Borrego' 
WHERE category IN ('Macho Borrego', 'Fêmea Borrega');

UPDATE deceased_animals 
SET category = 'Adulto' 
WHERE category IN ('Fêmea Vazia', 'Macho Vazio');
