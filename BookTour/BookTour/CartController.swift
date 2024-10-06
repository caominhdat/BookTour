import UIKit
import FirebaseAuth
import FirebaseFirestore

class CartController: UIViewController {
    
    private let tableView = UITableView()
    private var cartItems: [[String: Any]] = [] // Lưu các tour đã đặt
    private var totalPrice: Double = 0.0 // Tổng tiền của giỏ hàng
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .blue
        label.textAlignment = .center
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hoàn tất đặt tour", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Giỏ Tour"
        setupUI()
        loadCartItems()
        
        //bookButton.addTarget(self, action: #selector(handleCheckout), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCart), name: NSNotification.Name("CartUpdated"), object: nil)
        bookButton.addTarget(self, action: #selector(handleCheckout), for: .touchUpInside)//Hoàn tất
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CartCell.self, forCellReuseIdentifier: "CartCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(totalLabel)
        view.addSubview(bookButton)
        
        // Cải tiến các ràng buộc cho UI
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalLabel.topAnchor, constant: -20),
            
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalLabel.bottomAnchor.constraint(equalTo: bookButton.topAnchor, constant: -10),
            totalLabel.heightAnchor.constraint(equalToConstant: 50),
            
            bookButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bookButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Thêm màu nền cho tableView để tạo sự tách biệt
        tableView.layer.cornerRadius = 8
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1) // Nền nhẹ cho TableView
    }
    
    private func loadCartItems() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let cartRef = db.collection("Cart").document(userID)
        
        cartRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                if let data = document.data(), let items = data["items"] as? [[String: Any]] {
                    self.cartItems = items
                    self.calculateTotal()
                    self.tableView.reloadData()
                }
            } else {
                let errorMessage = error?.localizedDescription ?? "Không có lỗi"
                print("Giỏ hàng trống hoặc lỗi: \(errorMessage)")
            }
        }
    }
    
    private func calculateTotal() {
        print("calculateTotal() được gọi")
        totalPrice = 0
        for item in cartItems {
            let quantity = item["soLuong"] as? Int ?? 0
            let priceString = item["giaTour"] as? String ?? "0 VND"
            
            // Loại bỏ "VND" và dấu chấm "." trong giá tiền
            let cleanPriceString = priceString
                .replacingOccurrences(of: " VND", with: "")
                .replacingOccurrences(of: ".", with: "")
            
            // Chuyển đổi thành Double để tính toán
            let price = Double(cleanPriceString) ?? 0
            
            // Tính tổng: giá tiền nhân với số lượng
            totalPrice += Double(quantity) * price
        }
        
        // Hiển thị tổng giá dưới định dạng "Tổng: xxx VND"
        totalLabel.text = "Tổng: \(formatCurrency(value: totalPrice)) VND"
        print("Tổng tiền đã tính: \(totalPrice)")
    }
    
    // Hàm định dạng lại giá trị thành chuỗi tiền tệ
    private func formatCurrency(value: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        let formattedValue = numberFormatter.string(from: NSNumber(value: value)) ?? "0"
        return formattedValue
    }
    
    //    @objc private func handleCheckout() {
    //        saveToCart { [weak self] in
    //            // Điều hướng tới màn hình thanh toán
    //            self?.navigateToPaymentScreen()
    //        }
    //    }
    
    private func saveToCart(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let cartRef = db.collection("Cart").document(userID)
        
        cartRef.setData(["items": cartItems]) { error in
            if let error = error {
                print("Lỗi khi lưu giỏ hàng: \(error.localizedDescription)")
            } else {
                print("Lưu giỏ hàng thành công")
                completion() // Gọi completion sau khi lưu thành công
            }
        }
    }
    
    @objc private func reloadCart() {
        loadCartItems() // Tải lại các mục giỏ hàng
        print("Giỏ hàng đã được cập nhật")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleCheckout() {
        // Lưu thông tin phiếu đặt tour vào Firestore
        saveBookingToHistory { [weak self] in
            // Hiển thị thông báo đặt tour thành công
            let alert = UIAlertController(title: "Thành công", message: "Đặt tour thành công!", preferredStyle: .alert)
            self?.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                alert.dismiss(animated: true) {
                    // Chuyển người dùng sang HistoryController
                    let historyVC = HistoryController()
                    self?.navigationController?.pushViewController(historyVC, animated: true)
                }
            }
        }
    }
    
    private func saveBookingToHistory(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userID)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let userData = document.data()
                let email = userData?["email"] as? String ?? ""
                let name = userData?["name"] as? String ?? ""
                let phone = userData?["phone"] as? String ?? ""
                
                // Chuẩn bị dữ liệu cho lịch sử đặt tour
                let bookingData: [String: Any] = [
                    "email": email,
                    "name": name,
                    "phone": phone,
                    "items": self.cartItems,
                    "totalPrice": self.totalPrice,
                    "bookingDate": Timestamp(date: Date())
                ]
                
                // Tạo document mới trong collection "Bookings"
                let historyRef = db.collection("History").document(userID).collection("Bookings").document()
                
                // Lưu thông tin vào collection "Bookings"
                historyRef.setData(bookingData) { error in
                    if let error = error {
                        print("Lỗi khi lưu lịch sử: \(error.localizedDescription)")
                    } else {
                        print("Lưu lịch sử đặt tour thành công")
                        completion()
                    }
                }
            } else {
                print("Lỗi: Document người dùng không tồn tại.")
            }
        }
    }
}

extension CartController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let cartItem = cartItems[indexPath.row]
        
        print("Cart item at index \(indexPath.row): \(cartItem)")
        
        if let name = cartItem["tenTour"] as? String,
           let quantity = cartItem["soLuong"] as? Int,
           let price = cartItem["giaTour"] as? String,
           let image = cartItem["hinhTour"] as? String {
            cell.tourNameLabel.text = name
            cell.quantityLabel.text = "\(quantity)"
            cell.priceLabel.text = price
            
            if let url = URL(string: image) { // Sử dụng image từ cartItem
                cell.tourImageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
            } else {
                cell.tourImageView.image = UIImage(named: "placeholder") // Đặt hình mặc định nếu URL không hợp lệ
            }
            
            cell.onQuantityChange = { [weak self] newQuantity in
                self?.cartItems[indexPath.row]["soLuong"] = newQuantity
                self?.calculateTotal()
                // Cập nhật giỏ hàng vào Firestore
                self?.saveToCart {}
            }
            
            cell.onDeleteTapped = { [weak self] in
                // Xoá item khỏi danh sách local
                self?.cartItems.remove(at: indexPath.row)
                
                // Xoá dòng trong table view
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                // Reload lại dữ liệu nếu cần
                self?.loadCartItems()
            }
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
                print("User ID is nil, cannot set documentID.")
                return cell
            }
            
        let documentID = userID
        let itemIndex = indexPath.row // Sử dụng indexPath.row làm itemIndex
            
        
        cell.configure(with: cartItem, documentID: documentID, itemIndex: itemIndex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //    private func navigateToPaymentScreen() {
    //        // Thực hiện điều hướng tới màn hình thanh toán
    //        let paymentVC = PaymentViewController() // Thay thế bằng controller thanh toán thực tế
    //        navigationController?.pushViewController(paymentVC, animated: true)
    //    }
}
