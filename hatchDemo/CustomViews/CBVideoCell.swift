//
//  CBVideoCell.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-10-01.
//

import AVFoundation
import UIKit

final class CBVideoCell: UITableViewCell {

	// MARK: statics
	static let reuseIdentifier = "CBVideoCell"

	// MARK: settable variables
	public var urlString: String = "" {
		didSet {
			configure(with: urlString)
		}
	}
	public var autoPlay: Bool = true
	public var loopVideo: Bool = true

	private var player: AVPlayer?
	private var playerLayer: AVPlayerLayer?

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		selectionStyle = .none
		backgroundColor = .black
		contentView.clipsToBounds = true
	}

	// MARK: - Layout
	override func layoutSubviews() {
		super.layoutSubviews()
		playerLayer?.frame = contentView.bounds
	}

	// MARK: - Reuse
	override func prepareForReuse() {
		super.prepareForReuse()
		cleanupPlayer()
	}

	private func cleanupPlayer() {
		NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
		player?.pause()
		playerLayer?.removeFromSuperlayer()
		player = nil
		playerLayer = nil

		// make sure nothing being notified
		NotificationCenter.default.removeObserver(self)
	}

	deinit {
		player = nil
		playerLayer = nil
		NotificationCenter.default.removeObserver(self)
	}

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

		contentView.layer.addSublayer(layer)

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

extension CBVideoCell {

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
