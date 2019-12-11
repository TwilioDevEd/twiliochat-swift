//
//  Message.swift
//  twiliochat
//
//  Created by HackMini on 11.12.2019.
//  Copyright © 2019 Twilio. All rights reserved.
//

import Foundation
import MessageKit

// class TWMessage: TCHMessage, MessageType {
struct TWMessage: MessageType, Hashable {
	
	var sender: SenderType {
		return user
	}
	
	var messageId: String
	var sentDate: Date
	var kind: MessageKind
	
	var user: TWUser
	
	var timestamp: TimeInterval {
		return sentDate.timeIntervalSince1970
	}
	
	private init(kind: MessageKind, user: TWUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
	
	// Conform the hashable protocol
	func hash(into hasher: inout Hasher) {
		hasher.combine(messageId)
	}
	
	// Hashable also conforms "Equatable" so conforming it, is needed.
	static func == (lhs: TWMessage, rhs: TWMessage) -> Bool {
		return lhs.messageId == rhs.messageId
	}
	
	init(from tchMessage: TCHMessage, with kind: MessageKind, date: Date) {
		// TODO: Şimdilik senderID ve displayName aynı.. Değiştir
		let user = TWUser(senderId: tchMessage.author ?? "senderID yok", displayName: tchMessage.author ?? "displayName yok")
		
		// messageID optional sağ tarafı uuid olabilir mi? ileride sıkıntı yaratır mı?
		self.init(kind: kind, user: user, messageId: tchMessage.sid ?? UUID().uuidString, date: date)
	}
    
	init(custom: Any?, user: TWUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

	init(text: String, user: TWUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, user: TWUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

	init(image: UIImage, user: TWUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, user: TWUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

//    convenience init(location: CLLocation, user: TWUser, messageId: String, date: Date) {
//        let locationItem = CoordinateItem(location: location)
//        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
//    }

	init(emoji: String, user: TWUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

//    convenience  init(contact: MockContactItem, user: TWUser, messageId: String, date: Date) {
//        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
//    }
}


private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}
