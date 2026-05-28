import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: HistoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if store.records.isEmpty {
                    emptyView
                } else {
                    recordList
                }
            }
            .navigationTitle("\u{5386}\u{53f2}\u{8bb0}\u{5f55}")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("\u{8fd4}\u{56de}")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.records.isEmpty {
                        Button { showClearAlert = true } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
            }
            .alert("\u{6e05}\u{7a7a}\u{5168}\u{90e8}\u{8bb0}\u{5f55}\u{ff1f}", isPresented: $showClearAlert) {
                Button("\u{53d6}\u{6d88}", role: .cancel) {}
                Button("\u{6e05}\u{7a7a}", role: .destructive) { store.clearAll() }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundColor(Color(white: 0.3))
            Text("\u{6682}\u{65e0}\u{8bb0}\u{5f55}")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
    
    private var recordList: some View {
        List {
            ForEach(store.records) { record in
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.expression)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(white: 0.7))
                    
                    HStack {
                        Text("= \(record.result)")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Text(record.formattedTime)
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.4))
                    }
                }
                .padding(.vertical, 6)
                .listRowBackground(rowBg)
                .listRowSeparatorTint(Color(white: 0.12))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(bgColor)
    }
    
    private var bgColor: Color { Color(red: 0.04, green: 0.08, blue: 0.22) }
    private var accentColor: Color { Color(red: 0.50, green: 0.78, blue: 0.95) }
    private var rowBg: Color { Color(red: 0.08, green: 0.14, blue: 0.32) }
}
