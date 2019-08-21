//
//  LoginProfilePhotoViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/12/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class LoginProfilePhotoViewController: ViewController {

    var didSavePhoto: () -> Void = {}
    private let avatarView = AvatarView()
    private let imagePickerVC = UIImagePickerController()
    private let doneButton = LoadingButton()

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .background3)
        self.view.addSubview(self.avatarView)
        self.avatarView.onTap { [unowned self] (tap) in
            self.present(self.imagePickerVC, animated: true, completion: nil)
        }
        self.view.addSubview(self.doneButton)
        self.doneButton.set(style: .normal(color: .blue, text: "DONE")) {
            guard let image = self.avatarView.imageView.image else { return }
            self.saveProfilePicture(image: image)
        }
        self.imagePickerVC.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.view.round(corners: [.topLeft, .topRight], size: CGSize(width: 10, height: 10))

        self.avatarView.size = CGSize(width: 200, height: 200)
        self.avatarView.top = 80
        self.avatarView.centerOnX()
        self.avatarView.makeRound()

        self.doneButton.size = CGSize(width: self.view.width - 28, height: 40)
        self.doneButton.top = self.avatarView.bottom + 40
        self.doneButton.centerOnX()
    }

    func pixelate(image: UIImage) {
        guard let currentCGImage = image.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(50, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return }

        let context = CIContext()

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.avatarView.set(avatar: processedImage)
        }
    }

    func saveProfilePicture(image: UIImage) {
        guard let imageData = image.pngData(), let current = PFUser.current() else { return }

        let imageFile = PFFileObject(name:"image.png", data: imageData)
        current["profilePicute"] = imageFile
        self.doneButton.isLoading = true
        current.saveInBackground { (success, error) in
            guard success else { return }
            self.didSavePhoto()
            self.doneButton.isLoading = false
        }
    }
}

extension LoginProfilePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.pixelate(image: pickedImage)
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
