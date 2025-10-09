import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { getCashFlowProjection } from '@/lib/financial-service';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

export default function CashFlowProjection() {
  const [projection, setProjection] = useState<Array<{ month: Date; revenue: number; expense: number; balance: number }>>([]);

  useEffect(() => {
    setProjection(getCashFlowProjection(6));
  }, []);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Projeção de Fluxo de Caixa (6 meses)</CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Mês</TableHead>
              <TableHead>Receitas Previstas</TableHead>
              <TableHead>Despesas Previstas</TableHead>
              <TableHead>Saldo Projetado</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {projection.map((item, i) => (
              <TableRow key={i}>
                <TableCell className="font-medium">
                  {format(item.month, 'MMMM yyyy', { locale: ptBR })}
                </TableCell>
                <TableCell className="text-green-600">R$ {item.revenue.toFixed(2)}</TableCell>
                <TableCell className="text-red-600">R$ {item.expense.toFixed(2)}</TableCell>
                <TableCell className={item.balance >= 0 ? 'text-green-600 font-bold' : 'text-red-600 font-bold'}>
                  R$ {item.balance.toFixed(2)}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}
