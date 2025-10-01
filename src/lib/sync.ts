import { supabase } from "@/integrations/supabase/client";
import { localAnimals, localVaccinations, localNotes, localBreeding, localFinancial, localReports, localSync } from "./local-db";

async function upsertArray<T extends { id: string }>(table: string, rows: T[]) {
  for (const row of rows) {
    const { error } = await (supabase as any).from(table).upsert(row as any);
    if (error) throw error;
  }
}

export async function syncToCloud(onProgress?: (p: number, note?: string) => void) {
  const steps = 6;
  let done = 0;
  const step = async (fn: () => Promise<void>, note: string) => {
    await fn();
    done += 1; onProgress?.(Math.round((done/steps)*100), note);
  };

  await step(() => upsertArray('animals', localAnimals.all()), 'Animais');
  await step(() => upsertArray('vaccinations', localVaccinations.all()), 'Vacinações');
  await step(() => upsertArray('notes', localNotes.all()), 'Anotações');
  await step(() => upsertArray('breeding_records', localBreeding.all()), 'Reprodução');
  await step(() => upsertArray('financial_records', localFinancial.all()), 'Financeiro');
  await step(() => upsertArray('reports', localReports.all()), 'Relatórios');

  localSync.setLastSync();
}
