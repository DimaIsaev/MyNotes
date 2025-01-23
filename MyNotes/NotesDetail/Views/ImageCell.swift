//
//  ImageCell.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 24.01.2025.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    private lazy var cellImageView: UIImageView = makeCellImageView()
    
    func setCell(image: UIImage) {
        cellImageView.image = image
        setupLayout()
    }
    
}

// MARK: - UI Elements

private extension ImageCell {
    
    func setupLayout() {
        contentView.addSubview(cellImageView) //констрейнты не нужны?
    }
    
    func makeCellImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        return imageView
    }
    
}
