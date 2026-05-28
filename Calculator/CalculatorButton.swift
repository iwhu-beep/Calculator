import SwiftUI
import AVFoundation
import UIKit

private let synthesizer: AVSpeechSynthesizer = {
    let s = AVSpeechSynthesizer()
    return s
}()

private var voiceCache: String = ""
private var cachedVoice: AVSpeechSynthesisVoice?

private func resolveVoice() -> AVSpeechSynthesisVoice {
    let identifier = UserDefaults.standard.string(forKey: "voiceIdentifier") ?? ""
    if identifier == voiceCache, let v = cachedVoice { return v }
    let all = AVSpeechSynthesisVoice.speechVoices()
    if !identifier.isEmpty, let match = all.first(where: { $0.identifier == identifier }) {
        cachedVoice = match
        voiceCache = identifier
        return match
    }
    let enhanced = all.first { $0.language == "zh-CN" && ($0.quality == .enhanced || $0.quality == .premium) }
        ?? AVSpeechSynthesisVoice(language: "zh-CN")
    cachedVoice = enhanced
    voiceCache = "default"
    return enhanced ?? AVSpeechSynthesisVoice(language: "zh-CN")!
}

enum ButtonType {
    case digit(String)
    case `operator`(String)
    case function(String)
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
            if hapticEnabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                action()
            }
            if speechEnabled {
                speak(speakLabel?() ?? speechText)
            }
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
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - spacing * 5) / 4
    }
    
    private var label: String {
        switch type {
        case .digit(let d):       return d
        case .`operator`(let o):  return o
        case .function(let f):    return f
        }
    }
    
    private var speechText: String {
        switch type {
        case .digit(let d):       return d
        case .`operator`(let o):
            switch o {
            case "\u{00f7}": return "\u{9664}\u{4ee5}"
            case "\u{00d7}": return "\u{4e58}\u{4ee5}"
            case "-": return "\u{51cf}\u{53bb}"
            case "+": return "\u{52a0}\u{4e0a}"
            default:  return o
            }
        case .function(let f):
            switch f {
            case "AC":  return "\u{6e05}\u{9664}"
            case "+/-": return "\u{6b63}\u{8d1f}\u{53f7}"
            case "%":   return "\u{767e}\u{5206}\u{6bd4}"
            default:    return f
            }
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .digit:       return Color(red: 0.12, green: 0.22, blue: 0.50)
        case .`operator`:  return Color(red: 0.25, green: 0.60, blue: 0.95)
        case .function:    return Color(red: 0.50, green: 0.78, blue: 0.95)
        }
    }
    
    private var foregroundColor: Color {
        switch type {
        case .digit:       return .white
        case .`operator`:  return .white
        case .function:    return Color(red: 0.04, green: 0.08, blue: 0.22)
        }
    }
    
    private var fontSize: CGFloat {
        switch type {
        case .digit:       return 36
        case .`operator`:  return 40
        case .function:    return 30
        }
    }
    
    private var fontWeight: Font.Weight {
        switch type {
        case .digit:       return .medium
        case .`operator`:  return .bold
        case .function:    return .semibold
        }
    }
    
    private func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = resolveVoice()
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.08
        synthesizer.speak(utterance)
    }
}
