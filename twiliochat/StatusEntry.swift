import UIKit
import UIKit

enum TWCMemberStatus {
  case Joined
  case Left
}

class StatusEntry: NSObject {
  var sid: NSString = ""
  var member: TWMMember! = nil
  var timestamp: NSString = ""
  var status: TWCMemberStatus! = nil

  init(member: TWMMember, status: TWCMemberStatus) {
    self.member = member
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    timestamp = dateFormatter.stringFromDate(NSDate())
    self.status = status
  }


}
