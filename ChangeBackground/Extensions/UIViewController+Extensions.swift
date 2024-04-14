//
//  UIViewController+Helper.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/13/24.
//

import UIKit

// MARK: - UIViewController Extension for presenting error alerts
extension UIViewController {
    
    /// Presents an error alert with a default title "Error" and an OK button.
    /// - Parameter message: The error message to display.
    func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
}
