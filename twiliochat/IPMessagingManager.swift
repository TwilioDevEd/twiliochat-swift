import UIKit
import Parse

class IPMessagingManager: NSObject, TwilioAccessManagerDelegate {

    static let sharedManager = IPMessagingManager()

    var client:TwilioIPMessagingClient?
    var connected = false

    var userIdentity:String? {
        return PFUser.currentUser()?.username;
    }

    var hasIdentity: Bool {
        return PFUser.currentUser() != nil && PFUser.currentUser()!.authenticated
    }

    func presentRootViewController() {
        if (hasIdentity) {
            if (connected) {
                presentViewControllerByName("RevealViewController");
            }
            else {
                connectClient({ success, error in
                    if success {
                        self.presentViewControllerByName("RevealViewController")
                    }
                    else {
                        self.presentViewControllerByName("LoginViewController")
                    }
                })
            }
        }
        else {
            presentViewControllerByName("LoginViewController");
        }
    }

    func presentViewControllerByName(viewController: String) {
        presentViewController(storyBoardWithName("Main").instantiateViewControllerWithIdentifier(viewController));
    }

    func presentLaunchScreen() {
        presentViewController(storyBoardWithName("LaunchScreen").instantiateInitialViewController()!);
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
        handler: (Bool, NSError?) -> Void) {
            let user = PFUser()
            user.username = username
            user.email = email
            user.password = password
            user["fullName"] = fullName
            
            user.signUpInBackgroundWithBlock { succeeded, error in
                if succeeded {
                    self.connectClient(handler)
                }
                else {
                    handler(succeeded, error)
                }
            }
    }

    func loginWithUsername(
        username: String,
        password: String,
        handler: (Bool, NSError?) -> Void) {
            PFUser.logInWithUsernameInBackground(username, password: password) { user, error in
                if let error = error {
                    handler(false, error)
                }
                else {
                    self.connectClient(handler)
                }
            }
    }

    func logout() {
        PFUser.logOut()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.client?.shutdown()
            self.client = nil
        })
        self.connected = false
    }

    // MARK: Twilio Client

    func connectClient(handler: (Bool, NSError?) -> Void) {
        if (client != nil) {
            logout()
        }
        
        requestTokenWithBlock { succeeded, token in
            if let token = token where succeeded {
                self.initializeClientWithToken(token)
                self.loadGeneralChatRoom(handler)
            }
            else {
                let error = self.errorWithDescription("Could not get access token", code:301);
                handler(succeeded, error);
            }
        }
    }

    func initializeClientWithToken(token: String) {
        let accessManager = TwilioAccessManager(token:token, delegate:self)
        client = TwilioIPMessagingClient.ipMessagingClientWithAccessManager(accessManager, delegate: nil)
    }

    func loadGeneralChatRoom(handler:(Bool, NSError?) -> Void) {
        ChannelManager.sharedManager.joinGeneralChatRoomWithBlock { succeeded in
            if succeeded {
                self.connected = true
                handler(succeeded, nil)
            }
            else {
                let error = self.errorWithDescription("Could not join General channel", code: 300)
                handler(succeeded, error)
            }
        }
    }

    func requestTokenWithBlock(handler:(Bool, String?) -> Void) {
        if let device = UIDevice.currentDevice().identifierForVendor?.UUIDString {
            PFCloud.callFunctionInBackground(
                "token",
                withParameters: ["device": device],
                block: { results, error in
                    if let params = results as? NSDictionary, token = params["token"] as? String where error == nil {
                        handler(true, token)
                    }
                    else {
                        handler(false, nil)
                    }
                }
            )
        }
    }

    func errorWithDescription(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : description];
        return NSError(domain: "app", code: code, userInfo: userInfo)
    }

    // MARK: TwilioAccessManagerDelegate

    func accessManagerTokenExpired(accessManager: TwilioAccessManager!) {
        requestTokenWithBlock { succeeded, token in
            accessManager.updateToken(token)
        }
    }

    func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
        print(error.localizedDescription)
    }
}
