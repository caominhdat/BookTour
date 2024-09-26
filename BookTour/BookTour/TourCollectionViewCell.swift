//
//  TourCollectionViewCell.swift
//  BookTour
//
//  Created by Cao Đạt on 16/09/2024.
//

import UIKit


class TourCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TourCollectionViewCell"
    
    private let tenTourLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let thoiGianTourLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let giaTourLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .red
        return label
    }()
    
    private let hinhTourImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(hinhTourImageView)
        contentView.addSubview(tenTourLabel)
        contentView.addSubview(thoiGianTourLabel)
        contentView.addSubview(giaTourLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hinhTourImageView.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        tenTourLabel.frame = CGRect(x: 100, y: 10, width: contentView.frame.size.width - 110, height: 40)
        thoiGianTourLabel.frame = CGRect(x: 100, y: 35, width: contentView.frame.size.width - 110, height: 30)
        giaTourLabel.frame = CGRect(x: 100, y: 60, width: contentView.frame.size.width - 110, height: 20)
    }
    
    public func configure(with tour: Tour) {
        tenTourLabel.text = tour.tenTour
        thoiGianTourLabel.text = tour.thoiGianTour
        giaTourLabel.text = tour.giaTour
        
        // Kiểm tra nếu URL hợp lệ
        if let url = URL(string: tour.hinhTour) {
            hinhTourImageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
        } else {
            hinhTourImageView.image = UIImage(named: "placeholder") // Đặt hình mặc định nếu URL không hợp lệ
        }
    }

}

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage?) {
        self.image = placeholder
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }
}

