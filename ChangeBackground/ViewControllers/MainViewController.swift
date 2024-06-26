//
//  MainViewController.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/15/24.
//

import UIKit
import Vision
import Combine
import Photos

class MainViewController: UIViewController {
    @IBOutlet var backgroundImageView: DraggableZoomableImageView!
    @IBOutlet var subjectImageView: DraggableZoomableImageView!
    @IBOutlet var backgroundButton: UIButton!
    @IBOutlet var subjectButton: UIButton!
    @IBOutlet var backgroundCollectionView: UICollectionView!
    @IBOutlet var backgroundControlView: UIView!
    @IBOutlet var subjectControlView: UIView!
    @IBOutlet var undoEditButton: UIButton!
    
    private var eraseMaskView: MaskingView?
    private var viewModel = MainViewModel()
    private var cancellable: Set<AnyCancellable> = []
    private var backgroundImagesDataSource: BackgroundImagesDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControlViews()
        observeViewModel()
        setupBackgroundCollectionView()
    }
    
    private func observeViewModel() {
        viewModel.$foregroundImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                if let image {
                    self?.subjectImageView.isHidden = false
                    self?.subjectImageView.image = image
                }
            }
            .store(in: &cancellable)
        
        viewModel.shareImage = { [weak self] image in
            if let image {
                self?.presentShareViewController(image)
            }
        }
    }
    
    @IBAction func backgroundButtonPressed() {
        self.selectControlViews(.backgroundControlView)
        showImagePicker()
    }
    
    @IBAction func subjectButtonPressed() {
        self.selectControlViews(.subjectControlView)
        guard let _ = viewModel.foregroundImage else {
            showImagePicker()
            return
        }
    }
        
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        viewModel.handleShareButtonTapped(self.subjectImageView.superview!)
    }
    
    @IBAction func rotateSubjectImage(_ sender: UIButton) {
        subjectImageView.image = subjectImageView.image?.rotated(by: 90)
        
    }
    
    @IBAction func editSwitchChanged(_ sender: UISwitch) {        
        if sender.isOn {
            enableEraseMaskView()
        } else {
            disableEraseMaskView()
        }
    }
    
    @IBAction func undoEditSubjectImage(_ sender: UIButton) {
        viewModel.undoForegroundImageEdit()
    }
}

extension MainViewController {
    enum ControlViews {
        case backgroundControlView
        case subjectControlView
    }
    
    func selectControlViews(_ controlView: ControlViews) {
        switch controlView {
        case .backgroundControlView:
            backgroundButton.isSelected = true
            subjectButton.isSelected = false
        case .subjectControlView:
            subjectButton.isSelected = true
            backgroundButton.isSelected = false
        }
        
        backgroundControlView.isHidden = !backgroundButton.isSelected
        subjectControlView.isHidden = !subjectButton.isSelected
    }
    
    func setupControlViews() {
        self.selectControlViews(.backgroundControlView)
        self.subjectImageView.isHidden = true
        self.subjectImageView.contentMode = .scaleAspectFit
        self.backgroundImageView.contentMode = .scaleToFill
    }
}

extension MainViewController {
    func setupBackgroundCollectionView() {
        backgroundImagesDataSource = BackgroundImagesDataSource(imageView: self.backgroundImageView)
        backgroundCollectionView.dataSource = backgroundImagesDataSource
        backgroundCollectionView.delegate = backgroundImagesDataSource
        
        if let layout = backgroundCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
}

extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }
        
        LoadingIndicator.shared.show(over: self.view)
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true) {
            LoadingIndicator.shared.hide()
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        if backgroundButton.isSelected {
            backgroundImageView.image = selectedImage
        }
        else {
            viewModel.subjectImageSelected(selectedImage)
        }
        picker.dismiss(animated: true)
    }

}

extension MainViewController {
    func presentShareViewController(_ image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // Present the activity view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension MainViewController {
    private func enableEraseMaskView() {
        eraseMaskView = MaskingView(imageView: self.subjectImageView)
        guard let eraseMaskView else { return }
        eraseMaskView.isUserInteractionEnabled = true
        eraseMaskView.didUpdate = { [weak self] newImage in
            guard let self else {
                return
            }
            self.viewModel.foregroundImageDidChange(newImage)
        }
        backgroundImageView.isHidden = true
        undoEditButton.isHidden = false
        subjectImageView.addSubview(eraseMaskView)
    }

    private func disableEraseMaskView() {
        backgroundImageView.isHidden = false
        undoEditButton.isHidden = true
        eraseMaskView?.removeFromSuperview()
        eraseMaskView = nil
    }
}
