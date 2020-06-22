import UIKit
import UIKit

enum TWCMemberStatus {
    case Joined
    case Left
}

class StatusMessage: TCHMessage {
    var status: TWCMemberStatus! = nil
    var statusMember: TCHMember! = nil
    
    var _timestamp: String = ""
    override var timestamp: String {
        get {
            return _timestamp
        }
        set(newTimestamp) {
            _timestamp = newTimestamp
        }
    }
    
    init(statusMember: TCHMember, status: TWCMemberStatus) {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
        timestamp = dateFormatter.string(from: NSDate() as Date)
        self.statusMember = statusMember
        self.status = status
    }
    
    
}
