//
//  LoadingIndicator.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/11/24.
//

import Foundation

import UIKit

class LoadingIndicator {
    static let shared = LoadingIndicator()
    private var loadingView: UIView?
    
    // Prevent external instantiation
    private init() {}
    
    func show(over view:UIView) {
        DispatchQueue.main.async {[weak self] in
            guard let self else {
                return
            }
            let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            loadingView.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
            loadingView.layer.cornerRadius = 10
            loadingView.center = view.center
            view.addSubview(loadingView)
            let activityIndicator = UIActivityIndicatorView(style: .large)
            loadingView.addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY)
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            self.loadingView = loadingView
        }
    }
    
    func hide() {
        DispatchQueue.main.async {[weak self] in
            guard let self, let loadingView = self.loadingView else {
                return
            }
            loadingView.removeFromSuperview()
        }
    }

}
