//
//  CBExpandingTextView.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-09-30.
//

import UIKit

class CBExpandingTextView: UITextView {

	// MARK: settable variables
	public var maxLines: Int = 5 {
		didSet {
			if maxLines < 1 {
				maxLines = 1
			} else if maxLines > 20 {
				maxLines = 20
			}
			updateFrame()
			setNeedsDisplay()
		}
	}

	public var placeholderText: String = "" {
		didSet {
			updateFrame()
			setNeedsDisplay()
		}
	}

	// MARK: overridden
	override var intrinsicContentSize: CGSize { return currentContentSize }

	// MARK: private
	private let defaultTextInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	private var singleLineHeight: CGFloat { ceil(font?.lineHeight ?? 12) }
	private var minHeight: CGFloat { singleLineHeight + defaultTextInsets.top + defaultTextInsets.bottom }
	private var maxHeight: CGFloat { singleLineHeight * CGFloat(max(1, maxLines)) + defaultTextInsets.top + defaultTextInsets.bottom }
	private var currentContentSize: CGSize = .zero

	private var placeholderTextColor = UIColor.lightGray
	private var nonplaceholderTextColor = UIColor.black

	// MARK: - initializers
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.initDefaults(frame: self.frame)
	}

	private func initDefaults(frame: CGRect) {
		self.backgroundColor = UIColor.clear
		self.clipsToBounds = true

		self.delegate = self
		self.isScrollEnabled = true
		self.textContainerInset = defaultTextInsets
		self.textContainer.lineFragmentPadding = 0
		self.alwaysBounceVertical = false
		self.keyboardDismissMode = .interactive

		// save these for later
		currentContentSize = CGSize(width: contentSize.width, height: minHeight)
		nonplaceholderTextColor = self.textColor ?? .black

		updateFrame()
	}
}

// MARK: -
private extension CBExpandingTextView {

	func updateFrame() {

		// ALWAYS check if we need to substitute the placeholder
		checkForPlaceholder()

		if maxHeight > contentSize.height {
			currentContentSize = contentSize
		} else {
			currentContentSize = CGSize(width: contentSize.width, height: maxHeight)
		}
		invalidateIntrinsicContentSize()
	}

	func checkForPlaceholder() {

		guard text.count == 0 else { return }

		textColor = placeholderTextColor
		text = placeholderText
		resignFirstResponder()
	}
}

// MARK: - UITextViewDelegate methods
extension CBExpandingTextView: UITextViewDelegate {
	public func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == placeholderText {
			text = ""
		}
		textColor = nonplaceholderTextColor
	}

	public func textViewDidChange(_ textView: UITextView) {
		updateFrame()
	}
}
