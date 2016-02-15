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

  func testLoginUser() {
    viewController.usernameTextField.text = "username"
    viewController.ipMessagingClientClass = MockIPMessagingManager.self

    viewController.loginUser()

    XCTAssertTrue(MockIPMessagingManager.loginWithUsernameCalled)
    XCTAssertEqual(MockIPMessagingManager.usernameUsed, "username")
  }

  func testSignUpOrLoginEmptyFields() {
    viewController.ipMessagingClientClass = MockIPMessagingManager.self
    viewController.alertDialogControllerClass = MockAlertDialogController.self
    viewController.loginUser()

    XCTAssertEqual(MockAlertDialogController.showedAlertWithMessage, "All fields are required")
    XCTAssertFalse(MockIPMessagingManager.loginWithUsernameCalled)
  }

  func testSignUpOrLoginIsLoginIn() {
    viewController.usernameTextField.text = "username"
    viewController.ipMessagingClientClass = MockIPMessagingManager.self
    viewController.loginUser()

    XCTAssertTrue(MockIPMessagingManager.loginWithUsernameCalled)
  }
}
