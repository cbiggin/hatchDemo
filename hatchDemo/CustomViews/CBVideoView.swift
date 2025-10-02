//
//  CBVideoView.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-10-02.
//

import AVFoundation
import UIKit

final class CBVideoView: UIView {

    // MARK: - Settable variables
    public var urlString: String = "" {
        didSet {
            configure(with: urlString)
        }
    }
    public var autoPlay: Bool = true
    public var loopVideo: Bool = true

    // MARK: - Private
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .black
        clipsToBounds = true
		isUserInteractionEnabled = false
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    // MARK: - Cleanup
    private func cleanupPlayer() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil

        // Ensure nothing else is notifying
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        cleanupPlayer()
    }

    // MARK: - Configuration
    func configure(with urlString: String) {

		// Clean up any previous player/layer before reconfiguring
        cleanupPlayer()

        guard let url = URL(string: urlString) else {
            return
        }

        let player = AVPlayer(url: url)
        player.automaticallyWaitsToMinimizeStalling = true

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill

        self.layer.addSublayer(layer)

        self.player = player
        self.playerLayer = layer

        if autoPlay {
            player.play()
        }

        // need to be notified if looping
        if loopVideo {
            player.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
        setNeedsLayout()
    }

    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        guard let player else { return }
        guard loopVideo else { return }

        player.seek(to: .zero)
        if autoPlay {
            player.play()
        }
    }
}

// MARK: - Controls
extension CBVideoView {

    public var isPlaying: Bool {
        return player?.timeControlStatus == .playing ? true : false
    }

    public func toggle() {
        isPlaying ? pause() : play()
    }

    public func play() {
        player?.play()
    }

    public func pause() {
        player?.pause()
    }
}
