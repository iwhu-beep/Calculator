import Foundation
import SwiftUI

@MainActor
final class CalculatorEngine: ObservableObject {
    @Published var display = "0"
    @Published var operatorSymbol = ""
    
    @AppStorage("decimalPlaces") private var decimalPlaces = 8
    
    private var previousNumber: Double = 0
    private var operation: Operation? = nil
    private var shouldResetDisplay = false
    private var hasDecimal = false
    private var lastInput: InputType = .none
    private var pendingExpression = ""
    
    var historyStore: HistoryStore?
    
    enum Operation {
        case add, subtract, multiply, divide, power
        
        var symbol: String {
            switch self {
            case .add:      return "+"
            case .subtract: return "-"
            case .multiply: return "\u{00d7}"
            case .divide:   return "\u{00f7}"
            case .power:    return "x\u{02b8}"
            }
        }
    }
    
    enum InputType {
        case digit, operation, equals, clear, none
    }
    
    // MARK: — Basic
    
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
        pendingExpression = "\(formatResult(previousNumber)) \(op.symbol)"
        shouldResetDisplay = true
        hasDecimal = false
        lastInput = .operation
    }
    
    func inputEquals() {
        guard let op = operation else { return }
        
        let value = Double(display) ?? 0
        let expression = "\(pendingExpression) \(display) ="
        let result = calculate(previousNumber, value, op)
        display = formatResult(result)
        
        if display != "\u{9519}\u{8bef}" {
            historyStore?.add(expression: expression, result: display)
        }
        
        previousNumber = result
        operation = nil
        operatorSymbol = ""
        pendingExpression = ""
        shouldResetDisplay = true
        hasDecimal = display.contains(".")
        lastInput = .equals
    }
    
    func inputClear() {
        display = "0"
        previousNumber = 0
        operation = nil
        operatorSymbol = ""
        pendingExpression = ""
        shouldResetDisplay = false
        hasDecimal = false
        lastInput = .clear
    }
    
    func inputToggleSign() {
        guard let value = Double(display), value != 0 else { return }
        let negated = -value
        display = formatResult(negated)
        hasDecimal = display.contains(".")
    }
    
    func inputPercentage() {
        guard let value = Double(display) else { return }
        let percent = value / 100
        display = formatResult(percent)
        hasDecimal = display.contains(".")
    }
    
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
    
    // MARK: — Scientific
    
    func inputSin() {
        guard let value = Double(display), display != "\u{9519}\u{8bef}" else { return }
        let input = display
        display = formatResult(sin(value * .pi / 180))
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "sin(\(input))", result: display) }
    }
    
    func inputCos() {
        guard let value = Double(display), display != "\u{9519}\u{8bef}" else { return }
        let input = display
        display = formatResult(cos(value * .pi / 180))
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "cos(\(input))", result: display) }
    }
    
    func inputTan() {
        guard let value = Double(display), display != "\u{9519}\u{8bef}" else { return }
        let input = display
        let rad = value * .pi / 180
        if abs(cos(rad)) < 1e-10 { display = "\u{9519}\u{8bef}"; return }
        display = formatResult(tan(rad))
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "tan(\(input))", result: display) }
    }
    
    func inputLog() {
        guard let value = Double(display), value > 0, display != "\u{9519}\u{8bef}" else {
            display = "\u{9519}\u{8bef}"; return
        }
        let input = display
        display = formatResult(log10(value))
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "log(\(input))", result: display) }
    }
    
    func inputLn() {
        guard let value = Double(display), value > 0, display != "\u{9519}\u{8bef}" else {
            display = "\u{9519}\u{8bef}"; return
        }
        let input = display
        display = formatResult(log(value))
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "ln(\(input))", result: display) }
    }
    
    func inputSqrt() {
        guard let value = Double(display), value >= 0, display != "\u{9519}\u{8bef}" else {
            display = "\u{9519}\u{8bef}"; return
        }
        let input = display
        display = formatResult(sqrt(value))
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "\u{221a}(\(input))", result: display) }
    }
    
    func inputSquare() {
        guard let value = Double(display), display != "\u{9519}\u{8bef}" else { return }
        let input = display
        display = formatResult(value * value)
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "(\(input))\u{00b2}", result: display) }
    }
    
    func inputPi() {
        display = formatResult(.pi)
        hasDecimal = true
        shouldResetDisplay = false
        historyStore?.add(expression: "\u{03c0}", result: display)
    }
    
    func inputE() {
        display = formatResult(M_E)
        hasDecimal = true
        shouldResetDisplay = false
        historyStore?.add(expression: "e", result: display)
    }
    
    func inputReciprocal() {
        guard let value = Double(display), value != 0, display != "\u{9519}\u{8bef}" else {
            display = "\u{9519}\u{8bef}"; return
        }
        let input = display
        display = formatResult(1 / value)
        hasDecimal = display.contains(".")
        if display != "\u{9519}\u{8bef}" { historyStore?.add(expression: "1/(\(input))", result: display) }
    }
    
    // MARK: — Core
    
    private func calculate(_ a: Double, _ b: Double, _ op: Operation) -> Double {
        switch op {
        case .add:      return a + b
        case .subtract: return a - b
        case .multiply: return a * b
        case .divide:   return b == 0 ? .infinity : a / b
        case .power:    return pow(a, b)
        }
    }
    
    private func formatResult(_ value: Double) -> String {
        if value.isInfinite { return "\u{9519}\u{8bef}" }
        if value.isNaN { return "\u{9519}\u{8bef}" }
        
        let integerPart = Int(value)
        if Double(integerPart) == value {
            return "\(integerPart)"
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimalPlaces
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
