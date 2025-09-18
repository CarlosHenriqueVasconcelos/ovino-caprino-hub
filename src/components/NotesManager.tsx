import { useState, useEffect } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Textarea } from "./ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { useToast } from "./ui/use-toast";
import { Badge } from "./ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { Plus, FileText, Heart, AlertTriangle, Edit, Trash2 } from "lucide-react";
import { AnimalService } from "@/lib/animal-service";
import type { Note, Animal } from "@/lib/types";

export function NotesManager() {
  const { toast } = useToast();
  const animalService = new AnimalService();
  const [animals, setAnimals] = useState<Animal[]>([]);
  const [notes, setNotes] = useState<Note[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingNote, setEditingNote] = useState<Note | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('');

  const [formData, setFormData] = useState({
    animal_id: '',
    title: '',
    content: '',
    category: 'Geral',
    priority: 'Média' as 'Baixa' | 'Média' | 'Alta',
    date: new Date().toISOString().split('T')[0]
  });

  const categories = [
    { value: 'Saúde', label: '🏥 Saúde' },
    { value: 'Reprodução', label: '💝 Reprodução' },
    { value: 'Alimentação', label: '🌾 Alimentação' },
    { value: 'Comportamento', label: '🐑 Comportamento' },
    { value: 'Geral', label: '📝 Geral' }
  ];

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [animalsData, notesData] = await Promise.all([
        animalService.getAnimals(),
        animalService.getNotes()
      ]);
      setAnimals(animalsData);
      setNotes(notesData);
    } catch (error) {
      toast({
        title: "Erro ao carregar dados",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const handleNoteSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingNote) {
        await animalService.updateNote(editingNote.id, formData);
        toast({ title: "Anotação atualizada com sucesso!" });
      } else {
        await animalService.createNote(formData);
        toast({ title: "Anotação criada com sucesso!" });
      }
      
      setFormData({
        animal_id: '',
        title: '',
        content: '',
        category: 'Geral',
        priority: 'Média',
        date: new Date().toISOString().split('T')[0]
      });
      
      setIsDialogOpen(false);
      setEditingNote(null);
      loadData();
    } catch (error) {
      toast({
        title: "Erro ao salvar anotação",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const handleEditNote = (note: Note) => {
    setEditingNote(note);
    setFormData({
      animal_id: note.animal_id || '',
      title: note.title,
      content: note.content || '',
      category: note.category,
      priority: note.priority,
      date: note.date
    });
    setIsDialogOpen(true);
  };

  const handleDeleteNote = async (noteId: string) => {
    try {
      await animalService.deleteNote(noteId);
      toast({ title: "Anotação excluída com sucesso!" });
      loadData();
    } catch (error) {
      toast({
        title: "Erro ao excluir anotação",
        description: error instanceof Error ? error.message : "Erro desconhecido",
        variant: "destructive"
      });
    }
  };

  const getAnimalName = (animalId?: string) => {
    if (!animalId) return 'Geral';
    const animal = animals.find(a => a.id === animalId);
    return animal ? `${animal.code} - ${animal.name}` : 'Animal não encontrado';
  };

  const filteredNotes = selectedCategory 
    ? notes.filter(note => note.category === selectedCategory)
    : notes;

  if (loading) {
    return (
      <Card>
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin text-2xl">📝</div>
            <span className="ml-2">Carregando notas...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Anotações e Observações
          </CardTitle>
          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger asChild>
              <Button className="flex items-center gap-2">
                <Plus className="h-4 w-4" />
                Nova Nota
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>{editingNote ? 'Editar Nota' : 'Nova Nota'}</DialogTitle>
              </DialogHeader>
              <form onSubmit={handleNoteSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label>Animal</Label>
                  <Select value={formData.animal_id} onValueChange={(value) => 
                    setFormData({...formData, animal_id: value})}>
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione um animal (opcional)" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="">Nota geral (sem animal específico)</SelectItem>
                      {animals.map((animal) => (
                        <SelectItem key={animal.id} value={animal.id}>
                          {animal.code} - {animal.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Categoria *</Label>
                    <Select value={formData.category} onValueChange={(value) => 
                      setFormData({...formData, category: value})}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {categories.map((cat) => (
                          <SelectItem key={cat.value} value={cat.value}>
                            {cat.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Prioridade</Label>
                    <Select value={formData.priority} onValueChange={(value: 'Baixa' | 'Média' | 'Alta') => 
                      setFormData({...formData, priority: value})}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Baixa">🟢 Baixa</SelectItem>
                        <SelectItem value="Média">🟡 Média</SelectItem>
                        <SelectItem value="Alta">🔴 Alta</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="title">Título *</Label>
                    <Input
                      id="title"
                      value={formData.title}
                      onChange={(e) => setFormData({...formData, title: e.target.value})}
                      placeholder="Título da anotação"
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="date">Data</Label>
                    <Input
                      id="date"
                      type="date"
                      value={formData.date}
                      onChange={(e) => setFormData({...formData, date: e.target.value})}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="content">Conteúdo</Label>
                  <Textarea
                    id="content"
                    value={formData.content}
                    onChange={(e) => setFormData({...formData, content: e.target.value})}
                    placeholder="Descreva sua observação..."
                    rows={4}
                  />
                </div>

                <div className="flex justify-end space-x-2">
                  <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>
                    Cancelar
                  </Button>
                  <Button type="submit">
                    {editingNote ? 'Atualizar' : 'Salvar'}
                  </Button>
                </div>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
      <CardContent>
        <div className="flex gap-2 mb-4">
          <Button
            variant={selectedCategory === '' ? 'default' : 'outline'}
            size="sm"
            onClick={() => setSelectedCategory('')}
          >
            Todas ({notes.length})
          </Button>
          {categories.map((category) => {
            const count = notes.filter(n => n.category === category.value).length;
            return (
              <Button
                key={category.value}
                variant={selectedCategory === category.value ? 'default' : 'outline'}
                size="sm"
                onClick={() => setSelectedCategory(category.value)}
              >
                {category.label} ({count})
              </Button>
            );
          })}
        </div>

        {filteredNotes.length === 0 ? (
          <p className="text-center text-muted-foreground py-8">
            {selectedCategory 
              ? `Nenhuma nota encontrada na categoria ${selectedCategory}`
              : 'Nenhuma nota registrada'
            }
          </p>
        ) : (
          <div className="space-y-4">
            {filteredNotes.map((note) => (
              <div key={note.id} className="p-4 border rounded-lg">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h3 className="font-medium">{note.title}</h3>
                    <div className="flex items-center gap-2 mt-1">
                      <Badge variant={note.priority === 'Alta' ? 'destructive' : note.priority === 'Média' ? 'default' : 'secondary'}>
                        {note.priority}
                      </Badge>
                      <Badge variant="outline">{note.category}</Badge>
                      <span className="text-sm text-muted-foreground">
                        {getAnimalName(note.animal_id)}
                      </span>
                    </div>
                  </div>
                  <div className="flex gap-1">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleEditNote(note)}
                    >
                      <Edit className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDeleteNote(note.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
                {note.content && (
                  <p className="text-sm text-muted-foreground mb-2">{note.content}</p>
                )}
                <p className="text-xs text-muted-foreground">
                  {new Date(note.date).toLocaleDateString('pt-BR')}
                </p>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}