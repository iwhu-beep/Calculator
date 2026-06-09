import SwiftUI

@main
struct CalculatorApp: App {
    @AppStorage("screenAlwaysOn") private var screenAlwaysOn = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = screenAlwaysOn
                }
                .onChange(of: screenAlwaysOn) { _, newValue in
                    UIApplication.shared.isIdleTimerDisabled = newValue
                }
        }
    }
}
