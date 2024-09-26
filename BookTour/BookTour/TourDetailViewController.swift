import UIKit
import Firebase
import FirebaseAuth


class TourDetailViewController: UIViewController {
    var tour: Tour? // Biến lưu dữ liệu tour được truyền vào

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let guestCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Đặt", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        // Xử lý sự kiện cho nút "Đặt"
        bookButton.addTarget(self, action: #selector(bookTour), for: .touchUpInside)

        // Hiển thị dữ liệu tour
        if let tour = tour {
            nameLabel.text = tour.tenTour
            descriptionLabel.text = tour.moTaTour
            guestCountLabel.text = "Số lượng khách: \(tour.soLuongKhach)"
            priceLabel.text = "Giá: \(tour.giaTour)"
            durationLabel.text = "Thời gian: \(tour.thoiGianTour)"
            noteLabel.text = tour.ghiChu

            if let imageURL = URL(string: tour.hinhTour) {
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if let data = data, error == nil {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }
    }

    @objc private func bookTour() {
        guard let tour = tour else {
            print("Không có dữ liệu tour để thêm vào giỏ hàng.")
            return
        }

        // Tạo mảng dữ liệu để gửi đến CartController
        let cartData: [String: Any] = [
            "tenTour": tour.tenTour,
            "giaTour": tour.giaTour,
            "soLuong": 1, // Giả định số lượng là 1
            "hinhTour": tour.hinhTour
        ]

        // Lưu vào Firestore
        saveToCart(cartData: cartData)
    }

    private func saveToCart(cartData: [String: Any]) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Người dùng chưa đăng nhập.")
            return
        }

        let db = Firestore.firestore()
        let cartRef = db.collection("Cart").document(userID)

        cartRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Nếu document đã tồn tại, thêm item mới vào array
                cartRef.updateData([
                    "items": FieldValue.arrayUnion([cartData])
                ]) { error in
                    if let error = error {
                        print("Lỗi khi cập nhật giỏ hàng: \(error.localizedDescription)")
                    } else {
                        print("Cập nhật giỏ hàng thành công")
                        // Gửi thông báo cho CartController
                        NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
                    }
                }
            } else {
                // Nếu document chưa tồn tại, tạo mới với array chứa item
                cartRef.setData([
                    "items": [cartData]
                ]) { error in
                    if let error = error {
                        print("Lỗi khi lưu giỏ hàng: \(error.localizedDescription)")
                    } else {
                        print("Lưu giỏ hàng thành công")
                        // Gửi thông báo cho CartController
                        NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
                    }
                }
            }
        }
    }


    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(guestCountLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(bookButton)

        // Ràng buộc cho scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Ràng buộc cho các thành phần
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            guestCountLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            guestCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            priceLabel.topAnchor.constraint(equalTo: guestCountLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            durationLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            noteLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            noteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            noteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Ràng buộc cho nút book
            bookButton.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 20),
            bookButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bookButton.widthAnchor.constraint(equalToConstant: 150),
            bookButton.heightAnchor.constraint(equalToConstant: 50),
            bookButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Đảm bảo nút không bị che khuất
        ])
    }
}

