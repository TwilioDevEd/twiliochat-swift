import UIKit
import UIKit

enum TWCMemberStatus {
    case Joined
    case Left
}

class StatusMessage: TCHMessage {
    var member: TCHMember! = nil
    var status: TWCMemberStatus! = nil
    var _timestamp: String = ""
    override var timestamp: String {
        get {
            return _timestamp
        }
        set(newTimestamp) {
            _timestamp = newTimestamp
        }
    }
    
    init(member: TCHMember, status: TWCMemberStatus) {
        super.init()
        self.member = member
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        timestamp = dateFormatter.string(from: NSDate() as Date)
        self.status = status
    }
    
    
}
