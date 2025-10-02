//
//  ScrollingVC.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-09-30.
//

import Combine
import UIKit

class ScrollingVC: UIViewController {

	// MARK: IBOutlets
	@IBOutlet internal var indexLabel: UILabel!

	// MARK: our various subviews & frames
	internal var currentVideo: CBVideoView?
	internal var offscreenVideo: CBVideoView?
	internal var currentVideoFrame: CGRect = .zero
	internal var topVideoFrame: CGRect = .zero
	internal var bottomVideoFrame: CGRect = .zero

	// MARK: private variables
	private var videoUrls: [String] = []
	private var subscriptions: [AnyCancellable] = []

	private var currentVideos: [String] = []
	private var currentVideoIndex: Int = 0

	// MARK: life-cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setupControls()
		setupVideoViews()
		setupSubscriptions()
		Services.downloadVideos()
	}
}

// MARK: - Private methods
private extension ScrollingVC {

	func setupSubscriptions() {

		guard subscriptions.isEmpty else { return }

		Services.api.videoUrls
			.sink(
				receiveCompletion: { _ in
			}, receiveValue: {  [weak self] videos in
				self?.videoUrls = videos
				self?.redoVideos()
				self?.updateLabels()
			})
			.store(in: &subscriptions)
	}

	func setupControls() {
		// let's make out label somewhat nice
		indexLabel.layer.cornerRadius = 8
		indexLabel.clipsToBounds = true
		indexLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
	}

	func setupVideoViews() {
		let viewSize = view.frame.size

		// now create our views on top of one another
		topVideoFrame = CGRect(x: 0, y: -viewSize.height, width: viewSize.width, height: viewSize.height)
		currentVideoFrame = CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
		bottomVideoFrame = CGRect(x: 0, y: viewSize.height, width: viewSize.width, height: viewSize.height)

		let currentVideoView = CBVideoView(frame: currentVideoFrame)
		view.addSubview(currentVideoView)
		currentVideo = currentVideoView

		let bottomVideoView = CBVideoView(frame: bottomVideoFrame)
		view.addSubview(bottomVideoView)
		offscreenVideo = bottomVideoView
	}

	func redoVideos() {
		guard !videoUrls.isEmpty else { return }

		// add 2 entries to our video list (ie, currentVideos)
		currentVideos.append(videoUrls[Int.random(in: 0..<videoUrls.count)])
		currentVideos.append(videoUrls[Int.random(in: 0..<videoUrls.count)])
		guard currentVideos.count == 2 else { return }

		// only need to set our 1st & 2nd videos
		currentVideoIndex = 0
		currentVideo?.urlString = currentVideos[0]
		offscreenVideo?.urlString = currentVideos[1]
	}

	func updateLabels() {
		indexLabel.text = "\(currentVideoIndex + 1)"
		view.bringSubviewToFront(indexLabel)
	}
}

// MARK: - IBActions/Gestures
private extension ScrollingVC {

	@IBAction func scrollUp(_ sender: Any) {
		guard currentVideoIndex < videoUrls.count - 1 else { return }
		// check if we're at the very end and if so, add another... since we're INFINITE
		if currentVideoIndex == currentVideos.count - 1 {
			currentVideos.append(videoUrls[Int.random(in: 0..<videoUrls.count)])
		}

		guard currentVideoIndex < currentVideos.count - 1 else { return }

		let nextIndex = currentVideoIndex + 1
		guard nextIndex < currentVideos.count else { return }

		// make our offscreen video the next one and then animate (scroll) up
		offscreenVideo?.urlString = currentVideos[nextIndex]
		offscreenVideo?.frame = bottomVideoFrame

		UIView.animate(
			withDuration: 0.20,
			animations: {
				self.currentVideo?.frame = self.topVideoFrame
				self.offscreenVideo?.frame = self.currentVideoFrame
			},
			completion: { _ in
				self.currentVideoIndex = nextIndex
				let tempVideo = self.currentVideo
				self.currentVideo = self.offscreenVideo
				self.offscreenVideo = tempVideo
				self.updateLabels()
			}
		)
	}

	@IBAction func scrollDown(_ sender: Any) {
		guard currentVideoIndex > 0 else { return }

		let previousIndex = currentVideoIndex - 1

		// make our offscreen video the next one and then animate (scroll) up
		offscreenVideo?.urlString = currentVideos[previousIndex]
		offscreenVideo?.frame = topVideoFrame

		UIView.animate(
			withDuration: 0.20,
			animations: {
				self.currentVideo?.frame = self.bottomVideoFrame
				self.offscreenVideo?.frame = self.currentVideoFrame
			},
			completion: { _ in
				self.currentVideoIndex = previousIndex
				let tempVideo = self.currentVideo
				self.currentVideo = self.offscreenVideo
				self.offscreenVideo = tempVideo
				self.updateLabels()
			}
		)
	}

	@IBAction func tapGesture(_ sender: Any) {
		guard let currentVideo else { return }

		currentVideo.toggle()
	}
}

