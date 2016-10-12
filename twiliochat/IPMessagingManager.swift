import UIKit

class IPMessagingManager: NSObject {

  static let _sharedManager = IPMessagingManager()

  var client:TwilioIPMessagingClient?
  var delegate:ChannelManager?
  var connected = false

  var userIdentity:String {
    return SessionManager.getUsername()
  }

  var hasIdentity: Bool {
    return SessionManager.isLoogedIn()
  }
  
  override init() {
    super.init()
    delegate = ChannelManager.sharedManager
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
        print("Delegate method will load views when sync is complete")
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
      }
      else {
        let error = self.errorWithDescription("Could not get access token", code:301)
        completion(succeeded, error)
      }
    }
  }

  func initializeClientWithToken(token: String) {
    let accessManager = TwilioAccessManager(token:token, delegate:self)
    client = TwilioIPMessagingClient.ipMessagingClientWithAccessManager(accessManager, properties: nil, delegate: self)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    self.connected = true
  }

  func loadGeneralChatRoomWithCompletion(completion:(Bool, NSError?) -> Void) {
    ChannelManager.sharedManager.joinGeneralChatRoomWithCompletion { succeeded in
      if succeeded {
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
}

// MARK: - TwilioIPMessagingClientDelegate
extension IPMessagingManager : TwilioIPMessagingClientDelegate {
  func ipMessagingClient(client: TwilioIPMessagingClient!, channelAdded channel: TWMChannel!) {
    self.delegate?.ipMessagingClient(client, channelAdded: channel)
  }
  
  func ipMessagingClient(client: TwilioIPMessagingClient!, channelChanged channel: TWMChannel!) {
    self.delegate?.ipMessagingClient(client, channelChanged: channel)
  }
  
  func ipMessagingClient(client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
    self.delegate?.ipMessagingClient(client, channelDeleted: channel)
  }
  
  func ipMessagingClient(client: TwilioIPMessagingClient!, synchronizationStatusChanged status: TWMClientSynchronizationStatus) {
    if status == TWMClientSynchronizationStatus.Completed {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      ChannelManager.sharedManager.channelsList = client.channelsList()
      ChannelManager.sharedManager.populateChannels()
      loadGeneralChatRoomWithCompletion { success, error in
        if success {
          self.presentRootViewController()
        }
      }
    }
    self.delegate?.ipMessagingClient(client, synchronizationStatusChanged: status)
  }
}

// MARK: - TwilioAccessManagerDelegate
extension IPMessagingManager : TwilioAccessManagerDelegate {
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
