import UIKit

class LoginViewController: UIViewController {
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  // MARK: - Injectable Properties

  var alertDialogControllerClass = AlertDialogController.self
  var ipMessagingClientClass = IPMessagingManager.self

  // MARK: - Initialization

  var textFieldFormHandler: TextFieldFormHandler!

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeTextFields()
  }

  func initializeTextFields() {
    let textFields: [UITextField] = [usernameTextField]
    textFieldFormHandler = TextFieldFormHandler(withTextFields: textFields, topContainer: view)
    textFieldFormHandler.delegate = self
  }

  func resetFirstResponderOnSignUpModeChange() {
    self.view.layoutSubviews()

    if let index = self.textFieldFormHandler.firstResponderIndex {
      if (index > 1) {
        textFieldFormHandler.setTextFieldAtIndexAsFirstResponder(1)
      }
      else {
        textFieldFormHandler.resetScroll()
      }
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    textFieldFormHandler.cleanUp()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Actions

  @IBAction func loginButtonTouched(sender: UIButton) {
    loginUser()
  }

  // MARK: - Login

  func loginUser() {
    if (validateUserData()) {
      view.userInteractionEnabled = false
      activityIndicator.startAnimating()

      let ipMessagingManager = ipMessagingClientClass.sharedManager()
      if let username = usernameTextField.text {
        ipMessagingManager.loginWithUsername(username, completion: handleResponse)
      }
    }
  }

  func validateUserData() -> Bool {
    if let usernameEmpty = usernameTextField.text?.isEmpty where !usernameEmpty {
      return true
    }
    showError("All fields are required")
    return false
  }

  func showError(message:String) {
    alertDialogControllerClass.showAlertWithMessage(message, title: nil, presenter: self)
  }

  func handleResponse(succeeded: Bool, error: NSError?) {
    self.activityIndicator.stopAnimating()
    if succeeded {
      ipMessagingClientClass.sharedManager().presentRootViewController()
    }
    else if let error = error {
      self.showError(error.localizedDescription)
    }
    self.view.userInteractionEnabled = true
  }

  // MARK: - Style

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
extension LoginViewController : TextFieldFormHandlerDelegate {
  func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler) {
    loginUser()
  }
}
