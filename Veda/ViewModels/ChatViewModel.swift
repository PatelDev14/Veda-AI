import SwiftUI
import Observation  // For @Observable in iOS 17+

@Observable
@MainActor
class ChatViewModel {
    var messages: [Message] = []
    var currentInput: String = ""
    var isGenerating: Bool = false
    private var currentAssistantMessageIndex: Int?
    var isModelLoading: Bool = true
    var selectedImage: UIImage? = nil
    
    func checkStatus() {
        Task {
            // This loop checks every 0.5 seconds if the brain is ready
            // We look at the shared service we just updated
            while await FoundationModelService.shared.isSessionNil() {
                try? await Task.sleep(for: .seconds(0.5))
            }
            
            // Once session is not nil, update the UI
            isModelLoading = false
            print("✅ ViewModel: Veda is ready and loading is set to false")
        }
    }

    // Helper to check if session is ready (Add this to FoundationModelService.swift if needed, or just check the property)
    
    func sendMessage() {
        let trimmedInput = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        let userMessage = Message(role: .user, content: trimmedInput)
        messages.append(userMessage)
        
        currentInput = ""
        
        // Add streaming placeholder for assistant
        let placeholderIndex = messages.count
        let placeholder = Message(role: .assistant, content: "")
        messages.append(placeholder)
        
        isGenerating = true
        
        Task { [weak self] in
            guard let self else { return }
            
            await FoundationModelService.shared.generateResponse(
                for: trimmedInput,  // ← only latest user message; history is auto-included by session!
                updateHandler: { partial in
                    Task { @MainActor in
                        if placeholderIndex < self.messages.count {
                            self.messages[placeholderIndex].content = partial
                        }
                    }
                },
                completion: { result in
                    Task { @MainActor in
                        self.isGenerating = false
                        
                        if case .failure(let error) = result,
                           placeholderIndex < self.messages.count {
                            self.messages[placeholderIndex].content = "Error: \(error.localizedDescription)\n\n(Try again or check Apple Intelligence settings)"
                        }
                    }
                }
            )
            self.selectedImage = nil
        }
    }
    
    func clearChat() {
        messages.removeAll()
    }
}
