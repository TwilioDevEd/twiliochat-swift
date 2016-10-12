//import UIKit
//@testable import twiliochat
//
//class MockIPMessagingManager: IPMessagingManager {
//  static let mockManager = MockIPMessagingManager()
//
//  static var loginWithUsernameCalled = false
//  static var registerWithUsernameCalled = false
//  static var passwordUsed = ""
//  static var usernameUsed = ""
//
//  override class func sharedManager() -> IPMessagingManager {
//    return mockManager
//  }
//
//  override func loginWithUsername(username: String,
//    completion: (Bool, NSError?) -> Void) {
//      MockIPMessagingManager.loginWithUsernameCalled = true
//      MockIPMessagingManager.usernameUsed = username
//  }
//}
