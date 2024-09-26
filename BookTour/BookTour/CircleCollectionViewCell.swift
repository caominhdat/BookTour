//
//  CircleCollectionViewCell.swift
//  BookTour
//
//  Created by Cao Đạt on 15/09/2024.
//

import UIKit

class CircleCollectionViewCell: UICollectionViewCell {
 
    static let identifier = "CircleCollectionViewCell"
    
    private let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 90.0/2.0
        imageView.backgroundColor = .blue
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.link.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(myImageView)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myImageView.frame = contentView.bounds
        nameLabel.frame = CGRect(x: 0, y: contentView.frame.size.width - 10, width: contentView.frame.size.width, height: 40)
    }
    
    public func configure(with name: String) {
        myImageView.image = UIImage(named: name)
        nameLabel.text = name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.image = nil
        nameLabel.text = nil
    }
    
}
