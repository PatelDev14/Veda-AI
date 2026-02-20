import Foundation
import Speech
import Observation

@Observable
final class SpeechService {
    static let shared = SpeechService()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var transcribedText: String = ""
    var isRecording: Bool = false
    
    private init() {}
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized: print("✅ Speech Authorized")
                case .denied: print("❌ Speech Denied")
                case .restricted: print("❌ Speech Restricted")
                case .notDetermined: print("⚠️ Speech Not Determined")
                @unknown default: break
                }
            }
        }
    }

    
    func startRecording() throws {
        // 1. Cancel previous tasks
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // 2. Prepare Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // 3. Setup Request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // 4. Start Task
        let inputNode = audioEngine.inputNode

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.transcribedText = bestString
            }
            
            if let error = error {
                print("❌ Speech Error: \(error.localizedDescription)")
            }
        }
        
        // 5. Connect Microphone to Recognizer
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
}
