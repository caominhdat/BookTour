import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailRegisterText: UITextField!
    @IBOutlet weak var passwordRegisterText: UITextField!
    @IBOutlet weak var confirmRegisterText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordRegisterText.isSecureTextEntry = true
        confirmRegisterText.isSecureTextEntry = true
    }
    
    @IBAction func registerBotton(_ sender: Any) {
        // Kiểm tra email có rỗng không
        guard let email = emailRegisterText.text, !email.isEmpty else {
            showAlert(title: "Lỗi", message: "Email không được để trống")
            return
        }
        
        // Kiểm tra password có rỗng không
        guard let password = passwordRegisterText.text, !password.isEmpty else {
            showAlert(title: "Lỗi", message: "Password không được để trống")
            return
        }
        
        // Kiểm tra password và confirm password có trùng khớp không
        guard password == confirmRegisterText.text else {
            showAlert(title: "Lỗi", message: "Mật khẩu xác nhận không trùng khớp")
            return
        }
        
        // Đăng ký người dùng với Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                // Hiển thị lỗi nếu đăng ký thất bại
                self.showAlert(title: "Đăng ký thất bại", message: error.localizedDescription)
                return
            }
            
            // Lấy UID của người dùng sau khi đăng ký thành công
            guard let uid = firebaseResult?.user.uid else { return }
            
            // Tạo document mới trong Firestore với UID làm documentID
            let db = Firestore.firestore()
            db.collection("Users").document(uid).setData([
                "email": email,
                "uid": uid
                // Thêm các thông tin khác của người dùng tại đây nếu cần
            ]) { error in
                if let error = error {
                    // Hiển thị lỗi nếu thêm người dùng vào Firestore thất bại
                    self.showAlert(title: "Lỗi Firestore", message: error.localizedDescription)
                } else {
                    // Hiển thị thông báo thành công và điều hướng
                    self.showAlert(title: "Thành công", message: "Đăng ký thành công!") {
                        self.performSegue(withIdentifier: "goToNext", sender: self)
                    }
                }
            }
        }
    }
    
    // Hàm hiển thị UIAlertController
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?() // Gọi completion nếu cần thực hiện điều gì sau khi nhấn OK
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

