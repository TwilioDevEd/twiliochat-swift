import XCTest
@testable import twiliochat

class LoginViewControllerTests: XCTestCase {
    var viewController: LoginViewController!
    
    override func setUp() {
        super.setUp()
        let storyBoard = UIStoryboard(name:"Main", bundle: Bundle.main)
        viewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.loadView()
        viewController.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
        MockMessagingManager.loginWithUsernameCalled = false
        MockMessagingManager.registerWithUsernameCalled = false
        MockMessagingManager.usernameUsed = ""
        MockMessagingManager.passwordUsed = ""
        MockAlertDialogController.showedAlertWithMessage = ""
    }
    
    func testLoginUser() {
        viewController.usernameTextField.text = "username"
        viewController.MessagingClientClass = MockMessagingManager.self
        
        viewController.loginUser()
        
        XCTAssertTrue(MockMessagingManager.loginWithUsernameCalled)
        XCTAssertEqual(MockMessagingManager.usernameUsed, "username")
    }
    
    func testSignUpOrLoginEmptyFields() {
        viewController.MessagingClientClass = MockMessagingManager.self
        viewController.alertDialogControllerClass = MockAlertDialogController.self
        viewController.loginUser()
        
        XCTAssertEqual(MockAlertDialogController.showedAlertWithMessage, "All fields are required")
        XCTAssertFalse(MockMessagingManager.loginWithUsernameCalled)
    }
    
    func testSignUpOrLoginIsLoginIn() {
        viewController.usernameTextField.text = "username"
        viewController.MessagingClientClass = MockMessagingManager.self
        viewController.loginUser()
        
        XCTAssertTrue(MockMessagingManager.loginWithUsernameCalled)
    }
}
