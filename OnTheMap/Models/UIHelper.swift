//
//  UIHelper.swift
//  OnTheMap
//
//  Created by Shannon on 6/9/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import Foundation
import UIKit

struct UIHelper {
    static let loadingSpinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
}

extension UIColor {
    func udacityBlue () -> UIColor {
        return #colorLiteral(red: 0, green: 0.7098039216, blue: 0.8901960784, alpha: 1)
    }
}

extension UIViewController {
    
    func showAlert (message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Something Went Wrong", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog(message)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showLoadingSpinner (_ show: Bool) {
        DispatchQueue.main.async{
            let loadingSpinner = UIHelper.loadingSpinner
            loadingSpinner.alpha = 1
            loadingSpinner.color = .gray
            loadingSpinner.backgroundColor = .white
            loadingSpinner.center = self.view.center
            switch show {
            case true:
                loadingSpinner.startAnimating()
                self.view.addSubview(loadingSpinner)
                self.view.isUserInteractionEnabled = false
            case false:
                loadingSpinner.stopAnimating()
                self.view.willRemoveSubview(loadingSpinner)
                self.view.isUserInteractionEnabled = true
            }
        }
    }
}
