import UIKit
import Parse

class ForgotPasswordViewController: UIViewController, TextFieldFormHandlerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    var textFieldFormHandler:TextFieldFormHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldFormHandler = TextFieldFormHandler(withTextFields: [emailTextField], topContainer: view)
        textFieldFormHandler.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validateUserData() -> Bool {
        if let text = emailTextField.text where !text.isEmpty {
            return true;
        }
        
        AlertDialogController.showAlertWithMessage("Your email is required",
            title: nil,
            presenter: self)
        return false;
    }
    
    // MARK: - TextFieldFormHandlerDelegate
    
    func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler) {
        startPasswordRecovery();
    }
    
    func startPasswordRecovery() {
        view.userInteractionEnabled = false
        
        if (validateUserData()) {
            PFUser.requestPasswordResetForEmailInBackground(emailTextField.text ?? "",
                block: { (succeeded, error) in
                    if (succeeded) {
                        AlertDialogController.showAlertWithMessage("We've sent you an email with further instructions",
                            title: nil,
                            presenter: self,
                            handler: {
                                self.performSegueWithIdentifier("BackToLogin", sender: self)
                        })
                    }
                    else {
                        AlertDialogController.showAlertWithMessage(error?.localizedDescription,
                            title: nil,
                            presenter: self)
                        self.view.userInteractionEnabled = true
                    }
            })
        }
    }
    
    // MARK: - Actions
    @IBAction func sendButtonTouched(sender: UIButton) {
        startPasswordRecovery()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }

}
