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
    MockIPMessagingManager.usernameUsed = ""
    MockIPMessagingManager.passwordUsed = ""
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
}
