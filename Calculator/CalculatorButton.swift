import SwiftUI
import AVFoundation
import UIKit

private let synthesizer: AVSpeechSynthesizer = { let s = AVSpeechSynthesizer(); return s }()

private var voiceCache = ""
private var cachedVoice: AVSpeechSynthesisVoice?

private func resolveVoice() -> AVSpeechSynthesisVoice {
    let id = UserDefaults.standard.string(forKey: "voiceIdentifier") ?? ""
    if id == voiceCache, let v = cachedVoice { return v }
    let all = AVSpeechSynthesisVoice.speechVoices()
    if !id.isEmpty, let m = all.first(where: { $0.identifier == id }) { cachedVoice = m; voiceCache = id; return m }
    let e = all.first { $0.language == "zh-CN" && $0.quality.rawValue >= 2 } ?? AVSpeechSynthesisVoice(language: "zh-CN")
    cachedVoice = e; voiceCache = "default"
    return e ?? AVSpeechSynthesisVoice(language: "zh-CN")!
}

enum ButtonType {
    case digit(String)
    case `operator`(String)
    case function(String)
    case sciFunction(String)
}

struct CalculatorButton: View {
    let type: ButtonType
    var widthMultiplier: CGFloat = 1
    var speechEnabled: Bool = true
    var speakLabel: (() -> String)? = nil
    var action: () -> Void
    
    @AppStorage("buttonSize") private var buttonSize = 1.0
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    
    private let spacing: CGFloat = 10
    
    var body: some View {
        Button(action: {
            if hapticEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { action() }
            if speechEnabled { speak(speakLabel?() ?? speechText) }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: baseSize / 2)
                    .fill(backgroundColor)
                Text(label)
                    .font(.system(size: fontSize * buttonSize, weight: fontWeight, design: .rounded))
                    .foregroundColor(foregroundColor)
            }
            .frame(width: baseSize * widthMultiplier + (widthMultiplier - 1) * spacing, height: baseSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
    
    private var baseSize: CGFloat {
        let w = UIScreen.main.bounds.width
        return (w - spacing * 5) / 4
    }
    
    private var label: String {
        switch type {
        case .digit(let d):       return d
        case .`operator`(let o):  return o
        case .function(let f):    return f
        case .sciFunction(let s): return s
        }
    }
    
    private var speechText: String {
        switch type {
        case .digit(let d): return d
        case .`operator`(let o):
            switch o {
            case "\u{00f7}": return "\u{9664}\u{4ee5}"
            case "\u{00d7}": return "\u{4e58}\u{4ee5}"
            case "-": return "\u{51cf}\u{53bb}"
            case "+": return "\u{52a0}\u{4e0a}"
            case "x\u{02b8}": return "\u{6b21}\u{65b9}"
            default: return o
            }
        case .function(let f):
            switch f {
            case "AC": return "\u{6e05}\u{9664}"
            case "\u{232b}": return "\u{9000}\u{4f4d}"
            case "%": return "\u{767e}\u{5206}\u{6bd4}"
            default: return f
            }
        case .sciFunction(let s):
            switch s {
            case "sin": return "sin"
            case "cos": return "cos"
            case "tan": return "tan"
            case "log": return "log"
            case "ln":  return "ln"
            case "\u{221a}": return "\u{5f00}\u{6839}\u{53f7}"
            case "x\u{00b2}": return "\u{5e73}\u{65b9}"
            case "\u{03c0}": return "\u{03c0}"
            case "e":  return "e"
            default: return s
            }
        }
    }
    
    private var isClear: Bool {
        if case .function(let f) = type, f == "AC" { return true }
        return false
    }
    
    private var backgroundColor: Color {
        if isClear { return Color(red: 0.9, green: 0.2, blue: 0.2) }
        switch type {
        case .digit:        return Color(red: 0.12, green: 0.22, blue: 0.50)
        case .`operator`:   return Color(red: 0.25, green: 0.60, blue: 0.95)
        case .function:     return Color(red: 0.50, green: 0.78, blue: 0.95)
        case .sciFunction:  return Color(red: 0.06, green: 0.18, blue: 0.42)
        }
    }
    
    private var foregroundColor: Color {
        if isClear { return .white }
        switch type {
        case .digit:        return .white
        case .`operator`:   return .white
        case .function:     return Color(red: 0.04, green: 0.08, blue: 0.22)
        case .sciFunction:  return accentColor
        }
    }
    
    private var fontSize: CGFloat {
        switch type {
        case .digit:        return 36
        case .`operator`:   return 40
        case .function:     return 30
        case .sciFunction:  return 28
        }
    }
    
    private var fontWeight: Font.Weight {
        switch type {
        case .digit:        return .medium
        case .`operator`:   return .bold
        case .function:     return .semibold
        case .sciFunction:  return .medium
        }
    }
    
    private func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = resolveVoice()
        u.rate = 0.48
        u.pitchMultiplier = 1.08
        synthesizer.speak(u)
    }
    
    private var accentColor: Color { Color(red: 0.50, green: 0.78, blue: 0.95) }
}
