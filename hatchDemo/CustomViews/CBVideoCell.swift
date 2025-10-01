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

	public var urlString: String = "" {
		didSet {
			configure(with: urlString)
		}
	}

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
		player?.pause()
		playerLayer?.removeFromSuperlayer()
		player = nil
		playerLayer = nil
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

		player.play()

		setNeedsLayout()
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
