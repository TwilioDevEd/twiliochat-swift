import UIKit
import Parse

class IPMessagingManager: NSObject, TwilioAccessManagerDelegate {

    static let sharedManager = IPMessagingManager()

    var client:TwilioIPMessagingClient?
    var connected = false

    var userIdentity:String? {
        return PFUser.currentUser()?.username
    }

    var hasIdentity: Bool {
        return PFUser.currentUser() != nil && PFUser.currentUser()!.authenticated
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
    
    func registerWithUsername(
        username: String,
        password: String,
        fullName: String,
        email: String,
        completion: (Bool, NSError?) -> Void) {
            let user = PFUser()
            user.username = username
            user.email = email
            user.password = password
            user["fullName"] = fullName
            
            user.signUpInBackgroundWithBlock { succeeded, error in
                if succeeded {
                    self.connectClientWithCompletion(completion)
                    return
                }
                completion(succeeded, error)
            }
    }

    func loginWithUsername(
        username: String,
        password: String,
        completion: (Bool, NSError?) -> Void) {
            PFUser.logInWithUsernameInBackground(username, password: password) { user, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                self.connectClientWithCompletion(completion)
            }
    }

    func logout() {
        PFUser.logOut()
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
            PFCloud.callFunctionInBackground(
                "token",
                withParameters: ["device": device]) { results, error in
                    var token: String?
                    if let params = results as? NSDictionary where error == nil {
                        token = params["token"] as? String
                    }
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
            accessManager.updateToken(token)
        }
    }

    func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
        print(error.localizedDescription)
    }
}
