import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    @Published var records: [CalculationRecord] = []
    
    private let key = "calculation_history"
    
    init() {
        load()
    }
    
    func add(expression: String, result: String) {
        let record = CalculationRecord(expression: expression, result: result)
        records.insert(record, at: 0)
        save()
    }
    
    func clearAll() {
        records.removeAll()
        save()
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([CalculationRecord].self, from: data)
        else { return }
        records = saved
    }
}
