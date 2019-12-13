import UIKit
import MessageKit
import InputBarAccessoryView

final class MainChatViewController: ChatViewController {
	
    static let TWCOpenGeneralChannelSegue = "OpenGeneralChat"
    static let TWCLabelTag = 200
	
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var actionButtonItem: UIBarButtonItem!

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
	
	/// The object that manages attachments
	public lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
	
	var twInputBar: TWInputBarView!

//    var messages:Set<TCHMessage> = Set<TCHMessage>()
//	var messages: Set<TWMessage> = Set<TWMessage>()
//    var sortedMessages:[TCHMessage]!
//	var sortedMessages: [TWMessage]!
//
//	private func bringMessageType(from message: TCHMessage) -> MessageType {
//		return MessageType
//	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupInputBar()

//        if (revealViewController() != nil) {
//            revealButtonItem.target = revealViewController()
//            revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
//            navigationController?.navigationBar.addGestureRecognizer(revealViewController().panGestureRecognizer())
//            revealViewController().rearViewRevealOverdraw = 0
//        }
//
//        bounces = true
//        shakeToClearEnabled = true
//        isKeyboardPanningEnabled = true
//        shouldScrollToBottomAfterKeyboardShows = false
//        isInverted = true
//
//        let cellNib = UINib(nibName: MainChatViewController.TWCChatCellIdentifier, bundle: nil)
//        tableView!.register(cellNib, forCellReuseIdentifier:MainChatViewController.TWCChatCellIdentifier)
//
//        let cellStatusNib = UINib(nibName: MainChatViewController.TWCChatStatusCellIdentifier, bundle: nil)
//        tableView!.register(cellStatusNib, forCellReuseIdentifier:MainChatViewController.TWCChatStatusCellIdentifier)
//
//        textInputbar.autoHideRightButton = true
//        textInputbar.maxCharCount = 256
//        textInputbar.counterStyle = .split
//        textInputbar.counterPosition = .top
//
//        let font = UIFont(name:"Avenir-Light", size:14)
//        textView.font = font
//
//        rightButton.setTitleColor(UIColor(red:0.973, green:0.557, blue:0.502, alpha:1), for: .normal)
//
//        if let font = UIFont(name:"Avenir-Heavy", size:17) {
//			navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
//        }
//
//        tableView!.allowsSelection = false
//        tableView!.estimatedRowHeight = 70
//		tableView!.rowHeight = UITableView.automaticDimension
//        tableView!.separatorStyle = .none

        if channel == nil {
            channel = ChannelManager.sharedManager.generalChannel
        }

		// createPickerRightBarButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // required for iOS 11
//		textInputbar.bringSubviewToFront(textInputbar.textView)
//		textInputbar.bringSubviewToFront(textInputbar.leftButton)
//		textInputbar.bringSubviewToFront(textInputbar.rightButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // scrollToBottom()
    }

	// MARK: - Setup
	private func setupInputBar() {
		twInputBar = TWInputBarView()
		twInputBar.inputBarDelegate = self
		twInputBar.inputPlugins = [attachmentManager]
		messageInputBar = twInputBar
		messageInputBar.delegate = self
		
		// MessagesCollectionView Setup
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
	}
	
	override func configureMessageCollectionView() {
		super.configureMessageCollectionView()
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
	}

	

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {
//        return messages.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell:UITableViewCell
//
//        let message = sortedMessages[indexPath.row]
//
//        if let statusMessage = message as? StatusMessage {
//            cell = getStatusCellForTableView(tableView: tableView, forIndexPath:indexPath, message:statusMessage)
//        }
//        else {
//            cell = getChatCellForTableView(tableView: tableView, forIndexPath:indexPath, message:message)
//        }
//
//        cell.transform = tableView.transform
//        return cell
//    }
//
//	var exampleMedia: UIImage?
//
//    func getChatCellForTableView(tableView: UITableView, forIndexPath indexPath:IndexPath, message: TCHMessage) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatViewController.TWCChatCellIdentifier, for:indexPath as IndexPath)
//
//        let chatCell: ChatTableCell = cell as! ChatTableCell
//        let date = NSDate.dateWithISO8601String(dateString: message.timestamp ?? "")
//        let timestamp = DateTodayFormatter().stringFromDate(date: date)
//
////		let image = UIImage(contentsOfFile: tempFilename)
//
//		if message.hasMedia() {
//			chatCell.setUser(user: message.author ?? "[Unknown author]", message: message.body, date: timestamp ?? "[Unknown date]", image: exampleMedia)
//		} else {
//			chatCell.setUser(user: message.author ?? "[Unknown author]", message: message.body, date: timestamp ?? "[Unknown date]")
//		}
//
//        return chatCell
//    }
//
//    func getStatusCellForTableView(tableView: UITableView, forIndexPath indexPath:IndexPath, message: StatusMessage) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatViewController.TWCChatStatusCellIdentifier, for:indexPath as IndexPath)
//
//        let label = cell.viewWithTag(MainChatViewController.TWCLabelTag) as! UILabel
//        let memberStatus = (message.status! == .Joined) ? "joined" : "left"
//        label.text = "User \(message.member.identity ?? "[Unknown user]") has \(memberStatus)"
//        return cell
//    }

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
        // self.isTextInputbarHidden = onHold;
        UIApplication.shared.isNetworkActivityIndicatorVisible = onHold;
    }

