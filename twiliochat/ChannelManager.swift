import UIKit

class ChannelManager: NSObject {
  static let sharedManager = ChannelManager()

  static let defaultChannelUniqueName = "general"
  static let defaultChannelName = "General Channel"

  weak var delegate:MenuViewController?

  var channelsList:TWMChannels?
  var channels:NSMutableOrderedSet?
  var generalChannel:TWMChannel!

  override init() {
    super.init()
    channels = NSMutableOrderedSet()
  }

  // MARK: - General channel

  func joinGeneralChatRoomWithCompletion(completion: Bool -> Void) {

    let uniqueName = ChannelManager.defaultChannelUniqueName
    if let channelsList = self.channelsList {
      self.generalChannel = channelsList.channelWithUniqueName(uniqueName)
    }

    if self.generalChannel != nil {
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

  func joinGeneralChatRoomWithUniqueName(name: String?, completion: Bool -> Void) {
    generalChannel.joinWithCompletion { result in
      if (result.isSuccessful() && name != nil) {
        self.setGeneralChatRoomUniqueNameWithCompletion(completion)
        return
      }
      completion(result.isSuccessful())
    }
  }

  func createGeneralChatRoomWithCompletion(completion: Bool -> Void) {
    let channelName = ChannelManager.defaultChannelName
    let options:[NSObject : AnyObject] = [TWMChannelOptionFriendlyName: channelName, TWMChannelOptionType: TWMChannelType.Public.rawValue]
    channelsList!.createChannelWithOptions(options) { result, channel in
      if result.isSuccessful() {
        self.generalChannel = channel
      }
      completion(result.isSuccessful())
    }
  }

  func setGeneralChatRoomUniqueNameWithCompletion(completion:Bool -> Void) {
    generalChannel.setUniqueName(ChannelManager.defaultChannelUniqueName) { result in
      completion(result.isSuccessful())
    }
  }

  // MARK: - Populate channels
  
  func populateChannels() {
    channels = NSMutableOrderedSet()
    if let channels = channelsList?.allObjects() {
      self.channels?.addObjectsFromArray(channels)
      sortChannels()
    }
    
    if self.delegate != nil {
      self.delegate!.reloadChannelList()
    }
  }

  func sortChannels() {
    let sortSelector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
    let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
    channels!.sortUsingDescriptors([descriptor])
  }

  // MARK: - Create channel

  func createChannelWithName(name: String, completion: (Bool, TWMChannel?) -> Void) {
    if (name == ChannelManager.defaultChannelName) {
      completion(false, nil)
      return
    }

    let channelOptions:[NSObject : AnyObject] = [
      TWMChannelOptionFriendlyName: name, TWMChannelOptionType: TWMChannelType.Public.rawValue
    ]
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
    self.channelsList?.createChannelWithOptions(channelOptions) { result, channel in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
      completion(result.isSuccessful(), channel)
    }
  }
}

// MARK: - TwilioIPMessagingClientDelegate
extension ChannelManager : TwilioIPMessagingClientDelegate {
  func ipMessagingClient(client: TwilioIPMessagingClient!, channelAdded channel: TWMChannel!) {
    dispatch_async(dispatch_get_main_queue(), {
      if self.channels != nil {
        self.channels!.addObject(channel)
        self.sortChannels()
      }
      self.delegate?.ipMessagingClient(client, channelAdded: channel)
    })
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channelChanged channel: TWMChannel!) {
    self.delegate?.ipMessagingClient(client, channelChanged: channel)
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
    dispatch_async(dispatch_get_main_queue(), {
      if self.channels != nil {
        self.channels?.removeObject(channel)
      }
      self.delegate?.ipMessagingClient(client, channelDeleted: channel)
    })

  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, synchronizationStatusChanged status: TWMClientSynchronizationStatus) {
  }
}
