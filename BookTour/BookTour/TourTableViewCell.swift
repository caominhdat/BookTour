import UIKit

class TourCell: UITableViewCell {
    
    let tourImageView = UIImageView()
    let tourNameLabel = UILabel()
    let tourPriceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(tourImageView)
        contentView.addSubview(tourNameLabel)
        contentView.addSubview(tourPriceLabel)
        // Set layout cho các thành phần trong cell ở đây
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tour: Tour) {
        tourNameLabel.text = tour.tenTour
        tourPriceLabel.text = tour.giaTour
        
        if let url = URL(string: tour.hinhTour) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.tourImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}

