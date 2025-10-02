//
//  EditingVC.swift
//  hatchDemo
//
//  Created by Colin Biggin on 2025-09-30.
//

import UIKit

class EditingVC: UIViewController {

	// MARK: IBOutlets
	@IBOutlet internal var primaryTextField: CBExpandingTextView!

	// MARK: life-cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		// let's make the primaryTextField a bit more interesting
		primaryTextField.layer.cornerRadius = 8
		primaryTextField.layer.borderWidth = 1
		primaryTextField.layer.borderColor = UIColor.systemGray.cgColor
		primaryTextField.placeholderText = "Send message"
	}
}

// MARK: IBActions
extension EditingVC {
	@IBAction func toggleDismissKeyboard(_ sender: Any) {
		primaryTextField.resignFirstResponder()
	}
}
