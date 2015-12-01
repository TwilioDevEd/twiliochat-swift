import UIKit
import Parse

class IPMessagingManager: NSObject {
    
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
                connectClient({ (success, error) -> Void in
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
    
    func registerWithUsername(
        username: String,
        password: String,
        fullName: String,
        email: String,
        handler: ((Bool, NSError?) -> Void)) {
            let user = PFUser()
            user.username = username
            user.email = email
            user.password = password
            user["fullName"] = fullName
            
            user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
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
        handler: ((Bool, NSError?) -> Void)) {
            PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
                if let error = error {
                    handler(false, error)
                }
                else {
                    self.connectClient(handler)
                }
            }
    }
    
    func connectClient(handler:((Bool, NSError?) -> Void)) {
        if (client != nil) {
            logout()
        }
        
        if let device = UIDevice.currentDevice().identifierForVendor?.UUIDString {
            PFCloud.callFunctionInBackground(
                "token",
                withParameters: ["device": device],
                block: { (results, error) -> Void in
                    if let params = results as? NSDictionary, token = params["token"] as? String where error == nil {
                        self.client = TwilioIPMessagingClient.ipMessagingClientWithToken(token, delegate: nil)
                        self.connected = true
                        handler(true, nil)
                    }
                    else {
                        handler(false, error)
                    }
                }
            )
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
    
    /*- (void)updatePushToken:(NSData *)token {
    self.lastToken = token;
    [self updateIpMessagingClient];
    }
    
    - (void)receivedNotification:(NSDictionary *)notification {
    self.lastNotification = notification;
    [self updateIpMessagingClient];
    }
    
    
    // Mark: Push functionality
    
    - (void)updateIpMessagingClient {
    if (self.lastToken) {
    [self.client registerWithToken:self.lastToken];
    self.lastToken = nil;
    }
    
    if (self.lastNotification) {
    [self.client handleNotification:self.lastNotification];
    self.lastNotification = nil;
    }
    }*/
}
