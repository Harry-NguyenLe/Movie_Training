//
//  CustomMediaMessageCell.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/27/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import MessageKit

class CustomMediaMessageCell: MediaMessageCell {
    
    open lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    open override func setupConstraints() {
        super.setupConstraints()
        progressView.constraint(equalTo: CGSize(width: 240, height: 3))
        progressView.centerInSuperview()
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(progressView)
        setupConstraints()
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        switch message.kind {
        case .photo(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = true
            progressView.isHidden = false
        default:
            break
        }
    }
}
