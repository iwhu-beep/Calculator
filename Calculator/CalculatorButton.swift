import SwiftUI

enum ButtonType {
    case digit(String)
    case `operator`(String)
    case function(String)
}

struct CalculatorButton: View {
    let type: ButtonType
    var widthMultiplier: CGFloat = 1
    var action: () -> Void
    
    private let spacing: CGFloat = 8
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                action()
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
        .accessibilityAddTraits(.isButton)
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
    
    private var backgroundColor: Color {
        switch type {
        case .digit:       return Color(white: 0.2)
        case .`operator`:  return .orange
        case .function:    return Color(white: 0.6)
        }
    }
    
    private var foregroundColor: Color {
        switch type {
        case .digit:       return .white
        case .`operator`:  return .white
        case .function:    return .black
        }
    }
    
    private var fontSize: CGFloat {
        switch type {
        case .digit:       return 34
        case .`operator`:  return 38
        case .function:    return 28
        }
    }
    
    private var fontWeight: Font.Weight {
        switch type {
        case .digit:       return .medium
        case .`operator`:  return .bold
        case .function:    return .medium
        }
    }
}
