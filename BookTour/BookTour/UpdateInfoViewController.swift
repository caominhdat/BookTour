import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol UpdateInfoDelegate: AnyObject {
    func didUpdateUserInfo(name: String, phone: String)
}

class UpdateInfoViewController: UIViewController {
    
    weak var delegate: UpdateInfoDelegate?
    
    private let nameTextField = UITextField()
    private let phoneTextField = UITextField()
    private let updateButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
            
        title = "Cập nhật thông tin"
        view.backgroundColor = .white
        
        setupUI()
        fetchCurrentUserInfo()
    }
    
    private func setupUI() {
        // Thiết lập giao diện cho text fields và button
        nameTextField.placeholder = "Nhập tên"
        phoneTextField.placeholder = "Nhập số điện thoại"
        
        updateButton.setTitle("Cập nhật", for: .normal)
        updateButton.addTarget(self, action: #selector(updateUserInfo), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [nameTextField, phoneTextField, updateButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Thiết lập Auto Layout cho stackView
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func fetchCurrentUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        
        db.collection("Users").document(currentUser.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let phone = data?["phone"] as? String ?? ""
                
                // Điền thông tin hiện tại vào text fields
                self.nameTextField.text = name
                self.phoneTextField.text = phone
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @objc private func updateUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let name = nameTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        
        // Cập nhật thông tin vào Firestore
        db.collection("Users").document(currentUser.uid).setData([
            "name": name,
            "phone": phone
        ], merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
                // Gọi delegate để thông báo cập nhật thành công
                self.delegate?.didUpdateUserInfo(name: name, phone: phone)
                self.navigationController?.popViewController(animated: true) // Quay lại trang tài khoản
            }
        }
    }
}

