import Foundation
import FoundationModels
import UIKit

@MainActor
class FoundationModelService {
    static let shared = FoundationModelService()
    
    private var session: LanguageModelSession?
    private var initializationTask: Task<Void, Never>? = nil
    
    private init() {
    }
    
    func isSessionNil() -> Bool {
        return session == nil
    }
    
    private func initializeSession() async {
        let model = SystemLanguageModel.default
        
        switch model.availability {
        case .available:
            do {
                let systemInstructions = """
                You are Veda, a wise, calm, and helpful AI companion.
                Respond thoughtfully, concisely, and insightfully.
                Use simple, natural language. Be empathetic and encouraging.
                """
                
                self.session = try LanguageModelSession(
                    model: model,
                    instructions: systemInstructions
                )
                
                print("✅ Veda's brain is ready.")
                
                try? await session?.prewarm()
                print("🧠 Pre-warm complete.")
                
            } catch {
                print("❌ Session creation failed: \(error)")
            }
            
        case .unavailable(let reason):
            print("❌ Model unavailable: \(reason)")
        }
    }
    
    private func ensureInitialized() async {
        if session != nil { return }
        
        if let task = initializationTask {
            _ = await task.value
            return
        }
        
        initializationTask = Task {
            await initializeSession()
        }
        
        _ = await initializationTask?.value
    }
    
    func generateResponse(for promptString: String,
                          updateHandler: @escaping @MainActor (String) -> Void,
                          completion: @escaping @MainActor (Result<String, Error>) -> Void) async {
        
        await ensureInitialized()
        
        guard let session = self.session else {
            completion(.failure(NSError(domain: "Veda", code: -1, userInfo: [NSLocalizedDescriptionKey: "Brain not ready"])))
            return
        }
        
        do {
            let stream = session.streamResponse(to: promptString)
            
            var accumulated = ""
            
            for try await partial in stream {
                accumulated = partial.content
                updateHandler(accumulated)
            }
            
            completion(.success(accumulated))
            
        } catch {
            completion(.failure(error))
        }
    }
}
