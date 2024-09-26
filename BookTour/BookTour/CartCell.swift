import UIKit

class CartCell: UITableViewCell {
    
    // ImageView để hiển thị hình ảnh của tour
    let tourImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Các nút tăng, giảm số lượng
    let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed // Màu đỏ cho nút giảm
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen // Màu xanh lá cho nút tăng
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Nhãn hiển thị số lượng sản phẩm
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "1" // Số lượng mặc định là 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Nhãn hiển thị tên tour
    let tourNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Nhãn hiển thị giá tiền
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .systemRed // Màu đỏ cho giá tiền
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Closure để xử lý khi số lượng thay đổi
    var onQuantityChange: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white // Màu nền trắng cho cell
        
        // Thêm các phần tử UI vào nội dung của cell
        contentView.addSubview(tourImageView)
        contentView.addSubview(decreaseButton)
        contentView.addSubview(increaseButton)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(tourNameLabel)
        contentView.addSubview(priceLabel)
        
        // Gán hành động khi bấm nút tăng/giảm số lượng
        decreaseButton.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)
        
        // Thiết lập layout cho các phần tử trong cell
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Hàm giảm số lượng khi bấm nút "-"
    @objc private func decreaseQuantity() {
        var currentQuantity = Int(quantityLabel.text ?? "0") ?? 0
        if currentQuantity > 1 {
            currentQuantity -= 1
            quantityLabel.text = "\(currentQuantity)"
            onQuantityChange?(currentQuantity) // Gọi closure khi số lượng thay đổi
        }
    }
    
    // Hàm tăng số lượng khi bấm nút "+"
    @objc private func increaseQuantity() {
        var currentQuantity = Int(quantityLabel.text ?? "0") ?? 0
        currentQuantity += 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChange?(currentQuantity) // Gọi closure khi số lượng thay đổi
    }
    
    // Thiết lập layout cho các phần tử trong cell
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ImageView hiển thị hình ảnh tour
            tourImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tourImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tourImageView.widthAnchor.constraint(equalToConstant: 80),
            tourImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Nút giảm số lượng
            decreaseButton.leadingAnchor.constraint(equalTo: tourImageView.trailingAnchor, constant: 20),
            decreaseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            decreaseButton.widthAnchor.constraint(equalToConstant: 30),
            
            // Nhãn hiển thị số lượng
            quantityLabel.leadingAnchor.constraint(equalTo: decreaseButton.trailingAnchor, constant: 10),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Nút tăng số lượng
            increaseButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 10),
            increaseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            increaseButton.widthAnchor.constraint(equalToConstant: 30),
            
            // Nhãn tên tour
            tourNameLabel.leadingAnchor.constraint(equalTo: increaseButton.trailingAnchor, constant: 20),
            tourNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tourNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            // Nhãn hiển thị giá tiền
            priceLabel.leadingAnchor.constraint(equalTo: tourNameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: tourNameLabel.bottomAnchor, constant: 5),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // Hàm cấu hình cell với dữ liệu
    func configure(with tour: [String: Any]) {
        if let name = tour["tenTour"] as? String,
           let quantity = tour["soLuong"] as? Int,
           let price = tour["giaTour"] as? String,
           let imageURLString = tour["hinhTour"] as? String,
           let imageURL = URL(string: imageURLString) {
            
            tourNameLabel.text = name
            quantityLabel.text = "\(quantity)"
            priceLabel.text = price
            
            // Tải hình ảnh từ URL
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("HTTP Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Error converting data to image or no data received.")
                    return
                }
                
                DispatchQueue.main.async {
                    self.tourImageView.image = image
                }
            }.resume()

        } else {
            print("Invalid tour data.")
        }
    }
}

