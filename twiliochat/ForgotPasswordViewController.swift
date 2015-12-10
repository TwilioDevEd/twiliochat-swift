import UIKit
import Parse

class ForgotPasswordViewController: UIViewController {
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
      return true
    }

    AlertDialogController.showAlertWithMessage("Your email is required",
      title: nil,
      presenter: self)
    return false
  }

  func startPasswordRecovery() {
    view.userInteractionEnabled = false

    if (validateUserData()) {
      PFUser.requestPasswordResetForEmailInBackground(emailTextField.text ?? "") { (succeeded, error) in
        if (succeeded) {
          AlertDialogController.showAlertWithMessage("We've sent you an email with further instructions",
            title: nil,
            presenter: self) {
              self.performSegueWithIdentifier("BackToLogin", sender: self)
          }
        }
        else {
          AlertDialogController.showAlertWithMessage(error?.localizedDescription,
            title: nil,
            presenter: self)
          self.view.userInteractionEnabled = true
        }
      }
    }
  }

  // MARK: - Actions
  @IBAction func sendButtonTouched(sender: UIButton) {
    startPasswordRecovery()
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  override func shouldAutorotate() -> Bool {
    return true
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    if (UI_USER_INTERFACE_IDIOM() == .Pad) {
      return .All
    }
    return .Portrait
  }

  override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
    return .Portrait
  }
}

// MARK: - TextFieldFormHandlerDelegate
extension ForgotPasswordViewController : TextFieldFormHandlerDelegate {
  func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler) {
    startPasswordRecovery()
  }
}
