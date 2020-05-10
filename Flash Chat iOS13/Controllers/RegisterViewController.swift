

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.warningLabel.text = e.localizedDescription
                    print(e.localizedDescription)
                    print(e)
                } else {
                    //Navigate to the ChatVC
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
            
        }
    }
}
