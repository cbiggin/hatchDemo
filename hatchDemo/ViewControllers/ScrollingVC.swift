//
//  ScrollingVC.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-09-30.
//

import UIKit

class ScrollingVC: UIViewController {

	// MARK: IBOutlets
	@IBOutlet internal var tableView: UITableView!

	// MARK: private variables
	private var videoUrls: [String] = []

	// MARK: life-cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.isPagingEnabled = true

		Task { await self.downloadVideos() }
	}
}

// MARK: UITableViewDelegate
extension ScrollingVC: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let videoCell = tableView.cellForRow(at: indexPath) as? CBVideoCell else { return }

		videoCell.toggle()
	}
}

// MARK: UITableViewDataSource
extension ScrollingVC: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return videoUrls.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		// dequeue it a re-assign it's url string
		let cell = tableView.dequeueReusableCell(withIdentifier: CBVideoCell.reuseIdentifier, for: indexPath) as! CBVideoCell
		cell.urlString = videoUrls[indexPath.row]

		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		// always make it the height of tableview, ie, we want it to fill the screen
		return tableView.frame.height
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
		tableView.reloadData()
	}
}
