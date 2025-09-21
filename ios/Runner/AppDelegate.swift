import AudioToolbox
import UIKit
import Flutter
import AVFoundation
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL1 = "com.primocys.chat/audio"
    private var audioPlayer: AVAudioPlayer?
    private var isAudioPlaying = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("your_google_map_key_here") //You have to add here your google map key to share location
        // Initialize Firebase
        FirebaseApp.configure()

        let flutterEngine = self.window?.rootViewController as! FlutterViewController

        // Register plugins (this ensures that plugins like Firebase are initialized properly)
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // Register custom gallery plugin
        GalleryPlugin.register(with: self.registrar(forPlugin: "GalleryPlugin")!)

        // Set up the method channel to communicate with Flutter
        let channel = FlutterMethodChannel(name: CHANNEL1,
                                           binaryMessenger: flutterEngine.binaryMessenger)
        channel.setMethodCallHandler { (call, result) in
            if call.method == "setEarpiece" {
                self.setEarpiece()
                result(nil)
            } else if call.method == "playAudio" {
                if let args = call.arguments as? [String: Any], let audioFile = args["audioFile"] as? String {
                    self.playAudio(fileName: audioFile, channel: channel)
                } else {
                    // Play the system default sound (system alert tone)
                    self.playSystemSound(channel: channel)
                }
                result(nil)
            } else if call.method == "pauseAudio" {
                self.pauseAudio(channel: channel)
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Method to set the audio session for communication (earpiece)
    private func setEarpiece() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: .duckOthers)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(.none)  // Force audio to be routed to the earpiece
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // Play system sound (e.g., ringtone or alert tone)
    private func playSystemSound(channel: FlutterMethodChannel?) {
        // System sound ID for a notification sound or ringer
        let soundID: SystemSoundID = 2001
        
        AudioServicesPlaySystemSound(soundID)
        sendLogToFlutter(channel: channel, message: "System sound is playing.")
    }

    // Method to play the audio file (custom file from assets or provided path)
    private func playAudio(fileName: String, channel: FlutterMethodChannel?) {
        // Retrieve the path to the asset (located in the bundle)
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            sendLogToFlutter(channel: channel, message: "Audio file \(fileName) not found.")
            return
        }

        do {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isAudioPlaying = true
            sendLogToFlutter(channel: channel, message: "\(fileName) is playing in loop.")
        } catch {
            sendLogToFlutter(channel: channel, message: "Failed to play audio: \(error)")
        }
    }

    // Pause the audio if it's playing
    private func pauseAudio(channel: FlutterMethodChannel?) {
        if isAudioPlaying {
            audioPlayer?.pause()
            isAudioPlaying = false
            sendLogToFlutter(channel: channel, message: "Audio paused.")
        } else {
            sendLogToFlutter(channel: channel, message: "No audio is playing.")
        }
    }

    // Helper function to send logs to Flutter
    private func sendLogToFlutter(channel: FlutterMethodChannel?, message: String) {
        guard let channel = channel else {
            return
        }
        // Send the log message to Flutter
        channel.invokeMethod("logMessage", arguments: message)
    }
}