//    override func didPressRightButton(_ sender: Any!) {
//        textView.refreshFirstResponder()
//        sendMessage(inputMessage: textView.text)
//        super.didPressRightButton(sender)
//    }

    // MARK: - Chat Service
	
	var imagesWaitingToBeSent: [UIImage] = []
	
	func sendMessage(inputMessage: String, completion: @escaping (Bool) -> Void) {

		let messageOptions = TCHMessageOptions()
		
		if !inputMessage.isEmpty { imagesWaitingToBeSent.removeAll() }
		let isImageMessage: Bool = !imagesWaitingToBeSent.isEmpty
		
		// Send media message
//		if let data = imagesWaitingToBeSent.first?.pngData() {
		if let data = imagesWaitingToBeSent.first?.jpegData(compressionQuality: 0.5) {
			let inputStream = InputStream(data: data)

			messageOptions.withMediaStream(inputStream,
										   contentType: "image/jpeg",
										   defaultFilename: "message.jpg",
										   onStarted: {
											// Called when upload of media begins.
											print("Media upload started")
			},
										   onProgress: { (bytes) in
											// Called as upload progresses, with the current byte count.
											print("Media upload progress: \(bytes)")
			}) { (mediaSid) in
				// Called when upload is completed, with the new mediaSid if successful.
				// Full failure details will be provided through sendMessage's completion.
				print("Media upload completed")
			}
		} else {
			messageOptions.withBody(inputMessage)
		}

		// Trigger the sending of the message.
		self.channel.messages?.sendMessage(with: messageOptions,
										   completion: { (result, message) in
											if !result.isSuccessful() {
												print("Creation failed: \(String(describing: result.error))")
												// FIXME: delete here
												completion(isImageMessage)
											} else {
												print("Creation successful")
												completion(isImageMessage)
											}
		})

//        let messageOptions = TCHMessageOptions().withBody(inputMessage)
//        channel.messages?.sendMessage(with: messageOptions, completion: nil)
    }
	
	

    func addMessages(message:TCHMessage) {
        //messages =  messages.union(newMessages)
		//
//		let twMessages = newMessages.map() {
//			// TWMessage(from: $0, with: .text($0.body ?? ""), date: $0.timestampAsDate ?? Date())
//			// TODO: image şimdilik nil döndür
//			TWMessage(from: $0, with: $0.hasMedia() ? nil : nil)
//		}
	//
		// messages = messages.union(twMessages)
		// insertMessage(newMess)
		
		// Şimdilik ikisi de nil
		let twMessage = TWMessage(from: message, with: message.hasMedia() ? #imageLiteral(resourceName: "tree") : nil)
		
		insertMessage(twMessage)
		
//        sortMessages()
//        DispatchQueue.main.async {
//            // self.tableView!.reloadData()
//
//
//            if self.messages.count > 0 {
//                self.scrollToBottom()
//            }
//        }
    }

//    func sortMessages() {
//        //sortedMessages = messages.sorted { (a, b) -> Bool in
//            // (a.timestamp ?? "") > (b.timestamp ?? "")
//        //}
//		// sortedMessages = messages.sorted { $0.timestamp > $1.timestamp }
//    }

    func loadMessages() {
        // messages.removeAll()
        if channel.synchronizationStatus == .all {
            channel.messages?.getLastWithCount(100) { (result, items) in

//				items?.forEach ({
//					// şuanda bu sorgunun bir önemi yok çünkü bir medyaya sahip olanların hepsi için aynı medyayı çekiyor.
//					if $0.hasMedia() {
//						// twilio aynı anda birden fazla request yapmamayı öneriyor
//						self.fetchMessageMedia(for: $0)
//					}
//				})
				
				var twMessages: [TWMessage] = []
				
				items?.forEach() { message in
					if message.hasMedia() {
						self.fetchMessageMedia(for: message) { (success, image) in
							if success {
								DispatchQueue.main.async {
									twMessages.append(TWMessage(from: message, with: image))
									self.messagesCollectionView.reloadData()
								}
							}
						}
					} else {
						twMessages.append(TWMessage(from: message))
					}
				}

                // self.addMessages(newMessages: Set(items!))
				self.loadFirstMessages(messages: twMessages)
            }
        }
    }

	private func fetchMessageMedia(for message: TCHMessage, completion: @escaping (Bool, UIImage?) -> ()) {
		// Set up output stream for media content
		let tempFilename = (NSTemporaryDirectory() as NSString).appendingPathComponent(message.mediaFilename ?? "file.dat")
		let outputStream = OutputStream(toFileAtPath: tempFilename, append: false)

		// Request the start of the download
		if let outputStream = outputStream {
			message.getMediaWith(outputStream,
								 onStarted: {
									// Called when download of media begins.
			},
								 onProgress: { (bytes) in
									// Called as download progresses, with the current byte count.
			},
								 onCompleted: { (mediaSid) in
									// Called when download is completed, with the new mediaSid if successful.
									// Full failure details will be provided through the completion block below.

									print(mediaSid)
			}) { (result) in

				if !result.isSuccessful() {
					print("Download  failed: \(String(describing: result.error))")
					completion(false, nil)
				} else {
					print("Download successful")
					let image = UIImage(contentsOfFile: tempFilename)
					completion(true, image)
					// self.exampleMedia = image
					//self.tableView?.reloadData()
				}
			}
		}
	}

    func leaveChannel() {
        channel.leave { result in
            if (result.isSuccessful()) {
                let menuViewController = self.revealViewController().rearViewController as! MenuViewController
                menuViewController.deselectSelectedChannel()
				// self.revealViewController().rearViewController.performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
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

// MARK: - InputBar Delegate
extension MainChatViewController: TWInputBarDelegate {
	func inputBarDidSelectImage(_ inputBar: InputBarAccessoryView, image: UIImage) {
		imagesWaitingToBeSent.append(image)
	}
}

// MARK: -
extension MainChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        dismiss(animated: true, completion: {
            if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                let handled = self.attachmentManager.handleInput(of: pickedImage)
                if !handled {
                    // throw error
                }
            }
        })
    }
}

// MARK: - AttachmentManagerDelegate
extension MainChatViewController: AttachmentManagerDelegate {
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        twInputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        twInputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        twInputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    
    func setAttachmentManager(active: Bool) {
        
        let topStackView = twInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}

// MARK: - Channel Delegate
extension MainChatViewController : TCHChannelDelegate {
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        // if !messages.contains(message) {
			// Check if message has media.

		//	print(message.attributes())

			if message.hasMedia() {
				print("mediaFilename: \(String(describing: message.mediaFilename)) (optional)")
				print("mediaSize: \(message.mediaSize)")
			}

		// FIXME: -
		
//            addMessages(newMessages: [message])
			// addMessages(message: message)
        // }

		print("mesaj yollandı ---> ", message.body)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
      //  addMessages(newMessages: [StatusMessage(member:member, status:.Joined)])
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
      //  addMessages(newMessages: [StatusMessage(member:member, status:.Left)])
    }

    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        DispatchQueue.main.async {
            if channel == self.channel {
                 self.revealViewController().rearViewController
                    .performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
            }
        }
    }

    func chatClient(_ client: TwilioChatClient,
                    channel: TCHChannel,
                    synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        if status == .all {
            loadMessages()
            DispatchQueue.main.async {
                // self.tableView?.reloadData()
				self.messagesCollectionView.reloadData()
                self.setViewOnHold(onHold: false)
            }
        }
    }
}

// MARK: - MessagesDisplayDelegate
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
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        // avatarView.set(avatar: avatar)
		// TODO: Avatar image
		avatarView.backgroundColor = .orange
		avatarView.isHidden = isNextMessageSameSender(at: indexPath)
    }
}

// MARK: - MessagesLayoutDelegate

extension MainChatViewController: MessagesLayoutDelegate {
    
//    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 18
//    }
//
//    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 17
//    }
//
//    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 20
//    }
//
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 16
//    }
	
	func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
			// outgoingAvatarOverlap = 17.5
			return !isPreviousMessageSameSender(at: indexPath) ? (20 + 17.5) : 0
        }
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}

