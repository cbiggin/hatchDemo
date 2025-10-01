//
//  Services.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-10-01.
//

private var sharedInstance: Services = Services()

public class Services {

	private var api = API()

	public init() {
	}
}

// MARK: API
extension Services {
	public static var api: API {
		return sharedInstance.api
	}

	public static func downloadVideos() {
		Task {
			let _ = try await Services.api.downloadManifest("https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/manifest.json")
		}
	}

}



