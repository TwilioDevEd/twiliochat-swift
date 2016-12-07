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

  func joinGeneralChatRoomWithCompletion(completion: @escaping (Bool) -> Void) {

    let uniqueName = ChannelManager.defaultChannelUniqueName
    if let channelsList = self.channelsList {
      self.generalChannel = channelsList.channel(withUniqueName: uniqueName)
    }

    if self.generalChannel != nil {
      self.joinGeneralChatRoomWithUniqueName(name: nil, completion: completion)
      return
    }

    self.createGeneralChatRoomWithCompletion { succeeded in
      if (succeeded) {
        self.joinGeneralChatRoomWithUniqueName(name: uniqueName, completion: completion)
        return
      }

      completion(false)
    }
  }

  func joinGeneralChatRoomWithUniqueName(name: String?, completion: @escaping (Bool) -> Void) {
    generalChannel.join { result in
      if ((result?.isSuccessful())! && name != nil) {
        self.setGeneralChatRoomUniqueNameWithCompletion(completion: completion)
        return
      }
      completion((result?.isSuccessful())!)
    }
  }

  func createGeneralChatRoomWithCompletion(completion: @escaping (Bool) -> Void) {
    let channelName = ChannelManager.defaultChannelName
    let options:[NSObject : AnyObject] = [TWMChannelOptionFriendlyName as NSObject: channelName as AnyObject, TWMChannelOptionType as NSObject: TWMChannelType.public.rawValue as AnyObject]
    channelsList!.createChannel(options: options) { result, channel in
      if (result?.isSuccessful())! {
        self.generalChannel = channel
      }
      completion((result?.isSuccessful())!)
    }
  }

  func setGeneralChatRoomUniqueNameWithCompletion(completion:@escaping (Bool) -> Void) {
    generalChannel.setUniqueName(ChannelManager.defaultChannelUniqueName) { result in
      completion((result?.isSuccessful())!)
    }
  }

  // MARK: - Populate channels
  
  func populateChannels() {
    channels = NSMutableOrderedSet()
    if let channels = channelsList?.allObjects() {
      self.channels?.addObjects(from: channels)
      sortChannels()
    }
    
    if self.delegate != nil {
      self.delegate!.reloadChannelList()
    }
  }

  func sortChannels() {
    let sortSelector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
    let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
    channels!.sort(using: [descriptor])
  }

  // MARK: - Create channel

  func createChannelWithName(name: String, completion: @escaping (Bool, TWMChannel?) -> Void) {
    if (name == ChannelManager.defaultChannelName) {
      completion(false, nil)
      return
    }

    let channelOptions:[NSObject : AnyObject] = [
      TWMChannelOptionFriendlyName as NSObject: name as AnyObject, TWMChannelOptionType as NSObject: TWMChannelType.public.rawValue as AnyObject
    ]
    UIApplication.shared.isNetworkActivityIndicatorVisible = true;
    self.channelsList?.createChannel(options: channelOptions) { result, channel in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false;
      completion((result?.isSuccessful())!, channel)
    }
  }
}

// MARK: - TwilioIPMessagingClientDelegate
extension ChannelManager : TwilioIPMessagingClientDelegate {
  func ipMessagingClient(_ client: TwilioIPMessagingClient!, channelAdded channel: TWMChannel!) {
    DispatchQueue.main.async {
      if self.channels != nil {
        self.channels!.add(channel)
        self.sortChannels()
      }
      self.delegate?.ipMessagingClient(client, channelAdded: channel)
    }
  }

  func ipMessagingClient(_ client: TwilioIPMessagingClient!, channelChanged channel: TWMChannel!) {
    self.delegate?.ipMessagingClient(client, channelChanged: channel)
  }

  func ipMessagingClient(_ client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
    DispatchQueue.main.async {
      if self.channels != nil {
        self.channels?.remove(channel)
      }
      self.delegate?.ipMessagingClient(client, channelDeleted: channel)
    }

  }

  func ipMessagingClient(_ client: TwilioIPMessagingClient!, synchronizationStatusChanged status: TWMClientSynchronizationStatus) {
  }
}
