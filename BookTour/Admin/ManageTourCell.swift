//
//  ManageTourCell.swift
//  BookTour
//
//  Created by Cao Đạt on 02/10/2024.
//

import UIKit

class ManageTourCell: UICollectionViewCell {
    let imageView: UIImageView = {
            let img = UIImageView()
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            return img
        }()

        let nameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textAlignment = .center
            return label
        }()

        let priceLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            return label
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(imageView)
            contentView.addSubview(nameLabel)
            contentView.addSubview(priceLabel)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            priceLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: 150),

                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

                priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
                priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(with tour: TourModel) {
            nameLabel.text = tour.tenTour
            priceLabel.text = "Giá: \(tour.giaTour)"
            
            // Tải hình ảnh từ URL
            if let url = URL(string: tour.hinhTour) {
                downloadImage(from: url)
            } else {
                imageView.image = nil // Hoặc hình ảnh mặc định nếu URL không hợp lệ
            }
        }

        private func downloadImage(from url: URL) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error loading image: \(String(describing: error))")
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
}
