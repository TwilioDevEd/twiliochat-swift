import UIKit

class MessagingManager: NSObject {
    
    static let _sharedManager = MessagingManager()
    
    var client:TwilioChatClient?
    var delegate:ChannelManager?
    var connected = false
    
    var userIdentity:String {
        return SessionManager.getUsername()
    }
    
    var hasIdentity: Bool {
        return SessionManager.isLoggedIn()
    }
    
    override init() {
        super.init()
        delegate = ChannelManager.sharedManager
    }
    
    class func sharedManager() -> MessagingManager {
        return _sharedManager
    }
    
    func presentRootViewController() {
        if (!hasIdentity) {
            presentViewControllerByName(viewController: "LoginViewController")
            return
        }
        
        if (!connected) {
            connectClientWithCompletion { success, error in
                print("Delegate method will load views when sync is complete")
                if (!success || error != nil) {
                    DispatchQueue.main.async {
                        self.presentViewControllerByName(viewController: "LoginViewController")
                    }
                }
            }
            return
        }
        
        presentViewControllerByName(viewController: "RevealViewController")
    }
    
    func presentViewControllerByName(viewController: String) {
        presentViewController(controller: storyBoardWithName(name: "Main").instantiateViewController(withIdentifier: viewController))
    }
    
    func presentLaunchScreen() {
        presentViewController(controller: storyBoardWithName(name: "LaunchScreen").instantiateInitialViewController()!)
    }
    
    func presentViewController(controller: UIViewController) {
        let window = UIApplication.shared.delegate!.window!!
        window.rootViewController = controller
    }
    
    func storyBoardWithName(name:String) -> UIStoryboard {
        return UIStoryboard(name:name, bundle: Bundle.main)
    }
    
    // MARK: User and session management
    
    func loginWithUsername(username: String,
                           completion: @escaping (Bool, NSError?) -> Void) {
        SessionManager.loginWithUsername(username: username)
        connectClientWithCompletion(completion: completion)
    }
    
    func logout() {
        SessionManager.logout()
        DispatchQueue.global(qos: .userInitiated).async {
            self.client?.shutdown()
            self.client = nil
        }
        self.connected = false
    }
    
    // MARK: Twilio Client
    
    func loadGeneralChatRoomWithCompletion(completion:@escaping (Bool, NSError?) -> Void) {
        ChannelManager.sharedManager.joinGeneralChatRoomWithCompletion { succeeded in
            if succeeded {
                completion(succeeded, nil)
            }
            else {
                let error = self.errorWithDescription(description: "Could not join General channel", code: 300)
                completion(succeeded, error)
            }
        }
    }
    
    func connectClientWithCompletion(completion: @escaping (Bool, NSError?) -> Void) {
        if (client != nil) {
            logout()
        }
        
        requestTokenWithCompletion { succeeded, token in
            if let token = token, succeeded {
                self.initializeClientWithToken(token: token)
                completion(succeeded, nil)
            }
            else {
                let error = self.errorWithDescription(description: "Could not get access token", code:301)
                completion(succeeded, error)
            }
        }
    }
    
    func initializeClientWithToken(token: String) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        TwilioChatClient.chatClient(withToken: token, properties: nil, delegate: self) { [weak self] result, chatClient in
            guard (result.isSuccessful()) else { return }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self?.connected = true
            self?.client = chatClient
        }
    }
    
    func requestTokenWithCompletion(completion:@escaping (Bool, String?) -> Void) {
        if let device = UIDevice.current.identifierForVendor?.uuidString {
            TokenRequestHandler.fetchToken(params: ["device": device, "identity":SessionManager.getUsername()]) {response,error in
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

// MARK: - TwilioChatClientDelegate
extension MessagingManager : TwilioChatClientDelegate {
    func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {
        self.delegate?.chatClient(client, channelAdded: channel)
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, updated: TCHChannelUpdate) {
        self.delegate?.chatClient(client, channel: channel, updated: updated)
    }
    
    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        self.delegate?.chatClient(client, channelDeleted: channel)
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        if status == TCHClientSynchronizationStatus.completed {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            ChannelManager.sharedManager.channelsList = client.channelsList()
            ChannelManager.sharedManager.populateChannelDescriptors()
            loadGeneralChatRoomWithCompletion { success, error in
                if success {
                    self.presentRootViewController()
                }
            }
        }
        self.delegate?.chatClient(client, synchronizationStatusUpdated: status)
    }
    
    func chatClientTokenWillExpire(_ client: TwilioChatClient) {
        requestTokenWithCompletion { succeeded, token in
            if (succeeded) {
                client.updateToken(token!)
            }
            else {
                print("Error while trying to get new access token")
            }
        }
    }
    
    func chatClientTokenExpired(_ client: TwilioChatClient) {
        requestTokenWithCompletion { succeeded, token in
            if (succeeded) {
                client.updateToken(token!)
            }
            else {
                print("Error while trying to get new access token")
            }
        }
    }
}
