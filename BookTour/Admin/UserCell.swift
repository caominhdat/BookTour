import UIKit

// UserCellDelegate giúp giao tiếp giữa cell và UserViewController
protocol UserCellDelegate: AnyObject {
    func didTapUpdateButton(for user: User)
    func didTapDeleteButton(for user: User)
}

class UserCell: UITableViewCell {
    
    var nameLabel: UILabel!
    var emailLabel: UILabel!
    var phoneLabel: UILabel!
    var roleLabel: UILabel!
    var updateButton: UIButton!
    var deleteButton: UIButton!
    
    // Delegate để gọi các hành động từ UserViewController
    weak var delegate: UserCellDelegate?
    
    // Biến lưu trữ người dùng hiện tại để truyền dữ liệu cho delegate khi nhấn các nút
    var currentUser: User?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        emailLabel = UILabel()
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        phoneLabel = UILabel()
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(phoneLabel)
        
        roleLabel = UILabel()
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(roleLabel)
        
        updateButton = UIButton(type: .system)
        updateButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.addTarget(self, action: #selector(updateUser), for: .touchUpInside)
        contentView.addSubview(updateButton)
        
        deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        
        // AutoLayout
        NSLayoutConstraint.activate([
            // nameLabel
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: updateButton.leadingAnchor, constant: -10),
            
            // emailLabel
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: updateButton.leadingAnchor, constant: -10),
            
            // phoneLabel
            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            phoneLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(lessThanOrEqualTo: updateButton.leadingAnchor, constant: -10),
            
            // roleLabel
            roleLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(lessThanOrEqualTo: updateButton.leadingAnchor, constant: -10),
            roleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // updateButton
            updateButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            updateButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            updateButton.widthAnchor.constraint(equalToConstant: 30),
            updateButton.heightAnchor.constraint(equalToConstant: 30),
            
            // deleteButton
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Hàm configure để hiển thị thông tin người dùng
    func configure(with user: User) {
        currentUser = user
        nameLabel.text = "Tên người dùng: \(user.name)"
        emailLabel.text = "Email: \(user.email)"
        phoneLabel.text = "Số điện thoại: \(user.phone)"
        roleLabel.text = "Loại người dùng: \(user.role ?? "user")"
    }
    
    // Gọi delegate khi nhấn nút cập nhật
    @objc func updateUser() {
        guard let user = currentUser else { return }
        delegate?.didTapUpdateButton(for: user)
    }
    
    // Gọi delegate khi nhấn nút xóa
    @objc func deleteUser() {
        guard let user = currentUser else { return }
        delegate?.didTapDeleteButton(for: user)
    }
}

