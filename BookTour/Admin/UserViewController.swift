import UIKit
import FirebaseFirestore

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserCellDelegate {
    
    // Khai báo các thành phần giao diện
    var tableView: UITableView!
    var users: [User] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        // Thiết lập navigation bar
        self.title = "Danh sách người dùng"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUser))

        // Thiết lập TableView
        setupTableView()
        
        // Lấy dữ liệu người dùng từ Firestore
        fetchUsers()
    }

    // Thiết lập TableView với AutoLayout
    func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        self.view.addSubview(tableView)
        
        // Thiết lập AutoLayout cho TableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    // Hàm lấy dữ liệu từ Firestore
    func fetchUsers() {
        db.collection("Users").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Lỗi khi lấy dữ liệu: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Không có tài liệu nào trong bộ sưu tập.")
                return
            }

            self.users = documents.compactMap { document in
                do {
                    var user = try document.data(as: User.self)
                    user.id = document.documentID  // Gán UID từ Firestore document ID sau khi giải mã
                    return user
                } catch {
                    print("Lỗi khi giải mã dữ liệu tài liệu: \(document.documentID) - \(error)")
                    return nil
                }
            }
            
            print("Dữ liệu người dùng: \(self.users)")  // In dữ liệu lấy về để kiểm tra
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // Số lượng hàng trong table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Cấu hình từng cell trong table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.configure(with: user)
        cell.delegate = self  // Đặt delegate để nhận sự kiện từ UserCell
        return cell
    }
    
    // Hàm xử lý xóa người dùng từ Firestore
    func deleteUser(at indexPath: IndexPath) {
        // Kiểm tra chỉ mục có hợp lệ không
        guard indexPath.row < users.count else {
            print("Chỉ mục không hợp lệ. Không thể xóa người dùng.")
            return
        }

        let user = users[indexPath.row]
        
        guard let userId = user.id else {
            print("Không thể xóa người dùng vì không có ID.")
            return
        }
        
        db.collection("Users").document(userId).delete { error in
            if let error = error {
                print("Không thể xóa người dùng: \(error.localizedDescription)")
            } else {
                // Cập nhật mảng và bảng sau khi xóa
                DispatchQueue.main.async {
                    self.users.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    // Hàm thêm người dùng
    @objc func addUser() {
        // Điều hướng sang màn hình thêm người dùng
    }
    
    // MARK: - UserCellDelegate
    func didTapUpdateButton(for user: User) {
        // Xử lý sự kiện cập nhật người dùng
        print("Cập nhật người dùng: \(user.name)")
        // Điều hướng hoặc mở màn hình cập nhật
    }
    
    func didTapDeleteButton(for user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            deleteUser(at: IndexPath(row: index, section: 0))
        }
    }
}
