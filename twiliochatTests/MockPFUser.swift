import UIKit
import Parse

class MockPFUser: PFUser {
  static var requestPasswordCalled = false

  override class func requestPasswordResetForEmailInBackground(email: String, block: PFBooleanResultBlock?) {
    requestPasswordCalled = true
  }
}
