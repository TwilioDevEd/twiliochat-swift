import UIKit
import MessageKit
import InputBarAccessoryView

final class MainChatViewController: ChatViewController {
	
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var actionButtonItem: UIBarButtonItem!
	
	
	@IBAction func actionButtonTouched(_ sender: UIBarButtonItem) {
        // leaveChannel()
		print("kanaldan çık")
    }
    
    @IBAction func revealButtonTouched(_ sender: AnyObject) {
        revealViewController().revealToggle(animated: true)
    }
//
//    var _channel:TCHChannel!
//    var channel:TCHChannel! {
//        get {
//            return _channel
//        }
//        set(channel) {
//            _channel = channel
//            title = _channel.friendlyName
//            _channel.delegate = self
//
//            if _channel == ChannelManager.sharedManager.generalChannel {
//                navigationItem.rightBarButtonItem = nil
//            }
//
//            joinChannel()
//        }
//    }
//
////    var messages:Set<TCHMessage> = Set<TCHMessage>()
//	var messages: Set<TWMessage> = Set<TWMessage>()
////    var sortedMessages:[TCHMessage]!
//	var sortedMessages: [TWMessage]!
//
////	private func bringMessageType(from message: TCHMessage) -> MessageType {
////		return MessageType
////	}
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//		messagesCollectionView.messagesDataSource = self
//		messagesCollectionView.messagesLayoutDelegate = self
//		messagesCollectionView.messagesDisplayDelegate = self
//
////        if (revealViewController() != nil) {
////            revealButtonItem.target = revealViewController()
////            revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
////            navigationController?.navigationBar.addGestureRecognizer(revealViewController().panGestureRecognizer())
////            revealViewController().rearViewRevealOverdraw = 0
////        }
////
////        bounces = true
////        shakeToClearEnabled = true
////        isKeyboardPanningEnabled = true
////        shouldScrollToBottomAfterKeyboardShows = false
////        isInverted = true
////
////        let cellNib = UINib(nibName: MainChatViewController.TWCChatCellIdentifier, bundle: nil)
////        tableView!.register(cellNib, forCellReuseIdentifier:MainChatViewController.TWCChatCellIdentifier)
////
////        let cellStatusNib = UINib(nibName: MainChatViewController.TWCChatStatusCellIdentifier, bundle: nil)
////        tableView!.register(cellStatusNib, forCellReuseIdentifier:MainChatViewController.TWCChatStatusCellIdentifier)
////
////        textInputbar.autoHideRightButton = true
////        textInputbar.maxCharCount = 256
////        textInputbar.counterStyle = .split
////        textInputbar.counterPosition = .top
////
////        let font = UIFont(name:"Avenir-Light", size:14)
////        textView.font = font
////
////        rightButton.setTitleColor(UIColor(red:0.973, green:0.557, blue:0.502, alpha:1), for: .normal)
////
////        if let font = UIFont(name:"Avenir-Heavy", size:17) {
////			navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
////        }
////
////        tableView!.allowsSelection = false
////        tableView!.estimatedRowHeight = 70
////		tableView!.rowHeight = UITableView.automaticDimension
////        tableView!.separatorStyle = .none
//
//        if channel == nil {
//            channel = ChannelManager.sharedManager.generalChannel
//        }
//
//		// createPickerRightBarButton()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        // required for iOS 11
////		textInputbar.bringSubviewToFront(textInputbar.textView)
////		textInputbar.bringSubviewToFront(textInputbar.leftButton)
////		textInputbar.bringSubviewToFront(textInputbar.rightButton)
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        scrollToBottom()
//    }
//
//
////    override func numberOfSections(in tableView: UITableView) -> Int {
////        return 1
////    }
////
////    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {
////        return messages.count
////    }
////
////    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        var cell:UITableViewCell
////
////        let message = sortedMessages[indexPath.row]
////
////        if let statusMessage = message as? StatusMessage {
////            cell = getStatusCellForTableView(tableView: tableView, forIndexPath:indexPath, message:statusMessage)
////        }
////        else {
////            cell = getChatCellForTableView(tableView: tableView, forIndexPath:indexPath, message:message)
////        }
////
////        cell.transform = tableView.transform
////        return cell
////    }
//
////	var exampleMedia: UIImage?
//
////    func getChatCellForTableView(tableView: UITableView, forIndexPath indexPath:IndexPath, message: TCHMessage) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatViewController.TWCChatCellIdentifier, for:indexPath as IndexPath)
////
////        let chatCell: ChatTableCell = cell as! ChatTableCell
////        let date = NSDate.dateWithISO8601String(dateString: message.timestamp ?? "")
////        let timestamp = DateTodayFormatter().stringFromDate(date: date)
////
//////		let image = UIImage(contentsOfFile: tempFilename)
////
////		if message.hasMedia() {
////			chatCell.setUser(user: message.author ?? "[Unknown author]", message: message.body, date: timestamp ?? "[Unknown date]", image: exampleMedia)
////		} else {
////			chatCell.setUser(user: message.author ?? "[Unknown author]", message: message.body, date: timestamp ?? "[Unknown date]")
////		}
////
////        return chatCell
////    }
////
////    func getStatusCellForTableView(tableView: UITableView, forIndexPath indexPath:IndexPath, message: StatusMessage) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatViewController.TWCChatStatusCellIdentifier, for:indexPath as IndexPath)
////
////        let label = cell.viewWithTag(MainChatViewController.TWCLabelTag) as! UILabel
////        let memberStatus = (message.status! == .Joined) ? "joined" : "left"
////        label.text = "User \(message.member.identity ?? "[Unknown user]") has \(memberStatus)"
////        return cell
////    }
//
//    func joinChannel() {
//        setViewOnHold(onHold: true)
//
//        if channel.status != .joined {
//            channel.join { result in
//                print("Channel Joined")
//            }
//            return
//        }
//
//        loadMessages()
//        setViewOnHold(onHold: false)
//    }
//
//    // Disable user input and show activity indicator
//    func setViewOnHold(onHold: Bool) {
//        // self.isTextInputbarHidden = onHold;
//        UIApplication.shared.isNetworkActivityIndicatorVisible = onHold;
//    }
//
////    override func didPressRightButton(_ sender: Any!) {
////        textView.refreshFirstResponder()
////        sendMessage(inputMessage: textView.text)
////        super.didPressRightButton(sender)
////    }
//
//    // MARK: - Chat Service
//
//    func sendMessage(inputMessage: String) {
//
//		// Send media message
//		guard let data = UIImage(named: "tree")?.pngData() else { return }
//
//		let messageOptions = TCHMessageOptions()
//		let inputStream = InputStream(data: data)
//
//		messageOptions.withMediaStream(inputStream,
//									   contentType: "image/jpeg",
//									   defaultFilename: "tree.jpg",
//									   onStarted: {
//										// Called when upload of media begins.
//										print("Media upload started")
//		},
//									   onProgress: { (bytes) in
//										// Called as upload progresses, with the current byte count.
//										print("Media upload progress: \(bytes)")
//		}) { (mediaSid) in
//			// Called when upload is completed, with the new mediaSid if successful.
//			// Full failure details will be provided through sendMessage's completion.
//			print("Media upload completed")
//			}
//		.withBody(inputMessage)
//
//		// Trigger the sending of the message.
//		self.channel.messages?.sendMessage(with: messageOptions,
//										   completion: { (result, message) in
//											if !result.isSuccessful() {
//												print("Creation failed: \(String(describing: result.error))")
//											} else {
//												print("Creation successful")
//											}
//		})
//
//
////        let messageOptions = TCHMessageOptions().withBody(inputMessage)
////        channel.messages?.sendMessage(with: messageOptions, completion: nil)
//    }
//
//    func addMessages(newMessages:Set<TCHMessage>) {
//        //messages =  messages.union(newMessages)
//        sortMessages()
//        DispatchQueue.main.async {
//            // self.tableView!.reloadData()
//            if self.messages.count > 0 {
//                self.scrollToBottom()
//            }
//        }
//    }
//
//    func sortMessages() {
//        //sortedMessages = messages.sorted { (a, b) -> Bool in
//            // (a.timestamp ?? "") > (b.timestamp ?? "")
//        //}
//		sortedMessages = messages.sorted { $0.timestamp > $1.timestamp }
//    }
//
//    func loadMessages() {
//        messages.removeAll()
//        if channel.synchronizationStatus == .all {
//            channel.messages?.getLastWithCount(100) { (result, items) in
//
//				items?.forEach ({
//					// şuanda bu sorgunun bir önemi yok çünkü bir medyaya sahip olanların hepsi için aynı medyayı çekiyor.
//					if $0.hasMedia() {
//						// twilio aynı anda birden fazla request yapmamayı öneriyor
//						self.fetchMessageMedia(for: $0)
//					}
//				})
//
//                self.addMessages(newMessages: Set(items!))
//            }
//        }
//    }
//
//	private func fetchMessageMedia(for message: TCHMessage) {
//		// Set up output stream for media content
//		let tempFilename = (NSTemporaryDirectory() as NSString).appendingPathComponent(message.mediaFilename ?? "file.dat")
//		let outputStream = OutputStream(toFileAtPath: tempFilename, append: false)
//
//		// Request the start of the download
//		if let outputStream = outputStream {
//			message.getMediaWith(outputStream,
//								 onStarted: {
//									// Called when download of media begins.
//			},
//								 onProgress: { (bytes) in
//									// Called as download progresses, with the current byte count.
//			},
//								 onCompleted: { (mediaSid) in
//									// Called when download is completed, with the new mediaSid if successful.
//									// Full failure details will be provided through the completion block below.
//
//									print(mediaSid)
//			}) { (result) in
//
//				if !result.isSuccessful() {
//					print("Download failed: \(String(describing: result.error))")
//				} else {
//					print("Download successful")
//
//					//let image = UIImage(contentsOfFile: tempFilename)
//					// self.exampleMedia = image
//					//self.tableView?.reloadData()
//				}
//			}
//		}
//	}
//
//    func scrollToBottom() {
//        if messages.count > 0 {
//            //let indexPath = IndexPath(row: 0, section: 0)
//            // tableView!.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
//
//    func leaveChannel() {
//        channel.leave { result in
//            if (result.isSuccessful()) {
//                let menuViewController = self.revealViewController().rearViewController as! MenuViewController
//                menuViewController.deselectSelectedChannel()
//               // self.revealViewController().rearViewController.performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
//            }
//        }
//    }
//
//    // MARK: - Actions
//
//    @IBAction func actionButtonTouched(_ sender: UIBarButtonItem) {
//        leaveChannel()
//    }
//
//    @IBAction func revealButtonTouched(_ sender: AnyObject) {
//        revealViewController().revealToggle(animated: true)
//    }
//}
//
//// MARK: - MessageKit UI
//extension MainChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
//
//}
//
//// MARK: - MessageKit
//extension MainChatViewController: MessagesDataSource {
//
//	func currentSender() -> SenderType {
//		return MessagingManager._sharedManager.currentUser
//	}
//
//	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//		return sortedMessages[indexPath.section]
//	}
//
//	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//		return sortedMessages.count
//	}
//}
//
//
//
//// MARK: - Channel Delegate
//extension MainChatViewController : TCHChannelDelegate {
//    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
////        if !messages.contains(message) {
////			// Check if message has media.
////
////		//	print(message.attributes())
////
////			if message.hasMedia() {
////				print("mediaFilename: \(String(describing: message.mediaFilename)) (optional)")
////				print("mediaSize: \(message.mediaSize)")
////			}
////
////            addMessages(newMessages: [message])
////        }
//
//		print("mesaj yollandı ---> ", message.body)
//    }
//
//    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
//        addMessages(newMessages: [StatusMessage(member:member, status:.Joined)])
//    }
//
//    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
//        addMessages(newMessages: [StatusMessage(member:member, status:.Left)])
//    }
//
//    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
//        DispatchQueue.main.async {
//            if channel == self.channel {
//                // self.revealViewController().rearViewController
//                //    .performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
//            }
//        }
//    }
//
//    func chatClient(_ client: TwilioChatClient,
//                    channel: TCHChannel,
//                    synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
//        if status == .all {
//            loadMessages()
//            DispatchQueue.main.async {
//                // self.tableView?.reloadData()
//                self.setViewOnHold(onHold: false)
//            }
//        }
//    }
//}
	override func configureMessageCollectionView() {
		super.configureMessageCollectionView()
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
	}
}

extension MainChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        // avatarView.set(avatar: avatar)
		avatarView.backgroundColor = .orange
    }
    
    // MARK: - Location Messages
    
//    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
//        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
//        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
//        annotationView.image = pinImage
//        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
//        return annotationView
//    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
//    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
//
//        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
//    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
       // audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }

}

// MARK: - MessagesLayoutDelegate

extension MainChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

