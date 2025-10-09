import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { localFinancialAccounts } from '@/lib/financial-service';
import { FinancialAccount } from '@/lib/types';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, isSameDay, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';

export default function FinancialCalendar() {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [accounts, setAccounts] = useState<FinancialAccount[]>([]);

  useEffect(() => {
    setAccounts(localFinancialAccounts.all());
  }, []);

  const monthStart = startOfMonth(currentDate);
  const monthEnd = endOfMonth(currentDate);
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd });

  const getAccountsForDay = (day: Date) => {
    return accounts.filter(a => isSameDay(parseISO(a.due_date), day));
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Pago': return 'bg-green-500';
      case 'Pendente': return 'bg-yellow-500';
      case 'Vencido': return 'bg-red-500';
      case 'Cancelado': return 'bg-gray-500';
      default: return 'bg-gray-500';
    }
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-center">
          <CardTitle>Calendário Financeiro</CardTitle>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1))}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentDate(new Date())}
            >
              Hoje
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1))}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
        <p className="text-lg font-medium">{format(currentDate, 'MMMM yyyy', { locale: ptBR })}</p>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-7 gap-2">
          {['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'].map((day) => (
            <div key={day} className="text-center font-semibold p-2">
              {day}
            </div>
          ))}

          {days.map((day, i) => {
            const dayAccounts = getAccountsForDay(day);
            const isToday = isSameDay(day, new Date());

            return (
              <div
                key={i}
                className={`min-h-[80px] p-2 border rounded ${
                  !isSameMonth(day, currentDate) ? 'bg-gray-50' : 'bg-background'
                } ${isToday ? 'border-primary border-2' : ''}`}
              >
                <div className="text-sm font-medium mb-1">{format(day, 'd')}</div>
                <div className="space-y-1">
                  {dayAccounts.map((account) => (
                    <div
                      key={account.id}
                      className={`text-xs p-1 rounded ${getStatusColor(account.status)} text-white truncate`}
                      title={`${account.description} - R$ ${account.amount.toFixed(2)}`}
                    >
                      R$ {account.amount.toFixed(2)}
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        <div className="mt-4 flex gap-4 text-sm">
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-green-500 rounded"></div>
            <span>Pago</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-yellow-500 rounded"></div>
            <span>Pendente</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-red-500 rounded"></div>
            <span>Vencido</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
