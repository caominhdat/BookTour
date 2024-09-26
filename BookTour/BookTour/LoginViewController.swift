import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailLoginText: UITextField!
    @IBOutlet weak var passwordLoginText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Thiết lập thuộc tính isSecureTextEntry
//        if passwordLoginText != nil {
//                passwordLoginText.isSecureTextEntry = true
//            } else {
//                print("passwordLoginText is nil")
//            }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        // Sử dụng optional binding để kiểm tra email và password
        guard let email = emailLoginText.text, !email.isEmpty,
              let password = passwordLoginText.text, !password.isEmpty else {
            print("Email hoặc password không hợp lệ")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }
        }
    }
}

