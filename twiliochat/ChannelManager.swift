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
        IPMessagingManager.sharedManager.client?.delegate = self;
    }

    // MARK: General channel

    func joinGeneralChatRoomWithBlock(block: Bool -> Void) {
        populateChannelsWithBlock { succeeded in
            let uniqueName = ChannelManager.defaultChannelUniqueName
            if let channelsList = self.channelsList {
                self.generalChatroom = channelsList.channelWithUniqueName(uniqueName);
            }

            if self.generalChatroom != nil {
                self.joinGeneralChatRoomWithUniqueName(nil, block: block)
                return;
            }
            else {
                self.createGeneralChatRoomWithBlock({ succeeded in
                    if (succeeded) {
                        self.joinGeneralChatRoomWithUniqueName(uniqueName, block: block)
                        return;
                    }

                    block(false)
                })
            }
        }
    }

    func joinGeneralChatRoomWithUniqueName(name: String?, block: Bool -> Void) {
        generalChatroom.joinWithCompletion { result in
            if (result == .Success) {
                if (name != nil) {
                    self.setGeneralChatRoomUniqueNameWithBlock(block)
                    return
                }
            }
            block(result == .Success);
        }
    }

    func createGeneralChatRoomWithBlock(block: Bool -> Void) {
        let channelName = ChannelManager.defaultChannelName
        channelsList!.createChannelWithFriendlyName(channelName, type: .Public, completion: { result, channel in
            if (result == .Success) {
                self.generalChatroom = channel
            }
            block(result == .Success)
        })
    }

    func setGeneralChatRoomUniqueNameWithBlock(block:Bool -> Void) {
        generalChatroom.setUniqueName(ChannelManager.defaultChannelUniqueName) { result in
            block(result == .Success)
        }
    }

    // MARK: Populate channels

    func populateChannelsWithBlock(block: Bool -> Void) {
        channels = nil

        loadChannelListWithBlock { succeeded, channelList in
            if (succeeded) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    channelList!.loadChannelsWithCompletion({ result in
                        if (result == .Success) {
                            self.channels = NSMutableOrderedSet()
                            self.channels!.addObjectsFromArray(channelList!.allObjects())
                            self.sortChannels()
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            block(true)
                        })
                    })
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.channelsList = nil
                    self.channels = nil
                    block(false)
                })
            }
        }
    }

    func loadChannelListWithBlock(block: (Bool, TWMChannels?) -> Void) {
        self.channelsList = nil

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            IPMessagingManager.sharedManager.client!.channelsListWithCompletion({ result, channelsList in
                if (result == .Success) {
                    self.channelsList = channelsList
                }
                block(result == .Success, self.channelsList)
            })
        })
    }

    func sortChannels() {
        let sortSelector = Selector("localizedCaseInsensitiveCompare:")
        let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
        channels!.sortUsingDescriptors([descriptor])
    }

    // MARK: Create channel

    func createChannelWithName(name: String, block: (Bool, TWMChannel?) -> Void) {
        if (name == ChannelManager.defaultChannelName) {
            block(false, nil)
        }

        if (channelsList == nil)
        {
            loadChannelListWithBlock({ succeeded, channelsList in
                if (succeeded) {
                    self.createChannelWithName(name, block: block)
                }
                else {
                    block(succeeded, nil)
                }
            })
            return;
        }

        self.channelsList?.createChannelWithFriendlyName(name, type: .Public, completion: { result, channel in
            block(result == .Success, channel)
        })
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
