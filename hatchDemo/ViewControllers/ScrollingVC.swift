//
//  ScrollingVC.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-09-30.
//

import UIKit

class ScrollingVC: UIViewController {

	private var videoUrls: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		Task { await self.downloadVideos() }
	}
}

// MARK: IBActions
extension ScrollingVC {

	private func downloadVideos() async {
		let api = API()
		do {
			let videos = try await api.downloadManifest("https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/manifest.json")
			videoUrls = videos
			redoTableView()
		} catch {
			print("Failed to download manifest: \(error)")
		}
	}

	private func redoTableView() {
		// coming soon
	}

}

