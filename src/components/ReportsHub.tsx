import { useState, useMemo } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Label } from "./ui/label";
import { Input } from "./ui/input";
import { useToast } from "@/hooks/use-toast";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { FileText, Download, Save, Filter, TrendingUp, Calendar } from "lucide-react";
import { localReports } from "@/lib/local-db";
import { format } from "date-fns";
import {
  PERIOD_PRESETS,
  getAnimalsReport,
  getWeightsReport,
  getVaccinationsReport,
  getMedicationsReport,
  getBreedingReport,
  getFinancialReport,
  getNotesReport,
  type DateRange
} from "@/lib/reports-queries";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "./ui/table";

interface ReportsHubProps {
  onClose: () => void;
}

type ReportType = 'animals' | 'weights' | 'vaccinations' | 'medications' | 'breeding' | 'financial' | 'notes';

export function ReportsHub({ onClose }: ReportsHubProps) {
  const { toast } = useToast();
  const [activeReport, setActiveReport] = useState<ReportType>('animals');
  const [periodPreset, setPeriodPreset] = useState('last30');
  const [customStart, setCustomStart] = useState('');
  const [customEnd, setCustomEnd] = useState('');
  
  // Contextual filters
  const [speciesFilter, setSpeciesFilter] = useState('Todos');
  const [genderFilter, setGenderFilter] = useState('Todos');
  const [statusFilter, setStatusFilter] = useState('Todos');
  const [categoryFilter, setCategoryFilter] = useState('Todos');
  const [vaccineTypeFilter, setVaccineTypeFilter] = useState('Todos');
  const [stageFilter, setStageFilter] = useState('Todos');
  const [typeFilter, setTypeFilter] = useState('Todos');
  const [priorityFilter, setPriorityFilter] = useState('Todos');
  const [isReadFilter, setIsReadFilter] = useState<string>('Todos');
  
  // Sorting & pagination
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('asc');
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 25;

  const period: DateRange = useMemo(() => {
    if (periodPreset === 'custom') {
      return {
        start: customStart ? new Date(customStart) : new Date(),
        end: customEnd ? new Date(customEnd) : new Date()
      };
    }
    const preset = PERIOD_PRESETS.find(p => p.value === periodPreset);
    return preset ? preset.getDates() : PERIOD_PRESETS[0].getDates();
  }, [periodPreset, customStart, customEnd]);

  const reportData = useMemo(() => {
    switch (activeReport) {
      case 'animals':
        return getAnimalsReport({ period, species: speciesFilter, gender: genderFilter, status: statusFilter, category: categoryFilter });
      case 'weights':
        return getWeightsReport({ period });
      case 'vaccinations':
        return getVaccinationsReport({ period, status: statusFilter, vaccine_type: vaccineTypeFilter });
      case 'medications':
        return getMedicationsReport({ period, status: statusFilter });
      case 'breeding':
        return getBreedingReport({ period, stage: stageFilter });
      case 'financial':
        return getFinancialReport({ period, type: typeFilter, category: categoryFilter });
      case 'notes':
        return getNotesReport({ 
          period, 
          is_read: isReadFilter === 'Todos' ? null : isReadFilter === 'Lidas', 
          priority: priorityFilter 
        });
      default:
        return { summary: {}, data: [] };
    }
  }, [activeReport, period, speciesFilter, genderFilter, statusFilter, categoryFilter, vaccineTypeFilter, stageFilter, typeFilter, priorityFilter, isReadFilter]);

  const sortedData = useMemo(() => {
    if (!sortKey || !reportData.data) return reportData.data;
    const sorted = [...reportData.data].sort((a: any, b: any) => {
      const aVal = a[sortKey];
      const bVal = b[sortKey];
      if (typeof aVal === 'string') {
        return sortDir === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
      }
      return sortDir === 'asc' ? aVal - bVal : bVal - aVal;
    });
    return sorted;
  }, [reportData.data, sortKey, sortDir]);

  const paginatedData = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return sortedData.slice(start, start + pageSize);
  }, [sortedData, currentPage]);

  const totalPages = Math.ceil((sortedData?.length || 0) / pageSize);

  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDir(sortDir === 'asc' ? 'desc' : 'asc');
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
  };

  const handleExportCSV = () => {
    try {
      if (!sortedData || sortedData.length === 0) {
        toast({ title: "Nenhum dado para exportar", variant: "destructive" });
        return;
      }

      const headers = Object.keys(sortedData[0]).join(',');
      const rows = sortedData.map((row: any) => 
        Object.values(row).map(v => 
          typeof v === 'string' && v.includes(',') ? `"${v}"` : v
        ).join(',')
      );
      const csv = [headers, ...rows].join('\n');

      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      const timestamp = format(new Date(), 'yyyyMMdd_HHmmss');
      link.download = `${activeReport}_${timestamp}.csv`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);

      toast({ title: "CSV exportado com sucesso!" });
    } catch (error) {
      toast({ title: "Erro ao exportar CSV", variant: "destructive" });
    }
  };

  const handleSaveReport = () => {
    try {
      const reportTypes: Record<ReportType, 'Animais' | 'Pesos' | 'Vacinações' | 'Medicações' | 'Reprodução' | 'Financeiro' | 'Anotações'> = {
        animals: 'Animais',
        weights: 'Pesos',
        vaccinations: 'Vacinações',
        medications: 'Medicações',
        breeding: 'Reprodução',
        financial: 'Financeiro',
        notes: 'Anotações'
      };

      const title = `${reportTypes[activeReport]} – ${format(period.start, 'dd/MM/yyyy')} a ${format(period.end, 'dd/MM/yyyy')}`;
      
      const parameters = {
        report_type: activeReport,
        period_preset: periodPreset,
        custom_start: customStart,
        custom_end: customEnd,
        filters: {
          species: speciesFilter,
          gender: genderFilter,
          status: statusFilter,
          category: categoryFilter,
          vaccine_type: vaccineTypeFilter,
          stage: stageFilter,
          type: typeFilter,
          priority: priorityFilter,
          is_read: isReadFilter
        }
      };

      localReports.create({
        title,
        report_type: reportTypes[activeReport],
        parameters: JSON.stringify(parameters),
        generated_by: 'Dashboard'
      });

      toast({ title: "Relatório salvo com sucesso!" });
    } catch (error) {
      toast({ title: "Erro ao salvar relatório", variant: "destructive" });
    }
  };

  const renderSummaryCards = () => {
    const summary = reportData.summary;
    return (
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        {Object.entries(summary).map(([key, value]) => (
          <Card key={key}>
            <CardContent className="p-4">
              <div className="text-sm text-muted-foreground capitalize mb-1">
                {key.replace(/_/g, ' ')}
              </div>
              <div className="text-2xl font-bold">
                {typeof value === 'number' && (key.includes('revenue') || key.includes('expense') || key.includes('balance')) ?
                  `R$ ${value.toFixed(2)}` :
                  typeof value === 'number' && key.includes('avg') ?
                  value.toFixed(2) :
                  String(value)
                }
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    );
  };

  const renderFilters = () => {
    return (
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <Filter className="h-4 w-4" />
            Filtros
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Period filter */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label>Período</Label>
              <Select value={periodPreset} onValueChange={(v) => { setPeriodPreset(v); setCurrentPage(1); }}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {PERIOD_PRESETS.map(p => (
                    <SelectItem key={p.value} value={p.value}>{p.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            {periodPreset === 'custom' && (
              <>
                <div className="space-y-2">
                  <Label>Data Inicial</Label>
                  <Input type="date" value={customStart} onChange={(e) => setCustomStart(e.target.value)} />
                </div>
                <div className="space-y-2">
                  <Label>Data Final</Label>
                  <Input type="date" value={customEnd} onChange={(e) => setCustomEnd(e.target.value)} />
                </div>
              </>
            )}
          </div>

          {/* Contextual filters */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {activeReport === 'animals' && (
              <>
                <div className="space-y-2">
                  <Label>Espécie</Label>
                  <Select value={speciesFilter} onValueChange={setSpeciesFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="Ovino">Ovino</SelectItem>
                      <SelectItem value="Caprino">Caprino</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Gênero</Label>
                  <Select value={genderFilter} onValueChange={setGenderFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="Macho">Macho</SelectItem>
                      <SelectItem value="Fêmea">Fêmea</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Status</Label>
                  <Select value={statusFilter} onValueChange={setStatusFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="Saudável">Saudável</SelectItem>
                      <SelectItem value="Em tratamento">Em tratamento</SelectItem>
                      <SelectItem value="Reprodutor">Reprodutor</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </>
            )}

            {activeReport === 'vaccinations' && (
              <>
                <div className="space-y-2">
                  <Label>Status</Label>
                  <Select value={statusFilter} onValueChange={setStatusFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="Agendada">Agendada</SelectItem>
                      <SelectItem value="Aplicada">Aplicada</SelectItem>
                      <SelectItem value="Cancelada">Cancelada</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </>
            )}

            {activeReport === 'medications' && (
              <div className="space-y-2">
                <Label>Status</Label>
                <Select value={statusFilter} onValueChange={setStatusFilter}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Todos">Todos</SelectItem>
                    <SelectItem value="Agendado">Agendado</SelectItem>
                    <SelectItem value="Aplicado">Aplicado</SelectItem>
                    <SelectItem value="Cancelado">Cancelado</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}

            {activeReport === 'breeding' && (
              <div className="space-y-2">
                <Label>Estágio</Label>
                <Select value={stageFilter} onValueChange={setStageFilter}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Todos">Todos</SelectItem>
                    <SelectItem value="Encabritamento">Encabritamento</SelectItem>
                    <SelectItem value="Separacao">Separação</SelectItem>
                    <SelectItem value="Aguardando_Ultrassom">Aguardando Ultrassom</SelectItem>
                    <SelectItem value="Gestacao_Confirmada">Gestação Confirmada</SelectItem>
                    <SelectItem value="Parto_Realizado">Parto Realizado</SelectItem>
                    <SelectItem value="Falhou">Falhou</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}

            {activeReport === 'financial' && (
              <>
                <div className="space-y-2">
                  <Label>Tipo</Label>
                  <Select value={typeFilter} onValueChange={setTypeFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="receita">Receita</SelectItem>
                      <SelectItem value="despesa">Despesa</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </>
            )}

            {activeReport === 'notes' && (
              <>
                <div className="space-y-2">
                  <Label>Leitura</Label>
                  <Select value={isReadFilter} onValueChange={setIsReadFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="Lidas">Lidas</SelectItem>
                      <SelectItem value="Não lidas">Não lidas</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Prioridade</Label>
                  <Select value={priorityFilter} onValueChange={setPriorityFilter}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Todos">Todos</SelectItem>
                      <SelectItem value="Alta">Alta</SelectItem>
                      <SelectItem value="Média">Média</SelectItem>
                      <SelectItem value="Baixa">Baixa</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </>
            )}
          </div>
        </CardContent>
      </Card>
    );
  };

  const renderTable = () => {
    if (!paginatedData || paginatedData.length === 0) {
      return <div className="text-center py-8 text-muted-foreground">Nenhum dado encontrado para o período selecionado</div>;
    }

    const columns = Object.keys(paginatedData[0]);

    return (
      <div className="space-y-4">
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                {columns.map(col => (
                  <TableHead 
                    key={col} 
                    className="cursor-pointer hover:bg-muted"
                    onClick={() => handleSort(col)}
                  >
                    {col.replace(/_/g, ' ')} {sortKey === col && (sortDir === 'asc' ? '↑' : '↓')}
                  </TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {paginatedData.map((row: any, i) => (
                <TableRow key={i}>
                  {columns.map(col => (
                    <TableCell key={col}>
                      {typeof row[col] === 'boolean' ? (row[col] ? 'Sim' : 'Não') : 
                       col.includes('date') && row[col] ? format(new Date(row[col]), 'dd/MM/yyyy') :
                       typeof row[col] === 'number' && col.includes('amount') ? `R$ ${row[col].toFixed(2)}` :
                       String(row[col] || '')}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>

        {/* Pagination */}
        <div className="flex items-center justify-between">
          <div className="text-sm text-muted-foreground">
            Mostrando {((currentPage - 1) * pageSize) + 1} a {Math.min(currentPage * pageSize, sortedData.length)} de {sortedData.length} resultados
          </div>
          <div className="flex gap-2">
            <Button 
              variant="outline" 
              size="sm" 
              disabled={currentPage === 1}
              onClick={() => setCurrentPage(p => p - 1)}
            >
              Anterior
            </Button>
            <Button 
              variant="outline" 
              size="sm" 
              disabled={currentPage === totalPages}
              onClick={() => setCurrentPage(p => p + 1)}
            >
              Próximo
            </Button>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="w-full max-w-7xl mx-auto p-4">
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5" />
              Hub de Relatórios e Análises
            </CardTitle>
            <div className="flex gap-2">
              <Button onClick={handleExportCSV} variant="outline" size="sm">
                <Download className="h-4 w-4 mr-2" />
                Exportar CSV
              </Button>
              <Button onClick={handleSaveReport} variant="outline" size="sm">
                <Save className="h-4 w-4 mr-2" />
                Salvar Relatório
              </Button>
              <Button onClick={onClose} variant="outline" size="sm">
                Fechar
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeReport} onValueChange={(v) => { setActiveReport(v as ReportType); setCurrentPage(1); }}>
            <TabsList className="grid grid-cols-4 lg:grid-cols-7 mb-6">
              <TabsTrigger value="animals">Animais</TabsTrigger>
              <TabsTrigger value="weights">Pesos</TabsTrigger>
              <TabsTrigger value="vaccinations">Vacinações</TabsTrigger>
              <TabsTrigger value="medications">Medicações</TabsTrigger>
              <TabsTrigger value="breeding">Reprodução</TabsTrigger>
              <TabsTrigger value="financial">Financeiro</TabsTrigger>
              <TabsTrigger value="notes">Anotações</TabsTrigger>
            </TabsList>

            {renderFilters()}
            {renderSummaryCards()}

            <TabsContent value={activeReport} className="mt-0">
              {renderTable()}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}
