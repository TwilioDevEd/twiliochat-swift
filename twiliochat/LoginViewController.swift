import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, TextFieldFormHandlerDelegate {
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var createAccountButton: UIButton!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var fullNameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  @IBOutlet weak var fullNameHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var fullNameTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var emailTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var emailHeightConstraint: NSLayoutConstraint!

  // MARK: - Initialization

  var constraintDataList: [(NSLayoutConstraint, CGFloat)]!
  var isSigningUp = false
  var textFieldFormHandler: TextFieldFormHandler!

  var createAccountButtonTitle: String {
    return self.isSigningUp ? "Back to login" : "Create account"
  }
  var loginButtonTitle: String {
    return self.isSigningUp ? "Register" : "Login"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.isSigningUp = false
    initializeConstraints()
    initializeTextFields()
    refreshSignUpControls()
  }

  func initializeConstraints() {
    let constraints = [fullNameHeightConstraint, fullNameTopConstraint, emailHeightConstraint, emailTopConstraint]
    constraintDataList = constraints.map({ constraint in (constraint, constraint.constant)})
  }

  func initializeTextFields() {
    let textFields: [UITextField] = [usernameTextField, passwordTextField, fullNameTextField, emailTextField]
    textFieldFormHandler = TextFieldFormHandler(withTextFields: textFields, topContainer: view)
    textFieldFormHandler.delegate = self
  }

  func refreshSignUpControls() {
    createAccountButton.setTitle(createAccountButtonTitle, forState: .Normal)
    loginButton.setTitle(loginButtonTitle, forState: .Normal)

    textFieldFormHandler.lastTextField = isSigningUp ? nil : passwordTextField

    for (constraint, constant) in constraintDataList {
      constraint.constant = isSigningUp ? constant : 0
    }

    resetFirstResponderOnSignUpModeChange()
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
    signUpOrLogin()
  }

  @IBAction func createAccountButtonTouched(sender: UIButton) {
    toggleSignUpMode()
  }

  // MARK: - TextFieldFormHandlerDelegate

  func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler) {
    signUpOrLogin()
  }

  // MARK: - Login

  func toggleSignUpMode() {
    isSigningUp = !isSigningUp
    refreshSignUpControls()
  }

  func signUpOrLogin() {
    if (validateUserData()) {
      view.userInteractionEnabled = false
      activityIndicator.startAnimating()

      if(isSigningUp) {
        registerUser()
      }
      else {
        loginUser()
      }
    }
  }

  func loginUser() {
    let ipMessagingManager = IPMessagingManager.sharedManager
    if let username = usernameTextField.text, password = passwordTextField.text {
      ipMessagingManager.loginWithUsername(username, password: password, completion: handleResponse)
    }
  }

  func registerUser() {
    let ipMessagingManager = IPMessagingManager.sharedManager
    if let username = usernameTextField.text, password = passwordTextField.text, fullName = fullNameTextField.text, email = emailTextField.text {
      ipMessagingManager.registerWithUsername(username, password: password, fullName: fullName, email: email, completion: handleResponse)
    }
  }

  func validateUserData() -> Bool {
    if let usernameEmpty = usernameTextField.text?.isEmpty, passwordEmpty = passwordTextField.text?.isEmpty where !usernameEmpty && !passwordEmpty {
      if isSigningUp {
        if let fullNameEmpty = fullNameTextField.text?.isEmpty, emailEmpty = emailTextField.text?.isEmpty where !fullNameEmpty && !emailEmpty {
          return true
        }
      }
      else {
        return true
      }
    }
    showError("All fields are required")
    return false
  }

  func showError(message:String) {
    AlertDialogController.showAlertWithMessage(message, title: nil, presenter: self)
  }

  func handleResponse(succeeded: Bool, error: NSError?) {
    self.activityIndicator.stopAnimating()
    if succeeded {
      IPMessagingManager.sharedManager.presentRootViewController()
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
