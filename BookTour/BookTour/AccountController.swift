import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    
    // Mảng chứa các thông tin người dùng
    private let userInfoSections = ["Thông tin cá nhân", "Chức năng"]
    private var userInfoItems: [[String]] = [["Email: ", "Tên: ", "Số điện thoại: "], ["Cập nhật thông tin", "Đăng xuất!"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tài khoản"
        view.backgroundColor = .white
        
        // Cài đặt bảng
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        // Thiết lập Auto Layout cho bảng
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Lấy thông tin người dùng từ Firebase
        fetchUserInfo()
    }
    
    // MARK: - Fetch User Info from Firestore
    private func fetchUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        
        db.collection("Users").document(currentUser.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let email = currentUser.email ?? "Chưa cập nhật"
                let name = data?["name"] as? String ?? ""
                let phone = data?["phone"] as? String ?? ""
                
                // Cập nhật dữ liệu người dùng vào userInfoItems
                self.userInfoItems[0][0] += email // Cập nhật email
                self.userInfoItems[0][1] += name // Cập nhật tên
                self.userInfoItems[0][2] += phone // Cập nhật số điện thoại
                
                self.tableView.reloadData() // Reload bảng sau khi lấy dữ liệu
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return userInfoSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = userInfoItems[indexPath.section][indexPath.row]
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.textColor = .red
            cell.backgroundColor = .white
        } else {
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Xử lý hành động khi người dùng chọn mục
        if indexPath.section == 1 && indexPath.row == 0 {
            // Chuyển đến màn hình cập nhật thông tin
            navigateToUpdateInfo()
        } else if indexPath.section == 1 && indexPath.row == 1 {
            // Xử lý đăng xuất
            logout()
        }
    }
    
    // MARK: - Navigation
    private func navigateToUpdateInfo() {
        // Chuyển đến màn hình cập nhật thông tin
        let updateInfoVC = UpdateInfoViewController()
        updateInfoVC.delegate = self // Thiết lập delegate
        navigationController?.pushViewController(updateInfoVC, animated: true)
    }
    
    private func logout() {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            print("Sign out successful")
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isUserSignedIn")
            
            // Lấy màn hình đăng nhập từ Storyboard với ID "LoginRegis"
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // Tên của storyboard, thường là "Main"
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginRegis") // ID của màn hình đăng nhập
            
            // Điều hướng về màn hình đăng nhập
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } catch let signoutErr {
            print("Error signing out: \(signoutErr.localizedDescription)")
            let alertController = UIAlertController(title: "Error", message: signoutErr.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - UpdateInfoDelegate
extension AccountController: UpdateInfoDelegate {
    func didUpdateUserInfo(name: String, phone: String) {
        // Cập nhật lại thông tin người dùng sau khi cập nhật thành công
        self.userInfoItems[0][1] = "Tên: " + name
        self.userInfoItems[0][2] = "Số điện thoại: " + phone
        tableView.reloadData() // Reload bảng để hiển thị thông tin mới
    }
}

