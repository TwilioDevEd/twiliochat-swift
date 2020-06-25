import UIKit

protocol ChannelManagerDelegate {
    func reloadChannelDescriptorList()
}

class ChannelManager: NSObject {
    static let sharedManager = ChannelManager()
    
    static let defaultChannelUniqueName = "general"
    static let defaultChannelName = "General Channel"
    
    var delegate:ChannelManagerDelegate?
    
    var channelsList:TCHChannels?
    var channelDescriptors:NSOrderedSet?
    var generalChannel:TCHChannel!
    
    override init() {
        super.init()
        channelDescriptors = NSMutableOrderedSet()
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
    
    // MARK: - Populate channel Descriptors
    
    func populateChannelDescriptors() {
        
        channelsList?.userChannelDescriptors { result, paginator in
            guard let paginator = paginator else {
                return
            }

            let newChannelDescriptors = NSMutableOrderedSet()
            newChannelDescriptors.addObjects(from: paginator.items())
            self.channelsList?.publicChannelDescriptors { result, paginator in
                guard let paginator = paginator else {
                    return
                }

                // de-dupe channel list
                let channelIds = NSMutableSet()
                for descriptor in newChannelDescriptors {
                    if let descriptor = descriptor as? TCHChannelDescriptor {
                        if let sid = descriptor.sid {
                            channelIds.add(sid)
                        }
                    }
                }
                for descriptor in paginator.items() {
                    if let sid = descriptor.sid {
                        if !channelIds.contains(sid) {
                            channelIds.add(sid)
                            newChannelDescriptors.add(descriptor)
                        }
                    }
                }
                
                
                // sort the descriptors
                let sortSelector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
                let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
                newChannelDescriptors.sort(using: [descriptor])
                
                self.channelDescriptors = newChannelDescriptors
                
                if let delegate = self.delegate {
                    delegate.reloadChannelDescriptorList()
                }
            }
        }
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
            self.populateChannelDescriptors()
        }
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, updated: TCHChannelUpdate) {
        DispatchQueue.main.async {
            self.delegate?.reloadChannelDescriptorList()
        }
    }
    
    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        DispatchQueue.main.async {
            self.populateChannelDescriptors()
        }
        
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
    }
}
