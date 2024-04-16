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
    @IBOutlet var imageContainerView: CheckerboardView!
    @IBOutlet var backgroundImageView: DraggableZoomableImageView!
    @IBOutlet var subjectImageView: DraggableZoomableImageView!
    @IBOutlet var backgroundButton: UIButton!
    @IBOutlet var subjectButton: UIButton!
    @IBOutlet var backgroundCollectionView: UICollectionView!
    @IBOutlet var backgroundControlView: UIView!
    
    private var viewModel = MainViewModel()
    private var cancellable: Set<AnyCancellable> = []
    private var backgroundImagesDataSource: BackgroundImagesDataSource?
    private var transitionManager = TransitionManager()

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
        LoadingIndicator.shared.show(over: self.view)
        viewModel.handleShareButtonTapped(self.subjectImageView.superview!)
    }
        
    @IBAction func editButtonTapped(_ sender: UIButton) {
        self.presentEditViewController()
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
    }
    
    func setupControlViews() {
        self.selectControlViews(.backgroundControlView)
        self.subjectImageView.isHidden = true
        self.subjectImageView.contentMode = .scaleAspectFit
        self.backgroundImageView.contentMode = .scaleAspectFill
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
    
    func presentEditViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let editViewController = storyboard.instantiateViewController(withIdentifier: "EditViewController") as? EditViewController else {
            return
        }
        editViewController.mainViewModel = viewModel
        
        guard let _ = editViewController.view,
              let sourceView = self.imageContainerView,
              let destinationView = editViewController.imageContainerView else {
            return
        }
        
        transitionManager.setupTransition(from: self, to: editViewController, usingSourceView: sourceView, andDestinationView: destinationView)

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
        self.present(activityViewController, animated: true) {
            LoadingIndicator.shared.hide()
        }
    }
}
