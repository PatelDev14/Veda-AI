import SwiftUI

// MARK: - Elegant Pulsing Ring
struct PulsingRingView: View {
    @State private var animate = false
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [Color.red.opacity(0.7), Color.orange.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 2
            )
            .scaleEffect(animate ? 1.5 : 1.0)
            .opacity(animate ? 0.0 : 0.8)
            .animation(
                .easeOut(duration: 1.2)
                .repeatForever(autoreverses: false),
                value: animate
            )
            .onAppear { animate = true }
    }
}

struct InputBarView: View {
    @Binding var text: String
    let onSend: () -> Void
    let onCameraTap: () -> Void
    
    @State private var speechService = SpeechService.shared
    @State private var isSendHighlighted = false
    
    var body: some View {
        HStack(spacing: 14) {
            
            // MARK: - Camera Button
            Button(action: onCameraTap) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.orange.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(color: .orange.opacity(0.2), radius: 6)
                    )
            }
            
            // MARK: - Microphone Button
            Button {
                if speechService.isRecording {
                    speechService.stopRecording()
                    text = speechService.transcribedText
                } else {
                    speechService.transcribedText = ""
                    do {
                        try speechService.startRecording()
                    } catch {
                        print("❌ Recording start failed: \(error)")
                    }
                }
            } label: {
                ZStack {
                    if speechService.isRecording {
                        PulsingRingView()
                            .frame(width: 48, height: 48)
                    }
                    
                    Image(systemName: speechService.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(
                            speechService.isRecording
                                ? Color.red.opacity(0.9)
                                : Color.orange.opacity(0.85)
                        )
                        .symbolEffect(.pulse, options: .repeating)
                }
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(
                                    speechService.isRecording
                                        ? Color.red.opacity(0.5)
                                        : Color.orange.opacity(0.25),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: speechService.isRecording
                                ? .red.opacity(0.4)
                                : .orange.opacity(0.25),
                            radius: speechService.isRecording ? 12 : 6
                        )
                )
            }
            
            // MARK: - Text Field
            TextField(
                speechService.isRecording
                    ? "Listening..."
                    : "Ask Veda...",
                text: $text,
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.6)
                    )
            )
            .lineLimit(1...6)
            .onSubmit(of: .text) {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend()
                }
            }
            .onChange(of: speechService.isRecording) { _, newValue in
                if !newValue {
                    text = speechService.transcribedText
                }
            }
            
            // MARK: - Send Button
            Button(action: {
                onSend()
                isSendHighlighted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isSendHighlighted = false
                }
            })
            {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.white.opacity(0.2)
                        : Color.orange
                    )
                    .scaleEffect(isSendHighlighted ? 1.1 : 1.0)
                    .animation(.easeOut(duration: 0.2), value: isSendHighlighted)

            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSendHighlighted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.18),
                                    Color.indigo.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview
#Preview {
    InputBarView(
        text: .constant("Namaste..."),
        onSend: {},
        onCameraTap: {}
    )
    .background(Color.black.opacity(0.9))
    .preferredColorScheme(.dark)
}
