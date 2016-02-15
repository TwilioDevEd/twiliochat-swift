import UIKit

class IPMessagingManager: NSObject, TwilioAccessManagerDelegate {

  static let _sharedManager = IPMessagingManager()

  var client:TwilioIPMessagingClient?
  var connected = false

  var userIdentity:String {
    return SessionManager.getUsername()
  }

  var hasIdentity: Bool {
    return SessionManager.isLoogedIn()
  }

  class func sharedManager() -> IPMessagingManager {
    return _sharedManager
  }

  func presentRootViewController() {
    if (!hasIdentity) {
      presentViewControllerByName("LoginViewController")
      return
    }

    if (!connected) {
      connectClientWithCompletion { success, error in
        let viewController = success ? "RevealViewController" : "LoginViewController"
        self.presentViewControllerByName(viewController)
      }
      return
    }

    presentViewControllerByName("RevealViewController")
  }

  func presentViewControllerByName(viewController: String) {
    presentViewController(storyBoardWithName("Main").instantiateViewControllerWithIdentifier(viewController))
  }

  func presentLaunchScreen() {
    presentViewController(storyBoardWithName("LaunchScreen").instantiateInitialViewController()!)
  }

  func presentViewController(controller: UIViewController) {
    let window = UIApplication.sharedApplication().delegate!.window!!
    window.rootViewController = controller
  }

  func storyBoardWithName(name:String) -> UIStoryboard {
    return UIStoryboard(name:name, bundle: NSBundle.mainBundle())
  }

  // MARK: User and session management

  func loginWithUsername(username: String,
    completion: (Bool, NSError?) -> Void) {
      SessionManager.loginWithUsername(username)
      connectClientWithCompletion(completion)
  }

  func logout() {
    SessionManager.logout()
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.client?.shutdown()
      self.client = nil
    }
    self.connected = false
  }

  // MARK: Twilio Client

  func connectClientWithCompletion(completion: (Bool, NSError?) -> Void) {
    if (client != nil) {
      logout()
    }

    requestTokenWithCompletion { succeeded, token in
      if let token = token where succeeded {
        self.initializeClientWithToken(token)
        self.loadGeneralChatRoomWithCompletion(completion)
      }
      else {
        let error = self.errorWithDescription("Could not get access token", code:301)
        completion(succeeded, error)
      }
    }
  }

  func initializeClientWithToken(token: String) {
    let accessManager = TwilioAccessManager(token:token, delegate:self)
    client = TwilioIPMessagingClient.ipMessagingClientWithAccessManager(accessManager, delegate: nil)
  }

  func loadGeneralChatRoomWithCompletion(completion:(Bool, NSError?) -> Void) {
    ChannelManager.sharedManager.joinGeneralChatRoomWithCompletion { succeeded in
      if succeeded {
        self.connected = true
        completion(succeeded, nil)
      }
      else {
        let error = self.errorWithDescription("Could not join General channel", code: 300)
        completion(succeeded, error)
      }
    }
  }

  func requestTokenWithCompletion(completion:(Bool, String?) -> Void) {
    if let device = UIDevice.currentDevice().identifierForVendor?.UUIDString {
      TokenRequestHandler.fetchToken(["device": device, "identity":SessionManager.getUsername()]) {response,error in
        var token: String?
        token = response["token"] as? String
        completion(token != nil, token)
      }
    }
  }

  func errorWithDescription(description: String, code: Int) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey : description]
    return NSError(domain: "app", code: code, userInfo: userInfo)
  }

  // MARK: TwilioAccessManagerDelegate

  func accessManagerTokenExpired(accessManager: TwilioAccessManager!) {
    requestTokenWithCompletion { succeeded, token in
      if (succeeded) {
        accessManager.updateToken(token)
      }
      else {
        print("Error while trying to get new access token")
      }
    }
  }

  func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
    print("Access manager error: \(error.localizedDescription)")
  }
}
