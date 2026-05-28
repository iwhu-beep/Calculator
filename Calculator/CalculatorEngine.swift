import Foundation

@MainActor
final class CalculatorEngine: ObservableObject {
    @Published var display = "0"
    @Published var operatorSymbol = ""
    
    private var previousNumber: Double = 0
    private var operation: Operation? = nil
    private var shouldResetDisplay = false
    private var hasDecimal = false
    private var lastInput: InputType = .none
    
    enum Operation {
        case add, subtract, multiply, divide
        
        var symbol: String {
            switch self {
            case .add:      return "+"
            case .subtract: return "-"
            case .multiply: return "\u{00d7}"
            case .divide:   return "\u{00f7}"
            }
        }
    }
    
    enum InputType {
        case digit, operation, equals, clear, none
    }
    
    // MARK: — Digit Input
    
    func inputDigit(_ digit: Int) {
        if shouldResetDisplay {
            display = "\(digit)"
            shouldResetDisplay = false
            hasDecimal = false
        } else {
            if display == "0" {
                display = "\(digit)"
            } else {
                guard display.count < 12 else { return }
                display += "\(digit)"
            }
        }
        operatorSymbol = ""
        lastInput = .digit
    }
    
    // MARK: — Decimal
    
    func inputDecimal() {
        if shouldResetDisplay {
            display = "0."
            shouldResetDisplay = false
            hasDecimal = true
            operatorSymbol = ""
            lastInput = .digit
            return
        }
        guard !hasDecimal else { return }
        guard display.count < 12 else { return }
        display += "."
        hasDecimal = true
        operatorSymbol = ""
        lastInput = .digit
    }
    
    // MARK: — Operations
    
    func inputOperation(_ op: Operation) {
        let value = Double(display) ?? 0
        
        if let currentOp = operation, !shouldResetDisplay {
            let result = calculate(previousNumber, value, currentOp)
            display = formatResult(result)
            previousNumber = result
        } else {
            previousNumber = value
        }
        
        operation = op
        operatorSymbol = op.symbol
        shouldResetDisplay = true
        hasDecimal = false
        lastInput = .operation
    }
    
    // MARK: — Equals
    
    func inputEquals() {
        guard let op = operation else { return }
        
        let value = Double(display) ?? 0
        let result = calculate(previousNumber, value, op)
        display = formatResult(result)
        previousNumber = result
        operation = nil
        operatorSymbol = ""
        shouldResetDisplay = true
        hasDecimal = display.contains(".")
        lastInput = .equals
    }
    
    // MARK: — Clear
    
    func inputClear() {
        display = "0"
        previousNumber = 0
        operation = nil
        operatorSymbol = ""
        shouldResetDisplay = false
        hasDecimal = false
        lastInput = .clear
    }
    
    // MARK: — Toggle Sign
    
    func inputToggleSign() {
        guard let value = Double(display), value != 0 else { return }
        let negated = -value
        display = formatResult(negated)
        hasDecimal = display.contains(".")
    }
    
    // MARK: — Percentage
    
    func inputPercentage() {
        guard let value = Double(display) else { return }
        let percent = value / 100
        display = formatResult(percent)
        hasDecimal = display.contains(".")
    }
    
    // MARK: — Delete
    
    func inputDelete() {
        guard !shouldResetDisplay else { return }
        if display.hasSuffix(".") { hasDecimal = false }
        if display.count <= 1 || (display.hasPrefix("-") && display.count <= 2) {
            display = "0"
            hasDecimal = false
        } else {
            display.removeLast()
        }
    }
    
    // MARK: — Calculation
    
    private func calculate(_ a: Double, _ b: Double, _ op: Operation) -> Double {
        switch op {
        case .add:      return a + b
        case .subtract: return a - b
        case .multiply: return a * b
        case .divide:   return b == 0 ? .infinity : a / b
        }
    }
    
    private func formatResult(_ value: Double) -> String {
        if value.isInfinite { return "错误" }
        if value.isNaN { return "错误" }
        
        let integerPart = Int(value)
        if Double(integerPart) == value {
            return "\(integerPart)"
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
