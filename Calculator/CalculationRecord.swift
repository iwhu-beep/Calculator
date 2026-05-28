import Foundation

struct CalculationRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let expression: String
    let result: String
    let timestamp: Date
    
    init(expression: String, result: String) {
        self.id = UUID()
        self.expression = expression
        self.result = result
        self.timestamp = Date()
    }
    
    var formattedTime: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "MM-dd HH:mm:ss"
        return f.string(from: timestamp)
    }
}
