import Foundation
import Vision
import UIKit

@MainActor
class VisionService {
    static let shared = VisionService()
    
    private init() {}
    
    /// Analyzes a UIImage and returns a descriptive string using available Vision requests.
    /// Focuses on text extraction + basic classification (no native captioning API exists).
    func describe(image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "VisionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        // 1. Text recognition (core strength of Vision - supports 26+ languages)
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        textRequest.minimumTextHeight = 0.0  // Catch small text too
        
        // 2. Image classification (gets main subject like "coffee", "bicycle", "person")
        let classifyRequest = VNClassifyImageRequest()
        classifyRequest.revision = VNClassifyImageRequestRevision1  // Or latest available
        
        // Perform both requests concurrently
        try await handler.perform([textRequest, classifyRequest])
        
        var descriptionParts: [String] = []
        
        // Classification results (top categories)
        if let topClassification = classifyRequest.results?.first {
            let mainSubject = topClassification.identifier  // e.g., "cup", "bicycle", "person"
            let confidence = String(format: "%.0f%%", topClassification.confidence * 100)
            descriptionParts.append("Main subject: \(mainSubject) (\(confidence) confidence)")
        }
        
        // Extracted text
        let textObservations = textRequest.results ?? []
        if !textObservations.isEmpty {
            let texts = textObservations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            if !texts.isEmpty {
                descriptionParts.append("Visible text: " + texts.joined(separator: " | "))
            }
        }
        
        if descriptionParts.isEmpty {
            return "No recognizable text or subject detected in the image."
        }
        
        return descriptionParts.joined(separator: "\n\n")
    }
}
