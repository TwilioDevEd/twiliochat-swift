import XCTest
@testable import twiliochat

class LoginViewControllerTests: XCTestCase {
  var viewController: LoginViewController!

  override func setUp() {
    super.setUp()
    let storyBoard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
    viewController = storyBoard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    viewController.loadView()
    viewController.viewDidLoad()
  }

  override func tearDown() {
    super.tearDown()
    MockIPMessagingManager.loginWithUsernameCalled = false
    MockIPMessagingManager.registerWithUsernameCalled = false
    MockIPMessagingManager.usernameUsed = ""
    MockIPMessagingManager.passwordUsed = ""
    MockAlertDialogController.showedAlertWithMessage = ""
  }

  func testToggleSignUpMode() {
    let loginButton = viewController.loginButton
    let createAccountButton = viewController.createAccountButton
    XCTAssertEqual(loginButton.currentTitle, "Login")
    XCTAssertFalse(viewController.isSigningUp)
    XCTAssertEqual(createAccountButton.currentTitle, "Create account")

    viewController.toggleSignUpMode()

    XCTAssertEqual(loginButton.currentTitle, "Register")
    XCTAssertTrue(viewController.isSigningUp)
    XCTAssertEqual(createAccountButton.currentTitle, "Back to login")
  }

  func testLoginUser() {
    viewController.usernameTextField.text = "username"
    viewController.passwordTextField.text = "password"
    viewController.ipMessagingClientClass = MockIPMessagingManager.self

    viewController.loginUser()

    XCTAssertTrue(MockIPMessagingManager.loginWithUsernameCalled)
    XCTAssertEqual(MockIPMessagingManager.usernameUsed, "username")
    XCTAssertEqual(MockIPMessagingManager.passwordUsed, "password")
  }

  func testSignUpOrLoginEmptyFields() {
    viewController.ipMessagingClientClass = MockIPMessagingManager.self
    viewController.alertDialogControllerClass = MockAlertDialogController.self
    viewController.signUpOrLogin()

    XCTAssertEqual(MockAlertDialogController.showedAlertWithMessage, "All fields are required")
    XCTAssertFalse(MockIPMessagingManager.loginWithUsernameCalled)
  }

  func testSignUpOrLoginIsLoginIn() {
    viewController.usernameTextField.text = "username"
    viewController.passwordTextField.text = "password"
    viewController.ipMessagingClientClass = MockIPMessagingManager.self
    viewController.signUpOrLogin()

    XCTAssertTrue(MockIPMessagingManager.loginWithUsernameCalled)
  }

  func testSignUpOrLoginIsSigningUp() {
    viewController.usernameTextField.text = "username"
    viewController.passwordTextField.text = "password"
    viewController.fullNameTextField.text = "full name"
    viewController.emailTextField.text = "email"
    viewController.ipMessagingClientClass = MockIPMessagingManager.self

    viewController.toggleSignUpMode()
    viewController.signUpOrLogin()

    XCTAssertTrue(MockIPMessagingManager.registerWithUsernameCalled)
    XCTAssertEqual(MockIPMessagingManager.usernameUsed, "username")
    XCTAssertEqual(MockIPMessagingManager.passwordUsed, "password")
  }
}
