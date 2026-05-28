import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()
    @StateObject private var historyStore = HistoryStore()
    @AppStorage("speechEnabled") private var speechEnabled = true
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var isScientific = false
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                displayArea
                    .padding(.horizontal, 28)
                
                toolbarRow
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                if isScientific {
                    scientificRows
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                }
                
                keypad
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showHistory) { HistoryView(store: historyStore) }
        .onAppear { engine.historyStore = historyStore }
    }
    
    // MARK: — Display
    
    private var displayArea: some View {
        VStack(spacing: 2) {
            HStack {
                sciToggle
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
    
    private var sciToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isScientific.toggle() }
        } label: {
            Text("\u{79d1}\u{5b66}")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isScientific ? bgColor : accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isScientific ? accentColor : Color.clear)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(accentColor, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: — Toolbar
    
    private var toolbarRow: some View {
        HStack(spacing: 10) {
            toolBtn("clock.arrow.circlepath", "\u{5386}\u{53f2}") { showHistory = true }
            toolBtn(speechEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                    "\u{8bed}\u{97f3}", active: speechEnabled) { speechEnabled.toggle() }
            toolBtn("plus.forwardslash.minus", "\u{6b63}\u{8d1f}") { engine.inputToggleSign() }
            toolBtn("gearshape.fill", "\u{8bbe}\u{7f6e}") { showSettings = true }
        }
    }
    
    private func toolBtn(_ icon: String, _ label: String, active: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 16))
                Text(label).font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(active ? accentColor : Color(white: 0.7))
            .frame(maxWidth: .infinity).frame(height: 48)
            .background(rowBg).clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: — Scientific
    
    private var scientificRows: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                CalculatorButton(type: .sciFunction("sin"), speechEnabled: speechEnabled) { engine.inputSin() }
                CalculatorButton(type: .sciFunction("cos"), speechEnabled: speechEnabled) { engine.inputCos() }
                CalculatorButton(type: .sciFunction("tan"), speechEnabled: speechEnabled) { engine.inputTan() }
                CalculatorButton(type: .sciFunction("\u{03c0}"), speechEnabled: speechEnabled) { engine.inputPi() }
            }
            HStack(spacing: spacing) {
                CalculatorButton(type: .sciFunction("ln"), speechEnabled: speechEnabled)  { engine.inputLn() }
                CalculatorButton(type: .sciFunction("log"), speechEnabled: speechEnabled) { engine.inputLog() }
                CalculatorButton(type: .sciFunction("\u{221a}"), speechEnabled: speechEnabled) { engine.inputSqrt() }
                CalculatorButton(type: .sciFunction("e"), speechEnabled: speechEnabled) { engine.inputE() }
            }
        }
    }
    
    // MARK: — Keypad
    
    private var keypad: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                CalculatorButton(type: .function("AC"), speechEnabled: speechEnabled)     { engine.inputClear() }
                CalculatorButton(type: .function("\u{232b}"), speechEnabled: speechEnabled) { engine.inputDelete() }
                CalculatorButton(type: .function("%"), speechEnabled: speechEnabled)       { engine.inputPercentage() }
                CalculatorButton(type: .`operator`("\u{00f7}"), speechEnabled: speechEnabled) { engine.inputOperation(.divide) }
            }
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("7"), speechEnabled: speechEnabled)   { engine.inputDigit(7) }
                CalculatorButton(type: .digit("8"), speechEnabled: speechEnabled)   { engine.inputDigit(8) }
                CalculatorButton(type: .digit("9"), speechEnabled: speechEnabled)   { engine.inputDigit(9) }
                CalculatorButton(type: .`operator`("\u{00d7}"), speechEnabled: speechEnabled) { engine.inputOperation(.multiply) }
            }
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("4"), speechEnabled: speechEnabled)   { engine.inputDigit(4) }
                CalculatorButton(type: .digit("5"), speechEnabled: speechEnabled)   { engine.inputDigit(5) }
                CalculatorButton(type: .digit("6"), speechEnabled: speechEnabled)   { engine.inputDigit(6) }
                CalculatorButton(type: .`operator`("-"), speechEnabled: speechEnabled) { engine.inputOperation(.subtract) }
            }
            HStack(spacing: spacing) {
                CalculatorButton(type: .digit("1"), speechEnabled: speechEnabled)   { engine.inputDigit(1) }
                CalculatorButton(type: .digit("2"), speechEnabled: speechEnabled)   { engine.inputDigit(2) }
                CalculatorButton(type: .digit("3"), speechEnabled: speechEnabled)   { engine.inputDigit(3) }
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
        .padding(.bottom, 20)
    }
    
    private var displayFontSize: CGFloat {
        let c = engine.display.count
        if c <= 6  { return 72 }
        if c <= 9  { return 52 }
        if c <= 12 { return 38 }
        return 30
    }
    
    private var spacing: CGFloat { 10 }
    private var bgColor: Color { Color(red: 0.04, green: 0.08, blue: 0.22) }
    private var rowBg: Color { Color(red: 0.08, green: 0.14, blue: 0.32) }
    private var accentColor: Color { Color(red: 0.50, green: 0.78, blue: 0.95) }
}
