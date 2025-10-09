import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Plus, DollarSign, TrendingUp, TrendingDown, AlertCircle, Calendar, BarChart3 } from 'lucide-react';
import { localFinancialAccounts, localCostCenters, localBudgets, getCashFlowProjection } from '@/lib/financial-service';
import AccountsPayable from './AccountsPayable';
import AccountsReceivable from './AccountsReceivable';
import FinancialCalendar from './FinancialCalendar';
import RecurringExpenses from './RecurringExpenses';
import CashFlowProjection from './CashFlowProjection';
import CostCenters from './CostCenters';
import BudgetsGoals from './BudgetsGoals';

export default function FinancialDashboard() {
  const [stats, setStats] = useState({
    totalPending: 0,
    totalUpcoming: 0,
    countUpcoming: 0,
    totalOverdue: 0,
    countOverdue: 0,
    totalPaidMonth: 0,
    balance: 0,
    totalRevenue: 0,
    totalExpense: 0,
  });

  const loadStats = () => {
    setStats(localFinancialAccounts.getDashboardStats());
  };

  useEffect(() => {
    loadStats();
    localFinancialAccounts.generateRecurringAccounts();
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-bold">Controle Financeiro</h2>
          <p className="text-muted-foreground">Gestão completa de contas a pagar e receber</p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Saldo do Mês</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${stats.balance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              R$ {stats.balance.toFixed(2)}
            </div>
            <p className="text-xs text-muted-foreground">
              Receitas: R$ {stats.totalRevenue.toFixed(2)} | Despesas: R$ {stats.totalExpense.toFixed(2)}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">A Vencer (7 dias)</CardTitle>
            <TrendingUp className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">R$ {stats.totalUpcoming.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground">{stats.countUpcoming} contas</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Vencidas</CardTitle>
            <AlertCircle className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">R$ {stats.totalOverdue.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground">{stats.countOverdue} contas</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Pendente</CardTitle>
            <TrendingDown className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">R$ {stats.totalPending.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground">Todas as contas não pagas</p>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="payable" className="space-y-4">
        <TabsList className="grid w-full grid-cols-7">
          <TabsTrigger value="payable">A Pagar</TabsTrigger>
          <TabsTrigger value="receivable">A Receber</TabsTrigger>
          <TabsTrigger value="calendar">Calendário</TabsTrigger>
          <TabsTrigger value="recurring">Recorrentes</TabsTrigger>
          <TabsTrigger value="cashflow">Fluxo de Caixa</TabsTrigger>
          <TabsTrigger value="costcenters">Centros de Custo</TabsTrigger>
          <TabsTrigger value="budgets">Orçamentos</TabsTrigger>
        </TabsList>

        <TabsContent value="payable">
          <AccountsPayable onUpdate={loadStats} />
        </TabsContent>

        <TabsContent value="receivable">
          <AccountsReceivable onUpdate={loadStats} />
        </TabsContent>

        <TabsContent value="calendar">
          <FinancialCalendar />
        </TabsContent>

        <TabsContent value="recurring">
          <RecurringExpenses onUpdate={loadStats} />
        </TabsContent>

        <TabsContent value="cashflow">
          <CashFlowProjection />
        </TabsContent>

        <TabsContent value="costcenters">
          <CostCenters />
        </TabsContent>

        <TabsContent value="budgets">
          <BudgetsGoals />
        </TabsContent>
      </Tabs>
    </div>
  );
}
