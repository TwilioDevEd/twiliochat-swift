import UIKit
import SWRevealViewController
import SlackTextViewController

class MainChatViewController: SLKTextViewController {
  static let TWCChatCellIdentifier = "ChatTableCell"
  static let TWCChatStatusCellIdentifier = "ChatStatusTableCell"

  static let TWCOpenGeneralChannelSegue = "OpenGeneralChat"
  static let TWCLabelTag = 200

  var _channel:TWMChannel!
  var channel:TWMChannel! {
    get {
      return _channel
    }
    set(channel) {
      _channel = channel
      title = _channel.friendlyName
      _channel.delegate = self

      if _channel == ChannelManager.sharedManager.generalChannel {
        navigationItem.rightBarButtonItem = nil
      }

      joinChannel()
    }
  }

  var messages:Set<TWMMessage> = Set<TWMMessage>()
  var sortedMessages:[TWMMessage]!

  @IBOutlet weak var revealButtonItem: UIBarButtonItem!
  @IBOutlet weak var actionButtonItem: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    if (revealViewController() != nil) {
      revealButtonItem.target = revealViewController()
      revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      navigationController?.navigationBar.addGestureRecognizer(revealViewController().panGestureRecognizer())
      revealViewController().rearViewRevealOverdraw = 0
    }

    bounces = true
    shakeToClearEnabled = true
    keyboardPanningEnabled = true
    shouldScrollToBottomAfterKeyboardShows = false
    inverted = true

    let cellNib = UINib(nibName: MainChatViewController.TWCChatCellIdentifier, bundle: nil)
    tableView!.registerNib(cellNib, forCellReuseIdentifier:MainChatViewController.TWCChatCellIdentifier)

    let cellStatusNib = UINib(nibName: MainChatViewController.TWCChatStatusCellIdentifier, bundle: nil)
    tableView!.registerNib(cellStatusNib, forCellReuseIdentifier:MainChatViewController.TWCChatStatusCellIdentifier)

    textInputbar.autoHideRightButton = true
    textInputbar.maxCharCount = 256
    textInputbar.counterStyle = .Split
    textInputbar.counterPosition = .Top

    let font = UIFont(name:"Avenir-Light", size:14)
    textView.font = font

    rightButton.setTitleColor(UIColor(red:0.973, green:0.557, blue:0.502, alpha:1), forState: .Normal)

    if let font = UIFont(name:"Avenir-Heavy", size:17) {
      navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
    }

    tableView!.allowsSelection = false
    tableView!.estimatedRowHeight = 70
    tableView!.rowHeight = UITableViewAutomaticDimension
    tableView!.separatorStyle = .None

    if channel == nil {
      channel = ChannelManager.sharedManager.generalChannel
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    scrollToBottom()
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {
    return messages.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:UITableViewCell

    let message = sortedMessages[indexPath.row]

    if let statusMessage = message as? StatusMessage {
      cell = getStatusCellForTableView(tableView, forIndexPath:indexPath, message:statusMessage)
    }
    else {
      cell = getChatCellForTableView(tableView, forIndexPath:indexPath, message:message)
    }

    cell.transform = tableView.transform
    return cell
  }

  func getChatCellForTableView(tableView: UITableView, forIndexPath indexPath:NSIndexPath, message: TWMMessage) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(MainChatViewController.TWCChatCellIdentifier, forIndexPath:indexPath)

    let chatCell: ChatTableCell = cell as! ChatTableCell
    let timestamp = DateTodayFormatter().stringFromDate(NSDate.dateWithISO8601String(message.timestamp))

    chatCell.setUser(message.author ?? "[Unknown author]", message: message.body, date: timestamp ?? "[Unknown date]")

    return chatCell
  }

  func getStatusCellForTableView(tableView: UITableView, forIndexPath indexPath:NSIndexPath, message: StatusMessage) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(MainChatViewController.TWCChatStatusCellIdentifier, forIndexPath:indexPath)

    let label = cell.viewWithTag(MainChatViewController.TWCLabelTag) as! UILabel
    let memberStatus = (message.status! == .Joined) ? "joined" : "left"
    label.text = "User \(message.member.userInfo.identity) has \(memberStatus)"
    return cell
  }

  func joinChannel() {
    setViewOnHold(true)

    if channel.status != .Joined {
      channel.joinWithCompletion { result in
        print("Channel Joined")
      }
    }

    if channel.synchronizationStatus != .All {
      channel.synchronizeWithCompletion { result in
        if result.isSuccessful() {
          print("Synchronization started. Delegate method will load messages")
        }
      }
    }
    else {
      loadMessages()
      setViewOnHold(false)
    }

  }

  // Disable user input and show activity indicator
  func setViewOnHold(onHold: Bool) {
    self.textInputbarHidden = onHold;
    UIApplication.sharedApplication().networkActivityIndicatorVisible = onHold;
  }

  override func didPressRightButton(sender: AnyObject!) {
    textView.refreshFirstResponder()
    sendMessage(textView.text)
    super.didPressRightButton(sender)
  }

  // MARK: - Chat Service

  func sendMessage(inputMessage: String) {
    let message = channel.messages.createMessageWithBody(inputMessage)
    channel.messages.sendMessage(message, completion: nil)
  }

  func addMessages(newMessages:[TWMMessage]) {
    messages =  messages.union(newMessages)
    sortMessages()
    dispatch_async(dispatch_get_main_queue(), {
      self.tableView!.reloadData()
      if self.messages.count > 0 {
        self.scrollToBottom()
      }
    })
  }

  func sortMessages() {
    sortedMessages = messages.sort { a, b in a.timestamp > b.timestamp }
  }

  func loadMessages() {
    messages.removeAll()
    if channel.synchronizationStatus == .All {
      addMessages(channel.messages.allObjects())
    }
  }

  func scrollToBottom() {
    if messages.count > 0 {
      let indexPath = NSIndexPath(forRow: 0, inSection: 0)
      tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
  }

  func leaveChannel() {
    channel.leaveWithCompletion { result in
      if result.isSuccessful() {
        let menuViewController = self.revealViewController().rearViewController as! MenuViewController
        menuViewController.deselectSelectedChannel()
        self.revealViewController().rearViewController.performSegueWithIdentifier(MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
      }
    }
  }

  // MARK: - Actions

  @IBAction func actionButtonTouched(sender: UIBarButtonItem) {
    leaveChannel()
  }

  @IBAction func revealButtonTouched(sender: AnyObject) {
    revealViewController().revealToggleAnimated(true)
  }
}

extension MainChatViewController : TWMChannelDelegate {
  func ipMessagingClient(client: TwilioIPMessagingClient!, channel: TWMChannel!, messageAdded message: TWMMessage!) {
    if !messages.contains(message) {
      addMessages([message])
    }
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channel: TWMChannel!, memberJoined member: TWMMember!) {
    addMessages([StatusMessage(member:member, status:.Joined)])
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channel: TWMChannel!, memberLeft member: TWMMember!) {
    addMessages([StatusMessage(member:member, status:.Left)])
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
    dispatch_async(dispatch_get_main_queue(), {
      if channel == self.channel {
        self.revealViewController().rearViewController
          .performSegueWithIdentifier(MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
      }
    })
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channel: TWMChannel!, synchronizationStatusChanged status: TWMChannelSynchronizationStatus) {
    if status == .All {
      loadMessages()
      dispatch_async(dispatch_get_main_queue(), {
        self.tableView?.reloadData()
        self.setViewOnHold(false)
      })
    }
  }
}
