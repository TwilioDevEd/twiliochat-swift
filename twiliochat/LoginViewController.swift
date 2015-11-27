import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
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
    var textFields: [UITextField]!
    var isSigningUp = false
    var keyboardSize: CGFloat!
    var animationOffset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let constraints = [fullNameHeightConstraint, fullNameTopConstraint, emailHeightConstraint, emailTopConstraint]
        constraintDataList = constraints.map({ constraint in (constraint, constraint.constant)})
        hideSignUpControls()
        initializeTextFields()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }

    func initializeTextFields() {
        textFields = [usernameTextField, passwordTextField, fullNameTextField, emailTextField]
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    func toggleSignUpMode() {
        isSigningUp = !isSigningUp
        if (isSigningUp) {
            showSignUpControls()
        }
        else {
            hideSignUpControls()
        }
    }
    
    func showSignUpControls() {
        createAccountButton.setTitle("Back to login", forState: .Normal)
        loginButton.setTitle("Register", forState: .Normal)
        for (constraint, constant) in constraintDataList {
            constraint.constant = constant
        }
        setTextField(passwordTextField, returnKeyType: .Next)
    }
    
    func hideSignUpControls() {
        createAccountButton.setTitle("Create account", forState: .Normal)
        loginButton.setTitle("Login", forState: .Normal)
        for (constraint, _) in constraintDataList {
            constraint.constant = 0
        }
        setTextField(passwordTextField, returnKeyType: .Done)
    }
    
    func setTextField(textField: UITextField, returnKeyType type: UIReturnKeyType) {
        if (passwordTextField.isFirstResponder()) {
            passwordTextField.resignFirstResponder()
            passwordTextField.returnKeyType = type
            passwordTextField.becomeFirstResponder()
        }
        else {
            passwordTextField.returnKeyType = type
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions

    @IBAction func loginButtonTouched(sender: UIButton) {
    }
    @IBAction func createAccountButtonTouched(sender: UIButton) {
        toggleSignUpMode()
    }
    
    // MARK: - Animation
    
    func moveScreenUp() {
        shiftScreenYPosition(-keyboardSize - animationOffset, duration: 0.3, curve: .EaseInOut)
    }
    
    func moveScreenDown() {
        shiftScreenYPosition(0, duration: 0.2, curve: .EaseInOut)
    }
    
    func shiftScreenYPosition(position: CGFloat, duration: NSTimeInterval, curve: UIViewAnimationCurve) {
        UIView.beginAnimations("moveUp", context: nil)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationDuration(duration)
        
        view.frame.origin.y = position
        UIView.commitAnimations()
    }
    
    @IBAction func backgroundTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
        moveScreenDown()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let textFieldSuperView = textField.superview!
        
        let textFieldHeight = textFieldSuperView.frame.size.height
        let textFieldY = textFieldSuperView.superview?.convertPoint(textFieldSuperView.frame.origin, toView: view).y
        animationOffset = -screenHeight + (textFieldY ?? 0) + textFieldHeight;
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = textFields.indexOf(textField)!
        
        if (isSigningUp) {
            if (index == textFields.count - 1) {
                doneEnteringData()
                return true
            }
        }
        else if (index == 1) {
            doneEnteringData()
            return true
        }
        let nextTextField = textFields[index + 1]
        nextTextField.becomeFirstResponder()
        
        return true
    }

    func doneEnteringData() {
        view.endEditing(true)
        moveScreenDown()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (keyboardSize == nil) {
            if let keyboardRect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardSize = min(keyboardRect.height, keyboardRect.width);
            }
        }
        moveScreenUp()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
