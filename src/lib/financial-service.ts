import { FinancialAccount, CostCenter, Budget } from './types';
import { format, addMonths, addWeeks, addYears, startOfMonth, endOfMonth, isAfter, isBefore, parseISO } from 'date-fns';

const KEYS = {
  FINANCIAL_ACCOUNTS: 'financial_accounts',
  COST_CENTERS: 'cost_centers',
  BUDGETS: 'budgets',
};

const loadArray = <T>(key: string): T[] => {
  try {
    const data = localStorage.getItem(key);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
};

const saveArray = <T>(key: string, arr: T[]) => {
  localStorage.setItem(key, JSON.stringify(arr));
};

const genId = (prefix = 'id'): string => `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

// Financial Accounts
export const localFinancialAccounts = {
  all: (): FinancialAccount[] => loadArray<FinancialAccount>(KEYS.FINANCIAL_ACCOUNTS),
  
  create: (account: Omit<FinancialAccount, 'id' | 'created_at' | 'updated_at'>): FinancialAccount => {
    const accounts = localFinancialAccounts.all();
    const newAccount: FinancialAccount = {
      ...account,
      id: genId('fa'),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    accounts.push(newAccount);
    saveArray(KEYS.FINANCIAL_ACCOUNTS, accounts);
    return newAccount;
  },

  update: (id: string, updates: Partial<FinancialAccount>) => {
    const accounts = localFinancialAccounts.all();
    const index = accounts.findIndex(a => a.id === id);
    if (index !== -1) {
      accounts[index] = { ...accounts[index], ...updates, updated_at: new Date().toISOString() };
      saveArray(KEYS.FINANCIAL_ACCOUNTS, accounts);
    }
  },

  delete: (id: string) => {
    const accounts = localFinancialAccounts.all().filter(a => a.id !== id);
    saveArray(KEYS.FINANCIAL_ACCOUNTS, accounts);
  },

  markAsPaid: (id: string, paymentDate: string) => {
    localFinancialAccounts.update(id, { status: 'Pago', payment_date: paymentDate });
  },

  updateOverdueStatus: () => {
    const accounts = localFinancialAccounts.all();
    const today = format(new Date(), 'yyyy-MM-dd');
    
    accounts.forEach(account => {
      if (account.status === 'Pendente' && account.due_date < today) {
        localFinancialAccounts.update(account.id, { status: 'Vencido' });
      }
    });
  },

  getByStatus: (status: string): FinancialAccount[] => {
    localFinancialAccounts.updateOverdueStatus();
    return localFinancialAccounts.all().filter(a => a.status === status);
  },

  getUpcoming: (days: number): FinancialAccount[] => {
    localFinancialAccounts.updateOverdueStatus();
    const today = new Date();
    const futureDate = new Date(today);
    futureDate.setDate(futureDate.getDate() + days);
    
    return localFinancialAccounts.all()
      .filter(a => {
        if (a.status !== 'Pendente' && a.status !== 'Vencido') return false;
        const dueDate = parseISO(a.due_date);
        return !isBefore(dueDate, today) && !isAfter(dueDate, futureDate);
      })
      .sort((a, b) => a.due_date.localeCompare(b.due_date));
  },

  getDashboardStats: () => {
    localFinancialAccounts.updateOverdueStatus();
    const accounts = localFinancialAccounts.all();
    const today = new Date();
    const firstDayOfMonth = startOfMonth(today);
    const lastDayOfMonth = endOfMonth(today);
    const upcomingDate = new Date(today);
    upcomingDate.setDate(upcomingDate.getDate() + 7);

    const totalPending = accounts
      .filter(a => a.status === 'Pendente')
      .reduce((sum, a) => sum + a.amount, 0);

    const upcoming = accounts.filter(a => {
      if (a.status !== 'Pendente') return false;
      const dueDate = parseISO(a.due_date);
      return !isBefore(dueDate, today) && !isAfter(dueDate, upcomingDate);
    });

    const overdue = accounts.filter(a => a.status === 'Vencido');

    const paidThisMonth = accounts.filter(a => {
      if (a.status !== 'Pago' || !a.payment_date) return false;
      const paymentDate = parseISO(a.payment_date);
      return !isBefore(paymentDate, firstDayOfMonth) && !isAfter(paymentDate, lastDayOfMonth);
    });

    const totalRevenue = paidThisMonth
      .filter(a => a.type === 'receita')
      .reduce((sum, a) => sum + a.amount, 0);

    const totalExpense = paidThisMonth
      .filter(a => a.type === 'despesa')
      .reduce((sum, a) => sum + a.amount, 0);

    return {
      totalPending,
      totalUpcoming: upcoming.reduce((sum, a) => sum + a.amount, 0),
      countUpcoming: upcoming.length,
      totalOverdue: overdue.reduce((sum, a) => sum + a.amount, 0),
      countOverdue: overdue.length,
      totalPaidMonth: paidThisMonth.reduce((sum, a) => sum + a.amount, 0),
      balance: totalRevenue - totalExpense,
      totalRevenue,
      totalExpense,
    };
  },

  createInstallments: (account: Omit<FinancialAccount, 'id' | 'created_at' | 'updated_at'>): FinancialAccount[] => {
    if (!account.installments || account.installments <= 1) {
      return [localFinancialAccounts.create(account)];
    }

    const installmentAmount = account.amount / account.installments;
    const installments: FinancialAccount[] = [];
    const parentId = genId('fa_parent');

    for (let i = 1; i <= account.installments; i++) {
      const dueDate = addMonths(parseISO(account.due_date), i - 1);
      
      const installment = localFinancialAccounts.create({
        ...account,
        description: `${account.description} (${i}/${account.installments})`,
        amount: installmentAmount,
        due_date: format(dueDate, 'yyyy-MM-dd'),
        installment_number: i,
        parent_id: parentId,
      });
      
      installments.push(installment);
    }

    return installments;
  },

  generateRecurringAccounts: () => {
    const accounts = localFinancialAccounts.all();
    const today = new Date();

    accounts
      .filter(a => a.is_recurring && (!a.recurrence_end_date || !isAfter(parseISO(a.recurrence_end_date), today)))
      .forEach(recurring => {
        const nextDueDate = calculateNextDueDate(recurring);
        
        if (nextDueDate) {
          const exists = accounts.some(a => 
            a.parent_id === recurring.id && 
            a.due_date === format(nextDueDate, 'yyyy-MM-dd')
          );

          if (!exists) {
            localFinancialAccounts.create({
              type: recurring.type,
              category: recurring.category,
              description: recurring.description,
              amount: recurring.amount,
              due_date: format(nextDueDate, 'yyyy-MM-dd'),
              status: 'Pendente',
              payment_method: recurring.payment_method,
              animal_id: recurring.animal_id,
              supplier_customer: recurring.supplier_customer,
              notes: recurring.notes,
              cost_center: recurring.cost_center,
              parent_id: recurring.id,
            });
          }
        }
      });
  },
};

const calculateNextDueDate = (recurring: FinancialAccount): Date | null => {
  const today = new Date();
  const lastDue = parseISO(recurring.due_date);

  switch (recurring.recurrence_frequency) {
    case 'Mensal':
      return addMonths(today, 1);
    case 'Semanal':
      return addWeeks(today, 1);
    case 'Anual':
      return addYears(today, 1);
    default:
      return null;
  }
};

// Cost Centers
export const localCostCenters = {
  all: (): CostCenter[] => loadArray<CostCenter>(KEYS.COST_CENTERS).filter(c => c.active),
  
  create: (costCenter: Omit<CostCenter, 'id' | 'created_at'>): CostCenter => {
    const costCenters = loadArray<CostCenter>(KEYS.COST_CENTERS);
    const newCostCenter: CostCenter = {
      ...costCenter,
      id: genId('cc'),
      created_at: new Date().toISOString(),
    };
    costCenters.push(newCostCenter);
    saveArray(KEYS.COST_CENTERS, costCenters);
    return newCostCenter;
  },

  delete: (id: string) => {
    const costCenters = loadArray<CostCenter>(KEYS.COST_CENTERS);
    const index = costCenters.findIndex(c => c.id === id);
    if (index !== -1) {
      costCenters[index].active = false;
      saveArray(KEYS.COST_CENTERS, costCenters);
    }
  },
};

// Budgets
export const localBudgets = {
  all: (): Budget[] => loadArray<Budget>(KEYS.BUDGETS),
  
  create: (budget: Omit<Budget, 'id' | 'created_at' | 'updated_at'>): Budget => {
    const budgets = localBudgets.all();
    const newBudget: Budget = {
      ...budget,
      id: genId('bg'),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    budgets.push(newBudget);
    saveArray(KEYS.BUDGETS, budgets);
    return newBudget;
  },

  update: (id: string, updates: Partial<Budget>) => {
    const budgets = localBudgets.all();
    const index = budgets.findIndex(b => b.id === id);
    if (index !== -1) {
      budgets[index] = { ...budgets[index], ...updates, updated_at: new Date().toISOString() };
      saveArray(KEYS.BUDGETS, budgets);
    }
  },

  delete: (id: string) => {
    const budgets = localBudgets.all().filter(b => b.id !== id);
    saveArray(KEYS.BUDGETS, budgets);
  },

  getAnalysis: (category: string, year: number, month?: number) => {
    const accounts = localFinancialAccounts.all();
    const firstDay = month ? new Date(year, month - 1, 1) : new Date(year, 0, 1);
    const lastDay = month ? endOfMonth(firstDay) : new Date(year, 11, 31);

    const spent = accounts
      .filter(a => {
        if (a.category !== category || a.status !== 'Pago' || !a.payment_date) return false;
        const paymentDate = parseISO(a.payment_date);
        return !isBefore(paymentDate, firstDay) && !isAfter(paymentDate, lastDay);
      })
      .reduce((sum, a) => sum + a.amount, 0);

    return { spent };
  },
};

// Cash Flow Projection
export const getCashFlowProjection = (months: number) => {
  const accounts = localFinancialAccounts.all();
  const today = new Date();
  const projection: Array<{ month: Date; revenue: number; expense: number; balance: number }> = [];

  for (let i = 0; i < months; i++) {
    const month = addMonths(startOfMonth(today), i);
    const nextMonth = addMonths(month, 1);

    const revenue = accounts
      .filter(a => {
        if (a.type !== 'receita') return false;
        const dueDate = parseISO(a.due_date);
        return !isBefore(dueDate, month) && isBefore(dueDate, nextMonth);
      })
      .reduce((sum, a) => sum + a.amount, 0);

    const expense = accounts
      .filter(a => {
        if (a.type !== 'despesa') return false;
        const dueDate = parseISO(a.due_date);
        return !isBefore(dueDate, month) && isBefore(dueDate, nextMonth);
      })
      .reduce((sum, a) => sum + a.amount, 0);

    projection.push({
      month,
      revenue,
      expense,
      balance: revenue - expense,
    });
  }

  return projection;
};
