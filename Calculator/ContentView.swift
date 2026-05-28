import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                // Display
                displayArea
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                // Keypad
                keypad
            }
        }
    }
    
    // MARK: — Display
    
    private var displayArea: some View {
        HStack {
            Spacer()
            Text(engine.display)
                .font(.system(size: displayFontSize, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 120)
    }
    
    private var displayFontSize: CGFloat {
        let count = engine.display.count
        if count <= 6  { return 80 }
        if count <= 9  { return 60 }
        if count <= 12 { return 44 }
        return 34
    }
    
    // MARK: — Keypad
    
    private var keypad: some View {
        VStack(spacing: spacing) {
            // Row 1: AC, +-, %, /
            HStack(spacing: spacing) {
                CalculatorButton(type: .function("AC")) { engine.inputClear() }
                CalculatorButton(type: .function("+-"))  { engine.inputToggleSign() }
                CalculatorButton(type: .function("%"))  { engine.inputPercentage() }
                CalculatorButton(type: .operator("/"))  { engine.inputOperation(.divide) }
            }
            
            // Row 2: 7, 8, 9, x
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("7"))  { engine.inputDigit(7) }
                CalculatorButton(type: .digit("8"))  { engine.inputDigit(8) }
                CalculatorButton(type: .digit("9"))  { engine.inputDigit(9) }
                CalculatorButton(type: .operator("x")) { engine.inputOperation(.multiply) }
            }
            
            // Row 3: 4, 5, 6, -
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("4"))  { engine.inputDigit(4) }
                CalculatorButton(type: .digit("5"))  { engine.inputDigit(5) }
                CalculatorButton(type: .digit("6"))  { engine.inputDigit(6) }
                CalculatorButton(type: .operator("-")) { engine.inputOperation(.subtract) }
            }
            
            // Row 4: 1, 2, 3, +
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("1"))  { engine.inputDigit(1) }
                CalculatorButton(type: .digit("2"))  { engine.inputDigit(2) }
                CalculatorButton(type: .digit("3"))  { engine.inputDigit(3) }
                CalculatorButton(type: .operator("+")) { engine.inputOperation(.add) }
            }
            
            // Row 5: 0, ., =
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("0"), widthMultiplier: 2) { engine.inputDigit(0) }
                CalculatorButton(type: .digit(".")) { engine.inputDecimal() }
                CalculatorButton(type: .operator("=")) { engine.inputEquals() }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
    
    private var spacing: CGFloat { 8 }
}
