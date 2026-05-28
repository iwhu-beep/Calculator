import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    @StateObject private var historyStore = HistoryStore()
    @AppStorage("speechEnabled") private var speechEnabled = true
    @State private var showSettings = false
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.08, blue: 0.22).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                displayArea
                    .padding(.horizontal, 28)
                
                toolbarRow
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                keypad
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showHistory) { HistoryView(store: historyStore) }
        .onAppear { engine.historyStore = historyStore }
    }
    
    private var displayArea: some View {
        VStack(spacing: 2) {
            HStack {
                Spacer()
                Text(engine.operatorSymbol)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundColor(accentColor)
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
    
    private var toolbarRow: some View {
        HStack(spacing: 10) {
            toolbarButton(icon: "clock.arrow.circlepath", label: "\u{5386}\u{53f2}") { showHistory = true }
            toolbarButton(icon: speechEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                          label: "\u{8bed}\u{97f3}", active: speechEnabled) { speechEnabled.toggle() }
            toolbarButton(icon: "delete.left.fill", label: "\u{9000}\u{4f4d}") { engine.inputDelete() }
            toolbarButton(icon: "gearshape.fill", label: "\u{8bbe}\u{7f6e}") { showSettings = true }
        }
    }
    
    private func toolbarButton(icon: String, label: String, active: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(active ? accentColor : Color(white: 0.7))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color(red: 0.08, green: 0.14, blue: 0.32))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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
    private var accentColor: Color { Color(red: 0.50, green: 0.78, blue: 0.95) }
}
