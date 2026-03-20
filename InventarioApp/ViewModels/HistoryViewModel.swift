import Foundation
import SwiftData

@Observable
final class HistoryViewModel {
    private var modelContext: ModelContext

    var savedJornadas: [Jornada] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchHistory()
    }

    func fetchHistory() {
        let descriptor = FetchDescriptor<Jornada>(
            predicate: #Predicate { $0.isSaved == true },
            sortBy: [SortDescriptor(\.dateString, order: .reverse)]
        )
        savedJornadas = (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteJornada(_ jornada: Jornada) {
        modelContext.delete(jornada)
        try? modelContext.save()
        fetchHistory()
    }
}
