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
    
    private var foregroundImage: UIImage?
    private var outputImage: UIImage?
    private var backgroundImage: UIImage?
    private var isBackgroundButtonPressed = false
    
    private var viewModel = MainViewModel()
    private var cancellable: Set<AnyCancellable> = []
    private let backgroundImages = ["background-1", "background-2", "background-3", "background-4", "background-5", "background-5", "background-6"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        observeViewModel()
        
        backgroundCollectionView.delegate = self
        backgroundCollectionView.dataSource = self
        backgroundCollectionView.backgroundColor = .clear
        backgroundCollectionView.register(UINib(nibName: "BackgroundCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundCollectionViewCell")
        
        if let layout = backgroundCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    private func observeViewModel() {
        viewModel.$foregroundImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.subjectImageView.image = image
            }
            .store(in: &cancellable)
        
        viewModel.shareImage = { [weak self] image in
            if let image {
                self?.presentShareViewController(image)
            }
        }
    }
    
    @IBAction func backgroundButtonPressed() {
        isBackgroundButtonPressed = true
        showImagePicker()
    }
    
    @IBAction func subjectButtonPressed() {
        isBackgroundButtonPressed = false
        showImagePicker()
    }
        
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        viewModel.handleShareButtonTapped(self.subjectImageView.superview!)
    }
    
    @IBAction func rotateSubjectImage(_ sender: UIButton) {
        subjectImageView.image = subjectImageView.image?.rotated(by: 90)
        
    }

}

extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        if isBackgroundButtonPressed {
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
        
        // If you're using an iPad, you need to provide an anchor point for the popover (e.g., a button or a view)
        if let popoverController = activityViewController.popoverPresentationController {
            // Configure the anchor point here
            popoverController.sourceView = self.view // The view containing the anchor
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Or an actual button/frame
            popoverController.permittedArrowDirections = [] // Adjust if needed
        }
        
        // Present the activity view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgroundImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCollectionViewCell", for: indexPath) as! BackgroundCollectionViewCell
        let imageName = backgroundImages[indexPath.item]
        cell.imageView.image = UIImage(named: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = backgroundImages[indexPath.item]
        backgroundImageView.image = UIImage(named: imageName)
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}
