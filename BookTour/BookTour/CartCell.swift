import UIKit
import FirebaseFirestore
import FirebaseAuth

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
    
    // Cập nhật font size lớn hơn
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15) // Tăng font size
        label.text = "1"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tourNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15) // Tăng font size
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15) // Tăng font size
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Closure để xử lý khi số lượng thay đổi
    var onQuantityChange: ((Int) -> Void)?
    
    // Document ID của tour để xoá
    var tourDocumentID: String?
    
    // Index của item trong mảng
    var itemIndex: Int?

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
        
        // Thêm nút xoá vào nội dung của cell
        contentView.addSubview(deleteButton)
        
        // Gán hành động khi bấm nút xoá
        deleteButton.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
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
    
    // Nút xoá
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Closure để xử lý khi nút xoá được bấm
    var onDeleteTapped: (() -> Void)?
    
    @objc private func deleteTapped() {
        guard let documentID = tourDocumentID,
              let itemIndex = itemIndex else { return }
        
        let db = Firestore.firestore()
        let cartRef = db.collection("Cart").document(documentID)
        
        // Lấy document để cập nhật mảng
        cartRef.getDocument { [weak self] (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, let data = document.data() else {
                print("Document does not exist or has no data")
                return
            }
            
            // Kiểm tra và lấy items
            guard var items = data["items"] as? [[String: Any]] else {
                print("No items found")
                return
            }

            // Kiểm tra chỉ số và xoá item
            if items.indices.contains(itemIndex) {
                items.remove(at: itemIndex) // Xoá item tại chỉ số cần thiết
                
                // Cập nhật lại document trong Firestore
                cartRef.updateData(["items": items]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Item successfully removed")
                        self?.onDeleteTapped?() // Gọi closure khi xoá thành công
                    }
                }
            } else {
                print("Item không tồn tại tại chỉ số \(itemIndex)")
            }
        }
    }

    // Thiết lập layout cho các phần tử trong cell
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ImageView hiển thị hình ảnh tour
            tourImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            tourImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tourImageView.widthAnchor.constraint(equalToConstant: 80),
            tourImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Nhãn tên tour
            tourNameLabel.leadingAnchor.constraint(equalTo: tourImageView.trailingAnchor, constant: 15),
            tourNameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            tourNameLabel.topAnchor.constraint(equalTo: tourImageView.topAnchor),
            
            priceLabel.leadingAnchor.constraint(equalTo: tourNameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: tourNameLabel.bottomAnchor, constant: 5),
            priceLabel.bottomAnchor.constraint(equalTo: tourImageView.bottomAnchor),
            
            // Nút giảm số lượng
            decreaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -65),
            decreaseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            decreaseButton.widthAnchor.constraint(equalToConstant: 30),
            decreaseButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Nhãn số lượng
            quantityLabel.trailingAnchor.constraint(equalTo: decreaseButton.leadingAnchor, constant: -10),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Nút tăng số lượng
            increaseButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -10),
            increaseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            increaseButton.widthAnchor.constraint(equalToConstant: 30),
            increaseButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Nút xoá
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // Hàm cấu hình cell với dữ liệu
    func configure(with tour: [String: Any], documentID: String, itemIndex: Int) {
        self.tourDocumentID = documentID
        self.itemIndex = itemIndex
        
        // Lấy dữ liệu từ Firestore
        if let name = tour["tenTour"] as? String,
           let quantity = tour["soLuong"] as? Int,
           let price = tour["giaTour"] as? String,
           let imageString = tour["HinhTour"] as? String,
           let imageURL = URL(string: imageString) {
            
            tourNameLabel.text = name
            quantityLabel.text = "\(quantity)"
            priceLabel.text = price
            
            // Tải hình ảnh từ URL
            tourImageView.load(url: imageURL)
        }
    }
}

// Extension để tải hình ảnh từ URL
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

