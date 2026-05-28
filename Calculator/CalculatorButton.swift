import SwiftUI
import AVFoundation

private let synthesizer = AVSpeechSynthesizer()

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
    
    private let spacing: CGFloat = 10
    
    var body: some View {
        Button(action: {
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
                    .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
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
            case "/": return "除以"
            case "*": return "乘以"
            case "-": return "减去"
            case "+": return "加上"
            default:  return o
            }
        case .function(let f):
            switch f {
            case "AC":  return "清除"
            case "+/-": return "正负号"
            case "%":   return "百分比"
            default:    return f
            }
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .digit:       return Color(white: 0.18)
        case .`operator`:  return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .function:    return Color(white: 0.12)
        }
    }
    
    private var foregroundColor: Color {
        switch type {
        case .digit:       return .white
        case .`operator`:  return .white
        case .function:    return Color(red: 1.0, green: 0.58, blue: 0.0)
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
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
