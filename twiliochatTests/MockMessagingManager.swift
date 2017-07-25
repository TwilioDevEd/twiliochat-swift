import UIKit
@testable import twiliochat

class MockMessagingManager: MessagingManager {
    static let mockManager = MockMessagingManager()
    
    static var loginWithUsernameCalled = false
    static var registerWithUsernameCalled = false
    static var passwordUsed = ""
    static var usernameUsed = ""
    
    override class func sharedManager() -> MessagingManager {
        return mockManager
    }
    
    override func loginWithUsername(username: String,
                                    completion: @escaping (Bool, NSError?) -> Void) {
        MockMessagingManager.loginWithUsernameCalled = true
        MockMessagingManager.usernameUsed = username
    }
}
