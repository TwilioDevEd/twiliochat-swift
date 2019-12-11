//
//  TWUser.swift
//  twiliochat
//
//  Created by HackMini on 11.12.2019.
//  Copyright © 2019 Twilio. All rights reserved.
//

import Foundation
import MessageKit

struct TWUser: SenderType, Equatable {
	var senderId: String
	var displayName: String
	
	static func == (lhs: TWUser, rhs: TWUser) -> Bool {
		return lhs.senderId == rhs.senderId
	}
}
