import AVFoundation

@MainActor
final class CelebrationSoundPlayer {
    private let playbackVolume: Float = 0.55
    private var audioPlayer: AVAudioPlayer?
    private var fadeOutTask: Task<Void, Never>?

    private var isPlaying: Bool {
        audioPlayer?.isPlaying == true
    }

    init() {
        audioPlayer = Self.makeAudioPlayer()
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.volume = playbackVolume
        audioPlayer?.prepareToPlay()
    }

    func play() {
        fadeOutTask?.cancel()
        fadeOutTask = nil

        guard let audioPlayer else { return }

        audioPlayer.volume = playbackVolume

        if !audioPlayer.isPlaying {
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }
    }

    func stop() {
        guard let audioPlayer, isPlaying else { return }

        fadeOutTask?.cancel()
        let startingVolume = audioPlayer.volume
        let steps = 24
        let stepDurationNanoseconds: UInt64 = 30_000_000

        fadeOutTask = Task { @MainActor [weak self, weak audioPlayer] in
            guard let self, let audioPlayer else { return }

            for step in 1...steps {
                if Task.isCancelled { return }

                let progress = Float(step) / Float(steps)
                audioPlayer.volume = startingVolume * (1 - progress)

                do {
                    try await Task.sleep(nanoseconds: stepDurationNanoseconds)
                } catch {
                    return
                }
            }

            audioPlayer.stop()
            audioPlayer.currentTime = 0
            audioPlayer.volume = playbackVolume
            fadeOutTask = nil
        }
    }

    private static func makeAudioPlayer() -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "pixie", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "pixie", withExtension: "mp3", subdirectory: "Data")
        else {
            return nil
        }

        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            return nil
        }
    }
}
