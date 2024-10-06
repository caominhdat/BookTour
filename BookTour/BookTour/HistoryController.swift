import UIKit
import FirebaseAuth
import FirebaseFirestore

class HistoryController: UIViewController {
    private var bookingData: [[String: Any]] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6 // Đổi nền thành màu xám nhạt
        title = "Lịch sử"
        setupUI()
        loadHistoryData()
    }
    
    private func setupUI() {
        // Cài đặt scrollView để có thể cuộn nếu nội dung lớn
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.white // Tạo màu nền trắng cho content

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func loadHistoryData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let historyRef = db.collection("History").document(userID).collection("Bookings")
        
        historyRef.getDocuments { [weak self] (snapshot, error) in
            if let documents = snapshot?.documents {
                self?.bookingData = documents.compactMap { $0.data() }
                self?.displayBookingData()
            } else {
                let errorMessage = error?.localizedDescription ?? "Không có dữ liệu"
                print("Lỗi khi tải lịch sử: \(errorMessage)")
            }
        }
    }

    private func displayBookingData() {
        var lastView: UIView?

        for booking in bookingData {
            let email = booking["email"] as? String ?? ""
            let name = booking["name"] as? String ?? ""
            let phone = booking["phone"] as? String ?? ""
            let totalPrice = booking["totalPrice"] as? Double ?? 0.0
            let items = booking["items"] as? [[String: Any]] ?? []
            let bookDate = booking["bookingDate"] as? Timestamp
            
            // Định dạng ngày đặt
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let dateText = bookDate != nil ? dateFormatter.string(from: bookDate!.dateValue()) : "Chưa có ngày đặt"

            // Tạo nhãn cho thông tin phiếu đặt
            let titleLabel = createLabel(text: "Phiếu đặt tour", fontSize: 24, isBold: true)
            titleLabel.textColor = .systemBlue
            
            let dateLabel = createLabel(text: "Ngày đặt: \(dateText)", fontSize: 18)
            let nameLabel = createLabel(text: "Tên: \(name)", fontSize: 18)
            let emailLabel = createLabel(text: "Email: \(email)", fontSize: 18)
            let phoneLabel = createLabel(text: "Số điện thoại: \(phone)", fontSize: 18)
            let totalPriceLabel = createLabel(text: "Tổng tiền: \(formatCurrency(value: totalPrice)) VND", fontSize: 18, isBold: true)
            totalPriceLabel.textColor = .systemRed

            contentView.addSubview(titleLabel)
            contentView.addSubview(dateLabel)
            contentView.addSubview(nameLabel)
            contentView.addSubview(emailLabel)
            contentView.addSubview(phoneLabel)
            contentView.addSubview(totalPriceLabel)

            // Sắp xếp vị trí các thành phần
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: lastView?.bottomAnchor ?? contentView.topAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                nameLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
                emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
                phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                totalPriceLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 20),
                totalPriceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                totalPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ])

            lastView = totalPriceLabel
            
            // Thêm chi tiết tour
            for item in items {
                let tenTour = item["tenTour"] as? String ?? ""
                let soLuong = item["soLuong"] as? Int ?? 0
                let giaTour = item["giaTour"] as? String ?? "0 VND"

                let itemLabel = createLabel(text: "\(tenTour) - Số lượng: \(soLuong) - Giá: \(giaTour)", fontSize: 16)
                itemLabel.backgroundColor = UIColor.systemGray5
                itemLabel.layer.cornerRadius = 8
                itemLabel.layer.masksToBounds = true
                itemLabel.textColor = .systemGray

                contentView.addSubview(itemLabel)

                NSLayoutConstraint.activate([
                    itemLabel.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 10),
                    itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
                ])

                lastView = itemLabel
            }
        }

        if let lastView = lastView {
            NSLayoutConstraint.activate([
                lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        }
    }

    // Hàm tạo UILabel
    private func createLabel(text: String, fontSize: CGFloat, isBold: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray // Thay đổi màu chữ
        return label
    }
    
    // Hàm định dạng lại giá trị thành chuỗi tiền tệ
    private func formatCurrency(value: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        let formattedValue = numberFormatter.string(from: NSNumber(value: value)) ?? "0"
        return formattedValue
    }
}

