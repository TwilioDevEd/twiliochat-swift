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
        return self.isSigningUp ? "Back to login" : "Create account";
    }
    var loginButtonTitle: String {
        return self.isSigningUp ? "Register" : "Login";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isSigningUp = false;
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
        
        textFieldFormHandler.lastTextField = isSigningUp ? nil : passwordTextField;
        
        for (constraint, constant) in constraintDataList {
            constraint.constant = isSigningUp ? constant : 0
        }
        
        resetFirstResponderOnSignUpModeChange();
    }
    
    func resetFirstResponderOnSignUpModeChange() {
        self.view.layoutSubviews();
        
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
        
    }
    
    // MARK: - Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
}
