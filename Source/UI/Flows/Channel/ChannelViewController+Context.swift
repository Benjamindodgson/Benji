//
//  ChannelViewController+Context.swift
//  Benji
//
//  Created by Benji Dodgson on 7/3/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelViewController: UIImagePickerControllerDelegate {
    
    func showCameraOptions() {
        let alertVC = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)

        let action1 = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerVC.sourceType = .camera
            self.present(self.imagePickerVC, animated: true, completion: nil)
        }

        let action2 = UIAlertAction(title: "Photos", style: .default) { (action) in
            self.imagePickerVC.sourceType = .photoLibrary
            self.present(self.imagePickerVC, animated: true, completion: nil)
        }

        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertVC.addAction(action1)
        alertVC.addAction(action2)
        alertVC.addAction(action3)

        self.present(alertVC, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.imagePickerVC.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }

        self.didSelect(image: selectedImage)
    }

    func didSelect(image: UIImage) {
        // send image as a message.
    }
}
