import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var showingCamera = false
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            // 1. Dynamic Ethereal Background
            VedaCosmicBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header with Veda Logo/Aura
                headerView
                
                // 2. Messages list with improved spacing
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isGenerating {
                                TypingIndicatorContainer()
                            }
                            
                            Color.clear.frame(height: 20)
                        }
                        .padding(.top, 20)
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation(.spring()) {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                
                // 3. Premium Glass Input Bar
                InputBarView(
                    text: $viewModel.currentInput,
                    onSend: viewModel.sendMessage,
                    onCameraTap: { showingCamera = true }
                )
                .padding(.bottom, 8)
                .background(.ultraThinMaterial.opacity(0.5))
            }
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera) { image in
                capturedImage = image
                Task { @MainActor in
                    await processCapturedImage(image)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar) // Hidden because we built a custom header
        .preferredColorScheme(.dark)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("VEDA")
                    .font(.system(size: 13, weight: .heavy, design: .serif))
                    .tracking(6)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.9), Color.yellow.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Wisdom in Motion")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
            
            Spacer()
            
            Button(action: { viewModel.clearChat() }) {
                //Image(systemName: "sparkles.rectangle.stack.fill")
                Image(systemName: "plus.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange.opacity(0.8))
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                            )
                    )
            }
            .disabled(viewModel.messages.isEmpty)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.indigo.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    
    // Your existing logic remains exactly the same
    private func processCapturedImage(_ image: UIImage) async {
        do {
            let description = try await VisionService.shared.describe(image: image)
            let contextMessage = Message(role: .assistant, content: "[Image captured] \(description)")
            viewModel.messages.append(contextMessage)
            viewModel.currentInput = "Describe or help with this: \(description)"
            viewModel.sendMessage()
        } catch {
            let errorMsg = Message(role: .assistant, content: "Couldn't analyze image: \(error.localizedDescription)")
            viewModel.messages.append(errorMsg)
        }
    }
}

// MARK: - Amazing Dynamic Background
struct VedaCosmicBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black // Base
            
            // Shifting Nebula Blobs
            Circle()
                .fill(Color.indigo.opacity(0.3))
                .frame(width: 400)
                .blur(radius: 80)
                .offset(x: animate ? 100 : -100, y: animate ? -200 : -100)
            
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 300)
                .blur(radius: 70)
                .offset(x: animate ? -150 : 50, y: animate ? 200 : 100)
            
            // Mandala Grid
            MandalaOverlay()
                .opacity(0.12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Premium Typing Indicator
struct TypingIndicatorContainer: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Veda is contemplating...")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.orange.opacity(0.6))
                    .padding(.leading, 4)
                
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                            .frame(width: 6, height: 6)
                            .phaseAnimator([0, 1]) { content, phase in
                                content
                                    .scaleEffect(phase == 1 ? 1.3 : 0.7)
                                    .opacity(phase == 1 ? 1 : 0.3)
                            } animation: { phase in
                                .easeInOut(duration: 0.8).delay(Double(i) * 0.2)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.white.opacity(0.05))
                .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
    .preferredColorScheme(.dark)
}
