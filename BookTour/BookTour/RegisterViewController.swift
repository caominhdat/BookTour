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
        guard let email = emailRegisterText.text, !email.isEmpty else {
            print("Email không được để trống")
            return
        }
        
        guard let password = passwordRegisterText.text, !password.isEmpty else {
            print("Password không được để trống")
            return
        }
        
        guard password == confirmRegisterText.text else {
            print("Mật khẩu xác nhận không trùng khớp")
            return
        }
        
        // Đăng ký người dùng với Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                print("Đăng ký thất bại: \(error.localizedDescription)")
                return
            }
            
            // Lấy UID của người dùng sau khi đăng ký thành công
            guard let uid = firebaseResult?.user.uid else { return }
            
            // Tạo document mới trong Firestore với UID làm documentID
            let db = Firestore.firestore()
            db.collection("Users").document(uid).setData([
                "email": email,
                "uid": uid,
                // Bạn có thể thêm các thông tin khác của người dùng tại đây
            ]) { error in
                if let error = error {
                    print("Lỗi khi thêm người dùng vào Firestore: \(error.localizedDescription)")
                } else {
                    print("Đăng ký thành công và đã thêm người dùng vào Firestore")
                    // Điều hướng đến màn hình tiếp theo
                    self.performSegue(withIdentifier: "goToNext", sender: self)
                }
            }
        }
    }
}

