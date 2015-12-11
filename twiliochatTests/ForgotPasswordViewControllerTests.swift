import XCTest
import Parse
@testable import twiliochat

class ForgotPasswordViewControllerTests: XCTestCase {
  var viewController: ForgotPasswordViewController!

  override func setUp() {
    super.setUp()
    let storyBoard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
    viewController = storyBoard.instantiateViewControllerWithIdentifier("ForgotPasswordViewController") as! ForgotPasswordViewController
  }

  override func tearDown() {
    super.tearDown()
    MockPFUser.requestPasswordCalled = false
    MockAlertDialogController.showedAlertWithMessage = ""
  }

  func testStartPasswordRecovery() {
    viewController.pfUserClass = MockPFUser.self
    viewController.loadView()
    viewController.emailTextField.text = "my email"
    viewController.startPasswordRecovery()

    let mockPFUser = viewController.pfUserClass as! MockPFUser.Type

    XCTAssertTrue(mockPFUser.requestPasswordCalled)
  }

  func testStartPasswordRecoveryEmptyField() {
    viewController.pfUserClass = MockPFUser.self
    viewController.alertDialogControllerClass = MockAlertDialogController.self
    viewController.loadView()
    viewController.startPasswordRecovery()

    let mockPFUser = viewController.pfUserClass as! MockPFUser.Type
    let mockAlerDiagloController = viewController.alertDialogControllerClass as! MockAlertDialogController.Type

    XCTAssertFalse(mockPFUser.requestPasswordCalled)
    XCTAssertEqual(mockAlerDiagloController.showedAlertWithMessage, "Your email is required")
  }
}
