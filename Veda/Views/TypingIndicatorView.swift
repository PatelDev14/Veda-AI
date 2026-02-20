import SwiftUI

struct TypingIndicatorView: View {
    @State private var dotCount = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == dotCount ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: dotCount)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
}
