import UIKit

class ChannelManager: NSObject {
    static let sharedManager = ChannelManager()
    
    static let defaultChannelUniqueName = "general"
    static let defaultChannelName = "General Channel"
    
    weak var delegate:MenuViewController?
    
    var channelsList:TCHChannels?
    var channels:NSMutableOrderedSet?
    var generalChannel:TCHChannel!
    
    override init() {
        super.init()
        channels = NSMutableOrderedSet()
    }
    
    // MARK: - General channel
    
    func joinGeneralChatRoomWithCompletion(completion: @escaping (Bool) -> Void) {
        
        let uniqueName = ChannelManager.defaultChannelUniqueName
        if let channelsList = self.channelsList {
            channelsList.channel(withSidOrUniqueName: uniqueName) { result, channel in
                self.generalChannel = channel
                
                if self.generalChannel != nil {
                    self.joinGeneralChatRoomWithUniqueName(name: nil, completion: completion)
                } else {
                    self.createGeneralChatRoomWithCompletion { succeeded in
                        if (succeeded) {
                            self.joinGeneralChatRoomWithUniqueName(name: uniqueName, completion: completion)
                            return
                        }
                        
                        completion(false)
                    }
                }
            }
        }
    }
    
    func joinGeneralChatRoomWithUniqueName(name: String?, completion: @escaping (Bool) -> Void) {
        generalChannel.join { result in
            if ((result.isSuccessful()) && name != nil) {
                self.setGeneralChatRoomUniqueNameWithCompletion(completion: completion)
                return
            }
            completion((result.isSuccessful()))
        }
    }
    
    func createGeneralChatRoomWithCompletion(completion: @escaping (Bool) -> Void) {
        let channelName = ChannelManager.defaultChannelName
        let options = [
            TCHChannelOptionFriendlyName: channelName,
            TCHChannelOptionType: TCHChannelType.public.rawValue
            ] as [String : Any]
        channelsList!.createChannel(options: options) { result, channel in
            if (result.isSuccessful()) {
                self.generalChannel = channel
            }
            completion((result.isSuccessful()))
        }
    }
    
    func setGeneralChatRoomUniqueNameWithCompletion(completion:@escaping (Bool) -> Void) {
        generalChannel.setUniqueName(ChannelManager.defaultChannelUniqueName) { result in
            completion((result.isSuccessful()))
        }
    }
    
    // MARK: - Populate channels
    
    func populateChannels() {
        
        channelsList?.userChannelDescriptors { result, paginator in
            let newChannels = NSMutableOrderedSet()
            newChannels.addObjects(from: paginator!.items())
            self.channelsList?.publicChannelDescriptors { result, paginator in
                newChannels.addObjects(from: paginator!.items())
                self.channels = newChannels
                self.sortChannels()
                if let delegate = self.delegate {
                    delegate.reloadChannelList()
                }
            }
        }
    }
    
    func sortChannels() {
        guard let channels = channels else {
            return
        }
        
        let sortSelector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
        let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
        channels.sort(using: [descriptor])
    }
    
    // MARK: - Create channel
    
    func createChannelWithName(name: String, completion: @escaping (Bool, TCHChannel?) -> Void) {
        if (name == ChannelManager.defaultChannelName) {
            completion(false, nil)
            return
        }
        
        let channelOptions = [
            TCHChannelOptionFriendlyName: name,
            TCHChannelOptionType: TCHChannelType.public.rawValue
        ] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        self.channelsList?.createChannel(options: channelOptions) { result, channel in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion((result.isSuccessful()), channel)
        }
    }
}

// MARK: - TwilioChatClientDelegate
extension ChannelManager : TwilioChatClientDelegate {
    func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {
        DispatchQueue.main.async {
            if self.channels != nil {
                self.populateChannels()
            }
            self.delegate?.chatClient(client, channelAdded: channel)
        }
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, updated: TCHChannelUpdate) {
        self.delegate?.chatClient(client, channel: channel, updated: updated)
    }
    
    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        DispatchQueue.main.async {
            self.populateChannels()
            self.delegate?.chatClient(client, channelDeleted: channel)
        }
        
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
    }
}
