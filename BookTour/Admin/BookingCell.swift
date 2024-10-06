import UIKit

class BookingCell: UITableViewCell {
    
    let tourNameLabel = UILabel()
    let bookingDateLabel = UILabel()
    let totalPriceLabel = UILabel()
    let emailLabel = UILabel()
    let phoneLabel = UILabel()
    let itemsStackView = UIStackView() // Stack view cho các trường trong items
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        tourNameLabel.font = UIFont.boldSystemFont(ofSize: 16) // Chữ in đậm cho tên tour
        bookingDateLabel.font = UIFont.systemFont(ofSize: 14) // Font size cho ngày đặt
        totalPriceLabel.font = UIFont.systemFont(ofSize: 14) // Font size cho tổng tiền
        totalPriceLabel.textColor = UIColor.systemRed
        emailLabel.font = UIFont.systemFont(ofSize: 14) // Font size cho email
        phoneLabel.font = UIFont.systemFont(ofSize: 14) // Font size cho số điện thoại
        
        // Cấu hình stackView cho items
        itemsStackView.axis = .vertical
        itemsStackView.spacing = 5
        
        let stackView = UIStackView(arrangedSubviews: [tourNameLabel, bookingDateLabel, totalPriceLabel, emailLabel, phoneLabel, itemsStackView])
        stackView.axis = .vertical
        stackView.spacing = 5
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with booking: Booking) {
        // Hiển thị tên tour
        if let firstItem = booking.items.first, let tourName = firstItem["tenTour"] as? String {
            tourNameLabel.text = "Tour: \(tourName)"
        } else {
            tourNameLabel.text = "Tour: N/A"
        }

        // Hiển thị ngày đặt tour
        if let date = booking.bookingDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            bookingDateLabel.text = "Ngày đặt: \(dateFormatter.string(from: date))"
        } else {
            bookingDateLabel.text = "Ngày đặt: N/A"
        }
        
        // Hiển thị tổng tiền
        totalPriceLabel.text = "Tổng tiền: \(booking.totalPrice) VND"

        // Hiển thị email
        emailLabel.text = "Email: \(booking.email)"

        // Hiển thị số điện thoại
        phoneLabel.text = "Số điện thoại: \(booking.phone)"
        
        // Xóa tất cả subviews trong itemsStackView trước khi thêm mới
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Hiển thị thông tin từng trường trong items
        for item in booking.items {
            if let soLuong = item["soLuong"] as? Int {
                let soLuongLabel = UILabel()
                soLuongLabel.font = UIFont.systemFont(ofSize: 14) // Kích cỡ font cho số lượng
                soLuongLabel.text = "Số lượng: \(soLuong)"
                itemsStackView.addArrangedSubview(soLuongLabel) // Thêm số lượng vào stackView
            }
            
            if let giaTour = item["giaTour"] as? String {
                let giaTourLabel = UILabel()
                giaTourLabel.font = UIFont.systemFont(ofSize: 14) // Kích cỡ font cho giá tour
                giaTourLabel.text = "Giá tour: \(giaTour)"
                itemsStackView.addArrangedSubview(giaTourLabel) // Thêm giá tour vào stackView
            }
        }
    }
}

