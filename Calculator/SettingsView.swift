import SwiftUI
import AVFoundation

struct SettingsView: View {
    @AppStorage("voiceIdentifier") private var voiceIdentifier = ""
    @AppStorage("decimalPlaces") private var decimalPlaces = 8
    @AppStorage("buttonSize") private var buttonSize = 1.0
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("screenAlwaysOn") private var screenAlwaysOn = false
    @Environment(\.dismiss) private var dismiss
    
    private let voices = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.hasPrefix("zh") }
    
    private var currentVoiceName: String {
        voices.first { $0.identifier == voiceIdentifier }?.name
            ?? AVSpeechSynthesisVoice(language: "zh-CN")?.name
            ?? "\u{7cfb}\u{7edf}\u{9ed8}\u{8ba4}"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                voiceSection
                decimalSection
                buttonSizeSection
                hapticSection
                screenSection
            }
            .navigationTitle("\u{8bbe}\u{7f6e}")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("\u{5b8c}\u{6210}") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(bgColor)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Voice
    
    private var voiceSection: some View {
        Section {
            ForEach(voices, id: \.identifier) { voice in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(voice.name)
                            .foregroundColor(.white)
                        Text(qualityLabel(voice.quality))
                            .font(.caption)
                            .foregroundColor(Color(white: 0.5))
                    }
                    Spacer()
                    if voice.identifier == voiceIdentifier {
                        Image(systemName: "checkmark")
                            .foregroundColor(accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    voiceIdentifier = voice.identifier
                }
            }
        } header: {
            Text("\u{8bed}\u{97f3}").foregroundColor(accentColor)
        }
        .listRowBackground(rowBg)
    }
    
    // MARK: - Decimal
    
    private var decimalSection: some View {
        Section {
            Stepper(value: $decimalPlaces, in: 0...8) {
                HStack {
                    Text("\u{5c0f}\u{6570}\u{70b9}\u{540e}\u{4f4d}\u{6570}")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(decimalPlaces) \u{4f4d}")
                        .foregroundColor(accentColor)
                        .fontWeight(.semibold)
                }
            }
        } header: {
            Text("\u{7cbe}\u{5ea6}").foregroundColor(accentColor)
        }
        .listRowBackground(rowBg)
    }
    
    // MARK: - Button Size
    
    private var buttonSizeSection: some View {
        Section {
            Picker("\u{6309}\u{952e}\u{5b57}\u{53f7}", selection: $buttonSize) {
                Text("\u{5c0f}").tag(0.85)
                Text("\u{4e2d}").tag(1.0)
                Text("\u{5927}").tag(1.2)
            }
            .pickerStyle(.segmented)
        } header: {
            Text("\u{6309}\u{952e}\u{5b57}\u{53f7}").foregroundColor(accentColor)
        }
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Haptic
    
    private var hapticSection: some View {
        Section {
            Toggle(isOn: $hapticEnabled) {
                Text("\u{6309}\u{952e}\u{9707}\u{52a8}")
                    .foregroundColor(.white)
            }
            .tint(accentColor)
        } header: {
            Text("\u{53cd}\u{9988}").foregroundColor(accentColor)
        }
        .listRowBackground(rowBg)
    }
    
    // MARK: - Screen

    private var screenSection: some View {
        Section {
            Toggle(isOn: $screenAlwaysOn) {
                Text("屏幕常亮")
                    .foregroundColor(.white)
            }
            .tint(accentColor)
        } header: {
            Text("屏幕").foregroundColor(accentColor)
        }
        .listRowBackground(rowBg)
    }

    // MARK: - Helpers
    
    private func qualityLabel(_ q: AVSpeechSynthesisVoiceQuality) -> String {
        switch q {
        case .premium:  return "\u{2733}\u{fe0f} \u{9ad8}\u{7ea7}"
        case .enhanced: return "\u{2b50} \u{589e}\u{5f3a}"
        default:        return "\u{57fa}\u{7840}"
        }
    }
    
    private var bgColor: Color { Color(red: 0.04, green: 0.08, blue: 0.22) }
    private var accentColor: Color { Color(red: 0.50, green: 0.78, blue: 0.95) }
    private var rowBg: Color { Color(red: 0.08, green: 0.14, blue: 0.32) }
}
