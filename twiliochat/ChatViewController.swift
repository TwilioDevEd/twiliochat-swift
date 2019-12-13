//
//  BaseChatViewController.swift
//  twiliochat
//
//  Created by HackMini on 11.12.2019.
//  Copyright © 2019 Twilio. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// FIXME:
extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
    var messageList: [TWMessage] = []
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
		formatter.dateStyle = .long
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadFirstMessages()
        title = "MessageKit"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
//            .onNewMessage { [weak self] message in
//                self?.insertMessage(message)
//        }
		
		messagesCollectionView.reloadData()
		
		print("ChatVC - Connect here..")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // MockSocket.shared.disconnect()
		print("ChatVC - Disconnect here..")
    }
    
	func loadFirstMessages(messages: [TWMessage]? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
//            let count = UserDefaults.standard.mockMessagesCount()
//            SampleData.shared.getMessages(count: count) { messages in
//                DispatchQueue.main.async {
//                    self.messageList = messages
//                    self.messagesCollectionView.reloadData()
//                    self.messagesCollectionView.scrollToBottom()
//                }
//            }
			
			let dummyMessages = [
				TWMessage(text: "Sa", user: TWUser(senderId: "1", displayName: "Ünal Ce"), messageId: "11", date: Date()),
				TWMessage(text: "As", user: TWUser(senderId: "2", displayName: "ikinci"), messageId: "22", date: Date()),
				TWMessage(text: "Nabıyonuz", user: TWUser(senderId: SessionManager.getUsername(), displayName: "hehe"), messageId: "33", date: Date())
			]
		
			DispatchQueue.main.async {
				self.messageList = messages ?? dummyMessages
				self.messagesCollectionView.reloadData()
				self.messagesCollectionView.scrollToBottom()
			}
		}
    }
    
    @objc
    func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getMessages(count: 20) { messages in
//                DispatchQueue.main.async {
//                    self.messageList.insert(contentsOf: messages, at: 0)
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
//                }
//            }
        }
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
	func configureMessageInputBar() {

//		messageInputBar = TWInputBarView()
		
//        messageInputBar.inputTextView.tintColor = .primaryColor
//        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
//        messageInputBar.sendButton.setTitleColor(
//            UIColor.primaryColor.withAlphaComponent(0.3),
//            for: .highlighted
//        )
    }
	
//	func configureMessageInputBar() {
//    //    super.configureMessageInputBar()
//
//        messageInputBar.isTranslucent = true
//        messageInputBar.separatorLine.isHidden = true
//        messageInputBar.inputTextView.tintColor = .primaryColor
//        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
//        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
//        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
//        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
//        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
//        messageInputBar.inputTextView.layer.borderWidth = 1.0
//        messageInputBar.inputTextView.layer.cornerRadius = 16.0
//        messageInputBar.inputTextView.layer.masksToBounds = true
//        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        configureInputBarItems()
//    }
//
//    private func configureInputBarItems() {
//        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
//        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
//        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
//        // messageInputBar.sendButton.image = #imageLiteral(resourceName: "disclouser@2x.png")
//        messageInputBar.sendButton.title = "Gönder"
//        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
//        messageInputBar.middleContentViewPadding.right = -38
//        let charCountButton = InputBarButtonItem()
//            .configure {
//                $0.title = "0/140"
//                $0.contentHorizontalAlignment = .right
//                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
//                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
//                $0.setSize(CGSize(width: 50, height: 25), animated: false)
//            }.onTextViewDidChange { (item, textView) in
//                item.title = "\(textView.text.count)/140"
//                let isOverLimit = textView.text.count > 140
//                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
//                if isOverLimit {
//                    item.inputBarAccessoryView?.sendButton.isEnabled = false
//                }
//                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
//                item.setTitleColor(color, for: .normal)
//        }
//        let bottomItems = [.flexibleSpace, charCountButton]
//        messageInputBar.middleContentViewPadding.bottom = 8
//        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
//
//        // This just adds some more flare
//        messageInputBar.sendButton
//            .onEnabled { item in
//                UIView.animate(withDuration: 0.3, animations: {
//                    item.imageView?.backgroundColor = .primaryColor
//                })
//            }.onDisabled { item in
//                UIView.animate(withDuration: 0.3, animations: {
//                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
//                })
//        }
//    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: TWMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
	
	func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
		return MessagingManager._sharedManager.currentUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // let dateString = formatter.string(from: message.sentDate)
		let dateString = DateTodayFormatter().stringFromDate(date: message.sentDate as NSDate) ?? formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
	
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }

}

// MARK: - MessageInputBarDelegate
// !!!! ATTENTION !!!!      THIS IS NOT AN EXTENSION OF "CHATVIEWCONTROLLER"
extension MainChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
		
// 		let images = inputBar.inputTextView.components as? [UIImage]
		
		// sendMessage(inputMessage: text, with: images) {
		sendMessage(inputMessage: text) { isImageMessage in
			DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"

				self?.insertMessages(isImageMessage ? self?.imagesWaitingToBeSent ?? [] : components)
				
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
		}
    }
	
	func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Adjust content insets
        print(size)
        messagesCollectionView.contentInset.bottom = size.height + 300 // keyboard size estimate
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user = MessagingManager._sharedManager.currentUser
            if let str = component as? String {
                // let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
				let message = TWMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                // let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
				let message = TWMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}

