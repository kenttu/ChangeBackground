//
//  EditViewController.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/12/24.
//

import Foundation
import UIKit
import Combine

class EditViewController: UIViewController {
    @IBOutlet var subjectImageView: DraggableZoomableImageView!
    var mainViewModel: MainViewModel?
    
    private var viewModel = EditViewModel()
    private var eraseMaskView: MaskingView?
    private var cancellable: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeViewModel()
        setupSubjectView()
        setupEraseMaskView()
    }
    
    @IBAction func rotateSubjectImage(_ sender: UIButton) {
        subjectImageView.image = subjectImageView.image?.rotated(by: 90)
    }
    
    @IBAction func undoEditSubjectImage(_ sender: UIButton) {
        viewModel.undoForegroundImageEdit()
    }

    
    @IBAction func cancelButtonPress() {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneButtonPress() {
        mainViewModel?.foregroundImage = viewModel.foregroundImage
        self.dismiss(animated: true)
    }
}

extension EditViewController {
    private func setupSubjectView() {
        guard let mainViewModel, let foregroundImage =  mainViewModel.foregroundImage else {
            self.presentErrorAlert(message: "Subject image has not been selected.")
            return
        }
        subjectImageView.image = foregroundImage
        subjectImageView.contentMode = .scaleAspectFit
        viewModel.foregroundImageDidChange(foregroundImage)
    }
    
    private func setupEraseMaskView() {
        eraseMaskView = MaskingView(imageView: self.subjectImageView)
        guard let eraseMaskView else {
            self.presentErrorAlert(message: "Unable to process current image.")
            return
        }
        eraseMaskView.isUserInteractionEnabled = true
        eraseMaskView.didUpdate = { [weak self] newImage in
            guard let self else {
                return
            }
            self.viewModel.foregroundImageDidChange(newImage)
        }
        subjectImageView.addSubview(eraseMaskView)
    }

    private func observeViewModel() {
        viewModel.$foregroundImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                if let image {
                    self?.subjectImageView.image = image
                }
            }
            .store(in: &cancellable)        
    }

}
