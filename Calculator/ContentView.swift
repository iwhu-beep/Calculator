import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    @AppStorage("speechEnabled") private var speechEnabled = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                displayArea
                    .padding(.horizontal, 24)
                
                speakerToggle
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                
                keypad
            }
        }
    }
    
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
        .frame(height: 100)
    }
    
    private var speakerToggle: some View {
        HStack {
            Spacer()
            Button {
                speechEnabled.toggle()
            } label: {
                Image(systemName: speechEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 18))
                    .foregroundColor(speechEnabled ? .orange : Color(white: 0.4))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var displayFontSize: CGFloat {
        let count = engine.display.count
        if count <= 6  { return 80 }
        if count <= 9  { return 60 }
        if count <= 12 { return 44 }
        return 34
    }
    
    private var keypad: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                CalculatorButton(type: .function("AC"), speechEnabled: speechEnabled)   { engine.inputClear() }
                CalculatorButton(type: .function("+/-"), speechEnabled: speechEnabled)  { engine.inputToggleSign() }
                CalculatorButton(type: .function("%"), speechEnabled: speechEnabled)    { engine.inputPercentage() }
                CalculatorButton(type: .`operator`("/"), speechEnabled: speechEnabled)  { engine.inputOperation(.divide) }
            }
            
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("7"), speechEnabled: speechEnabled)      { engine.inputDigit(7) }
                CalculatorButton(type: .digit("8"), speechEnabled: speechEnabled)      { engine.inputDigit(8) }
                CalculatorButton(type: .digit("9"), speechEnabled: speechEnabled)      { engine.inputDigit(9) }
                CalculatorButton(type: .`operator`("*"), speechEnabled: speechEnabled) { engine.inputOperation(.multiply) }
            }
            
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("4"), speechEnabled: speechEnabled)      { engine.inputDigit(4) }
                CalculatorButton(type: .digit("5"), speechEnabled: speechEnabled)      { engine.inputDigit(5) }
                CalculatorButton(type: .digit("6"), speechEnabled: speechEnabled)      { engine.inputDigit(6) }
                CalculatorButton(type: .`operator`("-"), speechEnabled: speechEnabled) { engine.inputOperation(.subtract) }
            }
            
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("1"), speechEnabled: speechEnabled)      { engine.inputDigit(1) }
                CalculatorButton(type: .digit("2"), speechEnabled: speechEnabled)      { engine.inputDigit(2) }
                CalculatorButton(type: .digit("3"), speechEnabled: speechEnabled)      { engine.inputDigit(3) }
                CalculatorButton(type: .`operator`("+"), speechEnabled: speechEnabled) { engine.inputOperation(.add) }
            }
            
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("0"), widthMultiplier: 2, speechEnabled: speechEnabled) { engine.inputDigit(0) }
                CalculatorButton(type: .digit("."), speechEnabled: speechEnabled) { engine.inputDecimal() }
                CalculatorButton(type: .`operator`("="), speechEnabled: speechEnabled) { engine.inputEquals() }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
    
    private var spacing: CGFloat { 8 }
}
