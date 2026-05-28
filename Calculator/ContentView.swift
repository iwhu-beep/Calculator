import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    @AppStorage("speechEnabled") private var speechEnabled = true
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.09).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                displayArea
                    .padding(.horizontal, 28)
                
                speakerToggle
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)
                
                keypad
            }
        }
    }
    
    private var displayArea: some View {
        VStack(spacing: 2) {
            HStack {
                Spacer()
                Text(engine.operatorSymbol)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                    .frame(height: 30)
            }
            HStack {
                Spacer()
                Text(engine.display)
                    .font(.system(size: displayFontSize, weight: .thin, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
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
                    .font(.system(size: 16))
                    .foregroundColor(speechEnabled
                        ? Color(red: 1.0, green: 0.58, blue: 0.0)
                        : Color(white: 0.25))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var displayFontSize: CGFloat {
        let count = engine.display.count
        if count <= 6  { return 72 }
        if count <= 9  { return 52 }
        if count <= 12 { return 38 }
        return 30
    }
    
    private var keypad: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                CalculatorButton(type: .function("AC"), speechEnabled: speechEnabled)   { engine.inputClear() }
                CalculatorButton(type: .function("+/-"), speechEnabled: speechEnabled)  { engine.inputToggleSign() }
                CalculatorButton(type: .function("%"), speechEnabled: speechEnabled)    { engine.inputPercentage() }
                CalculatorButton(type: .`operator`("\u{00f7}"), speechEnabled: speechEnabled) { engine.inputOperation(.divide) }
            }
            
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("7"), speechEnabled: speechEnabled)      { engine.inputDigit(7) }
                CalculatorButton(type: .digit("8"), speechEnabled: speechEnabled)      { engine.inputDigit(8) }
                CalculatorButton(type: .digit("9"), speechEnabled: speechEnabled)      { engine.inputDigit(9) }
                CalculatorButton(type: .`operator`("\u{00d7}"), speechEnabled: speechEnabled) { engine.inputOperation(.multiply) }
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
                CalculatorButton(type: .`operator`("="), speechEnabled: speechEnabled,
                    speakLabel: { [engine] in
                        engine.display == "\u{9519}\u{8bef}" ? "\u{9519}\u{8bef}" : "\u{7b49}\u{4e8e}" + engine.display
                    }) { engine.inputEquals() }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 28)
    }
    
    private var spacing: CGFloat { 10 }
}
