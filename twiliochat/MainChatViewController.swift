import UIKit
import SlackTextViewController

class MainChatViewController: SLKTextViewController {
    static let TWCChatCellIdentifier = "ChatTableCell"
    static let TWCChatStatusCellIdentifier = "ChatStatusTableCell"
    
    static let TWCOpenGeneralChannelSegue = "OpenGeneralChat"
    static let TWCLabelTag = 200
    
    var _channel:TCHChannel!
    var channel:TCHChannel! {
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
    
    var messages:Set<TCHMessage> = Set<TCHMessage>()
    var sortedMessages:[TCHMessage]!
    
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
        isKeyboardPanningEnabled = true
        shouldScrollToBottomAfterKeyboardShows = false
        isInverted = true
        
        let cellNib = UINib(nibName: MainChatViewController.TWCChatCellIdentifier, bundle: nil)
        tableView!.register(cellNib, forCellReuseIdentifier:MainChatViewController.TWCChatCellIdentifier)
        
        let cellStatusNib = UINib(nibName: MainChatViewController.TWCChatStatusCellIdentifier, bundle: nil)
        tableView!.register(cellStatusNib, forCellReuseIdentifier:MainChatViewController.TWCChatStatusCellIdentifier)
        
        textInputbar.autoHideRightButton = true
        textInputbar.maxCharCount = 256
        textInputbar.counterStyle = .split
        textInputbar.counterPosition = .top
        
        let font = UIFont(name:"Avenir-Light", size:14)
        textView.font = font
        
        rightButton.setTitleColor(UIColor(red:0.973, green:0.557, blue:0.502, alpha:1), for: .normal)
        
        if let font = UIFont(name:"Avenir-Heavy", size:17) {
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        tableView!.allowsSelection = false
        tableView!.estimatedRowHeight = 70
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.separatorStyle = .none
        
        if channel == nil {
            channel = ChannelManager.sharedManager.generalChannel
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        let message = sortedMessages[indexPath.row]
        
        if let statusMessage = message as? StatusMessage {
            cell = getStatusCellForTableView(tableView: tableView, forIndexPath:indexPath, message:statusMessage)
        }
        else {
            cell = getChatCellForTableView(tableView: tableView, forIndexPath:indexPath, message:message)
        }
        
        cell.transform = tableView.transform
        return cell
    }
    
    func getChatCellForTableView(tableView: UITableView, forIndexPath indexPath:IndexPath, message: TCHMessage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatViewController.TWCChatCellIdentifier, for:indexPath as IndexPath)
        
        let chatCell: ChatTableCell = cell as! ChatTableCell
        let timestamp = DateTodayFormatter().stringFromDate(date: NSDate.dateWithISO8601String(dateString: message.timestamp))
        
        chatCell.setUser(user: message.author ?? "[Unknown author]", message: message.body, date: timestamp ?? "[Unknown date]")
        
        return chatCell
    }
    
    func getStatusCellForTableView(tableView: UITableView, forIndexPath indexPath:IndexPath, message: StatusMessage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatViewController.TWCChatStatusCellIdentifier, for:indexPath as IndexPath)
        
        let label = cell.viewWithTag(MainChatViewController.TWCLabelTag) as! UILabel
        let memberStatus = (message.status! == .Joined) ? "joined" : "left"
        label.text = "User \(message.member.identity) has \(memberStatus)"
        return cell
    }
    
    func joinChannel() {
        setViewOnHold(onHold: true)
        
        if channel.status != .joined {
            channel.join { result in
                print("Channel Joined")
            }
            return
        }
        
        loadMessages()
        setViewOnHold(onHold: false)
    }
    
    // Disable user input and show activity indicator
    func setViewOnHold(onHold: Bool) {
        self.isTextInputbarHidden = onHold;
        UIApplication.shared.isNetworkActivityIndicatorVisible = onHold;
    }
    
    override func didPressRightButton(_ sender: Any!) {
        textView.refreshFirstResponder()
        sendMessage(inputMessage: textView.text)
        super.didPressRightButton(sender)
    }
    
    // MARK: - Chat Service
    
    func sendMessage(inputMessage: String) {
        let message = channel.messages.createMessage(withBody: inputMessage)
        channel.messages.send(message, completion: nil)
    }
    
    func addMessages(newMessages:Set<TCHMessage>) {
        messages =  messages.union(newMessages)
        sortMessages()
        DispatchQueue.main.async {
            self.tableView!.reloadData()
            if self.messages.count > 0 {
                self.scrollToBottom()
            }
        }
    }
    
    func sortMessages() {
        sortedMessages = messages.sorted { a, b in a.timestamp > b.timestamp }
    }
    
    func loadMessages() {
        messages.removeAll()
        if channel.synchronizationStatus == .all {
            channel.messages.getLastWithCount(100) { (result, items) in
                self.addMessages(newMessages: Set(items!))
            }
        }
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView!.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func leaveChannel() {
        channel.leave { result in
            if (result?.isSuccessful())! {
                let menuViewController = self.revealViewController().rearViewController as! MenuViewController
                menuViewController.deselectSelectedChannel()
                self.revealViewController().rearViewController.performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func actionButtonTouched(_ sender: UIBarButtonItem) {
        leaveChannel()
    }
    
    @IBAction func revealButtonTouched(_ sender: AnyObject) {
        revealViewController().revealToggle(animated: true)
    }
}

extension MainChatViewController : TCHChannelDelegate {
    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, messageAdded message: TCHMessage!) {
        if !messages.contains(message) {
            addMessages(newMessages: [message])
        }
    }
    
    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, memberJoined member: TCHMember!) {
        addMessages(newMessages: [StatusMessage(member:member, status:.Joined)])
    }
    
    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, memberLeft member: TCHMember!) {
        addMessages(newMessages: [StatusMessage(member:member, status:.Left)])
    }
    
    func chatClient(_ client: TwilioChatClient!, channelDeleted channel: TCHChannel!) {
        DispatchQueue.main.async {
            if channel == self.channel {
                self.revealViewController().rearViewController
                    .performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
            }
        }
    }
    
    func chatClient(_ client: TwilioChatClient!,
                    channel: TCHChannel!,
                    synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        if status == .all {
            loadMessages()
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.setViewOnHold(onHold: false)
            }
        }
    }
}
