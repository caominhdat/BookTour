import UIKit
import FirebaseAuth

class AdminViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        // Background
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background") // Thay bằng tên ảnh của bạn
        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)

        // Tạo các nút quản lý
        let userManagementButton = createButton(title: "Quản lý người dùng", action: #selector(manageUsers))
        let tourManagementButton = createButton(title: "Quản lý tour", action: #selector(manageTours))
        let scheduleManagementButton = createButton(title: "Quản lý lịch trình", action: #selector(manageSchedules))
        let bookingManagementButton = createButton(title: "Quản lý tour đã đặt", action: #selector(manageBookings))

        // Sử dụng stack view để sắp xếp các nút quản lý
        let stackView = UIStackView(arrangedSubviews: [userManagementButton, tourManagementButton, scheduleManagementButton, bookingManagementButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)

        // Sắp xếp stack view ở giữa màn hình
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)
        ])

        // Nút đăng xuất
        let logoutButton = UIButton(type: .system)
        let logoutImage = UIImage(systemName: "lock.iphone") // Sử dụng SF Symbol
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = .white
        logoutButton.backgroundColor = UIColor(red: 205/255.0, green: 62/255.0, blue: 45/255.0, alpha: 0.8)
        logoutButton.layer.cornerRadius = 25
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        self.view.addSubview(logoutButton)

        // Contraint logout
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 50),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor(red: 205/255.0, green: 62/255.0, blue: 45/255.0, alpha: 0.8)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // Điều hướng
    @objc func manageUsers() {
        print("Quản lý người dùng")
        let userVC = UserViewController()
        self.navigationController?.pushViewController(userVC, animated: true)
    }

    @objc func manageTours() {
        print("Quản lý tour")
        let userVC = ManageTourController()
        self.navigationController?.pushViewController(userVC, animated: true)
    }

    @objc func manageSchedules() {
        print("Quản lý lịch trình")
        let userVC = ManageScheduleController()
        self.navigationController?.pushViewController(userVC, animated: true)
    }

    @objc func manageBookings() {
        print("Quản lý tour đã đặt")
        let userVC = ManageBookTourController()
        self.navigationController?.pushViewController(userVC, animated: true)
    }

    // Xử lí đăng xuất
    @objc func logout() {
        print("Đăng xuất")
        let auth = Auth.auth()
        do {
            try auth.signOut()
            print("Sign out successful")
            
            // Đặt trạng thái đăng xuất
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isUserSignedIn")
            
            // Điều hướng
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginRegis")
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

