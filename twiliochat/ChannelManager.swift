class ChannelManager: NSObject, TwilioIPMessagingClientDelegate {
    static let sharedManager = ChannelManager()

    static let defaultChannelUniqueName = "general"
    static let defaultChannelName = "General Channel"

    weak var delegate:TwilioIPMessagingClientDelegate?

    var channelsList:TWMChannels?
    var channels:NSMutableOrderedSet?
    var generalChatroom:TWMChannel!

    override init() {
        super.init()
        IPMessagingManager.sharedManager.client?.delegate = self
    }

    // MARK: General channel

    func joinGeneralChatRoomWithCompletion(completion: Bool -> Void) {
        populateChannelsWithCompletion { succeeded in
            let uniqueName = ChannelManager.defaultChannelUniqueName
            if let channelsList = self.channelsList {
                self.generalChatroom = channelsList.channelWithUniqueName(uniqueName)
            }

            if self.generalChatroom != nil {
                self.joinGeneralChatRoomWithUniqueName(nil, completion: completion)
                return
            }

            self.createGeneralChatRoomWithCompletion { succeeded in
                if (succeeded) {
                    self.joinGeneralChatRoomWithUniqueName(uniqueName, completion: completion)
                    return
                }
                
                completion(false)
            }
        }
    }

    func joinGeneralChatRoomWithUniqueName(name: String?, completion: Bool -> Void) {
        generalChatroom.joinWithCompletion { result in
            if (result == .Success && name != nil) {
                self.setGeneralChatRoomUniqueNameWithCompletion(completion)
                return
            }
            completion(result == .Success)
        }
    }

    func createGeneralChatRoomWithCompletion(completion: Bool -> Void) {
        let channelName = ChannelManager.defaultChannelName
        channelsList!.createChannelWithFriendlyName(channelName, type: .Public) { result, channel in
            if (result == .Success) {
                self.generalChatroom = channel
            }
            completion(result == .Success)
        }
    }

    func setGeneralChatRoomUniqueNameWithCompletion(completion:Bool -> Void) {
        generalChatroom.setUniqueName(ChannelManager.defaultChannelUniqueName) { result in
            completion(result == .Success)
        }
    }

    // MARK: Populate channels

    func populateChannelsWithCompletion(completion: Bool -> Void) {
        channels = nil

        loadChannelListWithCompletion { succeeded, channelList in
            if (!succeeded) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.channelsList = nil
                    self.channels = nil
                    completion(false)
                })
                return;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                channelList!.loadChannelsWithCompletion { result in
                    if (result == .Success) {
                        self.channels = NSMutableOrderedSet()
                        self.channels!.addObjectsFromArray(channelList!.allObjects())
                        self.sortChannels()
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(result == .Success)
                    }
                }
            }
        }
    }

    func loadChannelListWithCompletion(completion: (Bool, TWMChannels?) -> Void) {
        self.channelsList = nil

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            IPMessagingManager.sharedManager.client!.channelsListWithCompletion { result, channelsList in
                if (result == .Success) {
                    self.channelsList = channelsList
                }
                completion(result == .Success, self.channelsList)
            }
        }
    }

    func sortChannels() {
        let sortSelector = Selector("localizedCaseInsensitiveCompare:")
        let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
        channels!.sortUsingDescriptors([descriptor])
    }

    // MARK: Create channel

    func createChannelWithName(name: String, completion: (Bool, TWMChannel?) -> Void) {
        if (name == ChannelManager.defaultChannelName) {
            completion(false, nil)
            return
        }

        if (channelsList == nil)
        {
            loadChannelListWithCompletion { succeeded, channelsList in
                if (succeeded) {
                    self.createChannelWithName(name, completion: completion)
                    return
                }
                completion(succeeded, nil)
            }
            return
        }

        self.channelsList?.createChannelWithFriendlyName(name, type: .Public) { result, channel in
            completion(result == .Success, channel)
        }
    }

    // MARK: TwilioIPMessagingClientDelegate

    func ipMessagingClient(client: TwilioIPMessagingClient!, channelAdded channel: TWMChannel!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.channels!.addObject(channel)
            self.sortChannels()
            self.delegate?.ipMessagingClient?(client, channelAdded: channel)
        })
    }

    func ipMessagingClient(client: TwilioIPMessagingClient!, channelChanged channel: TWMChannel!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.ipMessagingClient?(client, channelChanged: channel)
        })
    }

    func ipMessagingClient(client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.channels?.removeObject(channel)
            self.delegate?.ipMessagingClient?(client, channelDeleted: channel)
        })
    }
}
