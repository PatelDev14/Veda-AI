import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        Group {
            if message.isUser {
                bubbleText
                    .background(userBackground)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                bubbleText
                    .background(assistantBackground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
    }
    
    // MARK: - Text Styling (Sleeker Formatting)
    
    private var bubbleText: some View {
        Text(.init(message.content)) // Enables Markdown formatting
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(.white.opacity(0.95))
            .lineSpacing(4)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
    }
    
    // MARK: - Clean User Bubble
    private var userBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
    
    // MARK: - Clean Assistant Bubble (NO blur, NO shadow box)
    private var assistantBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.thinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.orange.opacity(0.15), lineWidth: 1)
            )
    }

    
}


// MARK: - Mandala Overlay (unchanged)
struct MandalaOverlay: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [.orange.opacity(0.4), .purple.opacity(0.3), .orange.opacity(0.4)],
                            center: .center
                        ),
                        lineWidth: 1
                    )
                    .frame(width: geo.size.width * 1.5)
                
                ForEach(1..<4) { i in
                    Circle()
                        .strokeBorder(Color.orange.opacity(0.1), lineWidth: 0.5)
                        .frame(width: geo.size.width * CGFloat(Double(i) * 0.4))
                        .blur(radius: 2)
                }
            }
            .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
        }
    }
}


// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            MessageBubbleView(message: Message(role: .user, content: "How does the universe begin?"))
            MessageBubbleView(message: Message(role: .assistant, content: """
            In the stillness before time, wisdom suggests a single point of infinite potential.

            • Energy condensed  
            • Space expanded  
            • Consciousness emerged  

            🌌
            """))
        }
    }
    .preferredColorScheme(.dark)
}
