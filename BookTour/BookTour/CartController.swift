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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Thanh Toán", for: .normal)
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
        setupUI()
        loadCartItems()
        
        //bookButton.addTarget(self, action: #selector(handleCheckout), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCart), name: NSNotification.Name("CartUpdated"), object: nil)
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
        totalPrice = 0
        for item in cartItems {
            let quantity = item["soLuong"] as? Int ?? 0
            let priceString = item["giaTour"] as? String ?? "0"
            let price = Double(priceString.replacingOccurrences(of: ".", with: "")) ?? 0
            totalPrice += Double(quantity) * price
        }
        totalLabel.text = "Tổng: \(totalPrice) VND"
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
}

extension CartController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let cartItem = cartItems[indexPath.row]
        
        if let name = cartItem["tenTour"] as? String,
           let quantity = cartItem["soLuong"] as? Int,
           let price = cartItem["giaTour"] as? String {
            cell.tourNameLabel.text = name
            cell.quantityLabel.text = "\(quantity)"
            cell.priceLabel.text = price
            
            cell.onQuantityChange = { [weak self] newQuantity in
                self?.cartItems[indexPath.row]["soLuong"] = newQuantity
                self?.calculateTotal()
                // Cập nhật giỏ hàng vào Firestore
                self?.saveToCart {}
            }
        }
        
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


