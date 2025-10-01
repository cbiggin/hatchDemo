//
//  API.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-10-01.
//

import Foundation

let blah = "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/manifest.json"

public struct APIServerError: Error, CustomStringConvertible {

	public enum ErrorKind: Int {
		case invalidURLSession          = 17400
		case invalidURL                 = 17401
		case invalidHTTPResponse        = 17402
		case invalidData                = 17403
		case errorDownloadingManifest   = 17404
	}

	public let kind: ErrorKind
	public let message: String?
	public let errorCode: Int?
	public let file: String
	public let function: String
	public let line: Int

	// MARK: CustomStringConvertible
	public var description: String {
		var str = ""
		switch self.kind {
			case .invalidURLSession: str = ".invalidURLSession"
			case .invalidURL: str = ".invalidURL"
			case .invalidHTTPResponse: str = ".invalidHTTPResponse"
			case .invalidData: str = ".invalidData"
			case .errorDownloadingManifest: str = ".errorDownloadingManifest"
		}

		// no matter what, tack on our "raw value"
		str += " (\(kind.rawValue))"

		if let message = self.message {
			str += ", message: \(message)"
		}
		if let errorCode = self.errorCode {
			str += ", error Code: \(errorCode)"
		}

		// append the internal info
		return str + " (#file: \(file), #function: \(function), #line: \(line))"
	}

	// MARK: init()
	public init(kind: ErrorKind, message: String? = nil, errorCode: Int? = nil, file: String = #file, function: String = #function, line: Int = #line) {
		self.kind = kind
		self.message = message
		self.errorCode = errorCode

		// fill these automagically
		if let fname = file.components(separatedBy: "/").last {
			self.file = fname
		} else {
			self.file = file
		}
		self.function = function
		self.line = line
	}

	public init(_ kind: ErrorKind, message: String? = nil, errorCode: Int? = nil, file: String = #file, function: String = #function, line: Int = #line) {
		self.init(kind: kind, file: file, function: function, line: line)
	}
}

// MARK: -
public class API {

	public private(set) var urlString: String = ""
	public private(set) var videoUrls: [String] = []

	// MARK: private variables
	private var session: URLSession?

	init() {
		let sessionConfig = URLSessionConfiguration.default
		self.session = URLSession(configuration: sessionConfig)
	}

	deinit {
		videoUrls.removeAll()
	}

	public func reset() {
		videoUrls.removeAll()
	}

	public func downloadManifest(_ url: String) async throws -> [String] {

		// have we already download it? if so, just return
		guard videoUrls.isEmpty else { return videoUrls }

		guard let session else { throw APIServerError(kind: .invalidURLSession) }
		guard let manifestURL = URL(string: url) else { throw APIServerError(kind: .invalidURL) }

		do {
			let (data, response) = try await session.data(from: manifestURL)
			guard let httpResponse = response as? HTTPURLResponse else { throw APIServerError(kind: .invalidHTTPResponse) }
			guard httpResponse.statusSuccessful else { throw APIServerError(kind: .invalidHTTPResponse, errorCode: httpResponse.statusCode) }

			do {
				let decoder = JSONDecoder()
				let payload = try decoder.decode(ManifestPayload.self, from: data)

				// make sure we actually have some videos
				guard !payload.videos.isEmpty else { throw APIServerError(kind: .invalidData) }

				// save the... JUST in case
				videoUrls = payload.videos

				return payload.videos
			} catch {
				throw APIServerError(kind: .errorDownloadingManifest)
			}

		} catch {
			// no matter what, there was something wrong with download the configFile and that's "game over man"
			throw APIServerError(kind: .errorDownloadingManifest)
		}
	}

}

// MARK: -
private extension HTTPURLResponse {
	var statusSuccessful: Bool {
		switch statusCode {
		case 200, 201, 202, 204: return true
		default: return false
		}
	}
}

// MARK: -
private extension Data {
	func decodedText() -> String? {
		var str: String?

		if let tmpString = String(data: self, encoding: .utf8) {
			str = tmpString
		} else if let tmpString = String(data: self, encoding: .ascii) {
			str = tmpString
		}

		return str
	}
}
