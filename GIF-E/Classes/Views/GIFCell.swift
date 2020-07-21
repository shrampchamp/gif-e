//
//  GIFCell.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import UIKit
import SwiftyGif

class GIFCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.stopAnimatingGif()
        SwiftyGifManager.defaultManager.deleteImageView(imageView)
        imageView.image = nil
    }
}
