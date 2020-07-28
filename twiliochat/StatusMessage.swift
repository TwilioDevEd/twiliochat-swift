import UIKit
import UIKit

enum TWCMemberStatus {
    case Joined
    case Left
}

class StatusMessage: TCHMessage {
    var status: TWCMemberStatus! = nil
    var statusMember: TCHMember! = nil
    
    var _dateCreated: String = ""
    override var dateCreated: String {
        get {
            return _dateCreated
        }
        set(newDateCreated) {
            _dateCreated = newDateCreated
        }
    }
    
    init(statusMember: TCHMember, status: TWCMemberStatus) {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
        dateCreated = dateFormatter.string(from: NSDate() as Date)
        self.statusMember = statusMember
        self.status = status
    }
    
    
}
