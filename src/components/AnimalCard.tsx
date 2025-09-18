interface AnimalCardProps {
  animal: {
    id: string;
    name: string;
    species: string;
    breed: string;
    gender: string;
    age: string;
    weight: number;
    status: string;
    location: string;
    lastVaccination: string;
    pregnant: boolean;
    expectedDelivery?: string;
    healthIssue?: string;
  };
  onEdit?: () => void;
}

export function AnimalCard({ animal, onEdit }: AnimalCardProps) {
  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'saudável':
        return 'bg-green-100 text-green-800 border-green-200';
      case 'em tratamento':
        return 'bg-red-100 text-red-800 border-red-200';
      case 'reprodutor':
        return 'bg-blue-100 text-blue-800 border-blue-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getSpeciesIcon = (species: string) => {
    return species === 'Ovino' ? '🐑' : '🐐';
  };

  return (
    <div className={`bg-white rounded-xl p-6 shadow-md border-2 hover:shadow-lg transition-all duration-200 ${
      animal.healthIssue ? 'border-red-200 bg-red-50' : 'border-emerald-100'
    }`}>
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className="text-3xl">{getSpeciesIcon(animal.species)}</div>
          <div>
            <h3 className="font-bold text-emerald-800 text-lg">{animal.name}</h3>
            <p className="text-emerald-600 text-sm">{animal.id}</p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(animal.status)}`}>
          {animal.status}
        </div>
      </div>

      {/* Health Issue Alert */}
      {animal.healthIssue && (
        <div className="mb-4 p-3 bg-red-100 border border-red-200 rounded-lg">
          <p className="text-red-800 text-sm font-medium">⚠️ {animal.healthIssue}</p>
        </div>
      )}

      {/* Pregnancy Status */}
      {animal.pregnant && (
        <div className="mb-4 p-3 bg-pink-100 border border-pink-200 rounded-lg">
          <p className="text-pink-800 text-sm font-medium">🤱 Animal prenhe</p>
          {animal.expectedDelivery && (
            <p className="text-pink-600 text-xs mt-1">
              Parto previsto: {animal.expectedDelivery}
            </p>
          )}
        </div>
      )}

      {/* Animal Details */}
      <div className="space-y-2 text-sm mb-4">
        <div className="flex justify-between">
          <span className="text-gray-600">Raça:</span>
          <span className="font-medium text-gray-800">{animal.breed}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Idade:</span>
          <span className="font-medium text-gray-800">{animal.age}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Peso:</span>
          <span className="font-medium text-gray-800">{animal.weight} kg</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Local:</span>
          <span className="font-medium text-gray-800">{animal.location}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Última Vacinação:</span>
          <span className="font-medium text-gray-800">{animal.lastVaccination}</span>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex gap-2 mt-4">
        <button className="flex-1 bg-blue-500 hover:bg-blue-600 text-white text-xs py-2 px-3 rounded transition-colors duration-200">
          📋 Ver Detalhes
        </button>
        {onEdit && (
          <button 
            onClick={onEdit}
            className="flex-1 bg-emerald-500 hover:bg-emerald-600 text-white text-xs py-2 px-3 rounded transition-colors duration-200"
          >
            ✏️ Editar
          </button>
        )}
      </div>
    </div>
  );
}