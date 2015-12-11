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
    
  }
}
