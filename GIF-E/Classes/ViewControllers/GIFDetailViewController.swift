//
//  GIFDetailViewController.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import UIKit
import Photos
import SwiftyGif

class GIFDetailViewController: UIViewController {
    
    let gif: GIF
    let placeholder: UIImage?
    let imageView = UIImageView()
    
    init(gif: GIF, placeholder: UIImage? = nil) {
        self.gif = gif
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = gif.title
        
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.frame = view.bounds
        imageView.delegate = self
        
        if let image = placeholder {
            imageView.setGifImage(image)
        }
        
        imageView.setGifFromURL(gif.images.original.url, levelOfIntegrity: .highestNoFrameSkipping, showLoader: true)
    }
    
    func setUpBarItems() {
        guard imageView.gifImage?.imageData != nil else { return }
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(save))
        ]
    }
    
    // MARK: - actions -
    
    @objc func save() {
        guard let imageData = imageView.gifImage?.imageData else {
            return
        }
        
        let alertController = UIAlertController(
            title: "Share",
            message: "How would you like to share this GIF?",
            preferredStyle: .actionSheet
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Save Image",
                style: .default,
                handler: { _ in
                    
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetCreationRequest.forAsset()
                        request.addResource(with: .photo, data: imageData, options: nil)
                    }) { (success, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("GIF has saved")
                        }
                    }
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Copy",
                style: .default,
                handler: { _ in
                    UIPasteboard.general.setData(imageData, forPasteboardType: "com.compuserve.gif")
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        present(alertController, animated: true, completion: nil)
    }
}

extension GIFDetailViewController: SwiftyGifDelegate {
    func gifURLDidFinish(sender: UIImageView) {
        setUpBarItems()
    }
}
