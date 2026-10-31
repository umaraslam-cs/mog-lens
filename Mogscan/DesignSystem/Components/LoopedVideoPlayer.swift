import SwiftUI
import AVFoundation
import UIKit

/// A smooth, hardware-accelerated looping video player with speed control and aspect-fill scaling.
struct LoopedVideoPlayer: View {
    let resourceName: String
    var videoExtension: String = "mp4"
    var playbackRate: Float = 1.6

    var body: some View {
        VideoPlayerRepresentable(
            resourceName: resourceName,
            videoExtension: videoExtension,
            playbackRate: playbackRate
        )
    }
}

private struct VideoPlayerRepresentable: UIViewRepresentable {
    let resourceName: String
    let videoExtension: String
    let playbackRate: Float

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.setupPlayer(
            resourceName: resourceName,
            videoExtension: videoExtension,
            playbackRate: playbackRate
        )
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.updateRate(playbackRate)
    }
}

private final class PlayerContainerView: UIView {
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    private var targetRate: Float = 1.6

    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    func setupPlayer(resourceName: String, videoExtension: String, playbackRate: Float) {
        self.targetRate = playbackRate
        self.backgroundColor = .clear
        self.clipsToBounds = true

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: videoExtension) ??
                        Bundle.main.url(forResource: resourceName, withExtension: nil) else {
            return
        }

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        let player = AVQueuePlayer(playerItem: playerItem)
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false

        let looper = AVPlayerLooper(player: player, templateItem: playerItem)
        self.playerLooper = looper
        self.queuePlayer = player

        if let layer = self.layer as? AVPlayerLayer {
            layer.player = player
            layer.videoGravity = .resizeAspectFill
            self.playerLayer = layer
        }

        player.playImmediately(atRate: playbackRate)

        // Observe app foregrounding to resume playback smoothly
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resumePlayback),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func updateRate(_ rate: Float) {
        self.targetRate = rate
        queuePlayer?.rate = rate
    }

    @objc private func resumePlayback() {
        queuePlayer?.playImmediately(atRate: targetRate)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        queuePlayer?.pause()
        queuePlayer = nil
        playerLooper = nil
    }
}

#Preview {
    ZStack {
        AppBackground()
        LoopedVideoPlayer(resourceName: "technologysteps", playbackRate: 1.6)
            .frame(width: 320, height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    .preferredColorScheme(.dark)
}
