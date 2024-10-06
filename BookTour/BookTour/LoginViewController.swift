import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var emailLoginText: UITextField!
    @IBOutlet weak var passwordLoginText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Thiết lập thuộc tính isSecureTextEntry cho password field
        passwordLoginText?.isSecureTextEntry = true
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        // Kiểm tra email và password
        guard let email = emailLoginText.text, !email.isEmpty,
              let password = passwordLoginText.text, !password.isEmpty else {
            self.showAlert(title: "Lỗi", message: "Email hoặc password không hợp lệ.")
            return
        }
        
        // Đăng nhập với Firebase
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                // Hiển thị lỗi đăng nhập
                self.showAlert(title: "Lỗi đăng nhập", message: error.localizedDescription)
            } else {
                // Lấy UID của người dùng
                guard let uid = firebaseResult?.user.uid else { return }
                
                // Truy vấn Firestore để kiểm tra trường "role"
                let db = Firestore.firestore()
                db.collection("Users").document(uid).getDocument { (document, error) in
                    if let error = error {
                        self.showAlert(title: "Lỗi", message: "Không thể truy xuất thông tin người dùng: \(error.localizedDescription)")
                    } else if let document = document, document.exists {
                        // Lấy giá trị của trường "role"
                        let role = document.data()?["role"] as? String
                        
                        if role == "admin" {
                            // Nếu là admin, chuyển đến AdminViewController
                            self.performSegue(withIdentifier: "goToAdmin", sender: self)
                        } else {
                            // Nếu không có role hoặc role là user, tiếp tục điều hướng bình thường
                            self.performSegue(withIdentifier: "goToNext", sender: self)
                        }
                    } else {
                        self.showAlert(title: "Lỗi", message: "Người dùng không tồn tại.")
                    }
                }
            }
        }
    }

    // Hàm để hiển thị thông báo bằng UIAlertController
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

