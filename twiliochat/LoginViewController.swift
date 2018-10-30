import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Injectable Properties
    
    var alertDialogControllerClass = AlertDialogController.self
    var MessagingClientClass = MessagingManager.self
    
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
                textFieldFormHandler.setTextFieldAtIndexAsFirstResponder(index: 1)
            }
            else {
                textFieldFormHandler.resetScroll()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldFormHandler.cleanUp()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonTouched(_ sender: UIButton) {
        loginUser()
    }
    
    // MARK: - Login
    
    func loginUser() {
        if (validUserData()) {
            view.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let MessagingManager = MessagingClientClass.sharedManager()
            if let username = usernameTextField.text {
                MessagingManager.loginWithUsername(username: username, completion: handleResponse)
            }
        }
    }
    
    func validUserData() -> Bool {
        if let usernameEmpty = usernameTextField.text?.isEmpty, !usernameEmpty {
            return true
        }
        showError(message: "All fields are required")
        return false
    }
    
    func showError(message:String) {
        alertDialogControllerClass.showAlertWithMessage(message: message, title: nil, presenter: self)
    }
    
    func handleResponse(succeeded: Bool, error: NSError?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if let error = error, !succeeded {
                self.showError(message: error.localizedDescription)
            }
            self.view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return .all
        }
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - TextFieldFormHandlerDelegate
extension LoginViewController : TextFieldFormHandlerDelegate {
    func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler) {
        loginUser()
    }
}
