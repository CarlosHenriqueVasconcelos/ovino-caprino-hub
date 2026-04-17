-- Sync tombstones (multi-device delete replication)
-- Execute no SQL Editor do Supabase no projeto de producao.

CREATE TABLE IF NOT EXISTS public.sync_tombstones (
  id text PRIMARY KEY,
  farm_id uuid NOT NULL,
  table_name text NOT NULL,
  record_id text NOT NULL,
  deleted_at timestamptz NOT NULL,
  deleted_by_device text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_tombstones_target
  ON public.sync_tombstones (farm_id, table_name, record_id);

CREATE INDEX IF NOT EXISTS idx_sync_tombstones_farm_updated
  ON public.sync_tombstones (farm_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_sync_tombstones_farm_table
  ON public.sync_tombstones (farm_id, table_name, deleted_at DESC);

CREATE OR REPLACE FUNCTION public.set_sync_tombstones_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_tombstones_updated_at ON public.sync_tombstones;
CREATE TRIGGER trg_sync_tombstones_updated_at
BEFORE UPDATE ON public.sync_tombstones
FOR EACH ROW
EXECUTE FUNCTION public.set_sync_tombstones_updated_at();

ALTER TABLE public.sync_tombstones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sync_tombstones_select_by_farm" ON public.sync_tombstones;
CREATE POLICY "sync_tombstones_select_by_farm"
ON public.sync_tombstones
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.farm_users fu
    WHERE fu.user_id = auth.uid()
      AND fu.farm_id = sync_tombstones.farm_id
  )
);

DROP POLICY IF EXISTS "sync_tombstones_insert_by_farm" ON public.sync_tombstones;
CREATE POLICY "sync_tombstones_insert_by_farm"
ON public.sync_tombstones
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.farm_users fu
    WHERE fu.user_id = auth.uid()
      AND fu.farm_id = sync_tombstones.farm_id
  )
);

DROP POLICY IF EXISTS "sync_tombstones_update_by_farm" ON public.sync_tombstones;
CREATE POLICY "sync_tombstones_update_by_farm"
ON public.sync_tombstones
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.farm_users fu
    WHERE fu.user_id = auth.uid()
      AND fu.farm_id = sync_tombstones.farm_id
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.farm_users fu
    WHERE fu.user_id = auth.uid()
      AND fu.farm_id = sync_tombstones.farm_id
  )
);

DROP POLICY IF EXISTS "sync_tombstones_delete_by_farm" ON public.sync_tombstones;
CREATE POLICY "sync_tombstones_delete_by_farm"
ON public.sync_tombstones
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.farm_users fu
    WHERE fu.user_id = auth.uid()
      AND fu.farm_id = sync_tombstones.farm_id
  )
);
