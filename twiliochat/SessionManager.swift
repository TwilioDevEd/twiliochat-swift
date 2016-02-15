import UIKit

class SessionManager {
  static let UsernameKey: String = "username"
  static let IsLoggedInKey: String = "loggedIn"
  static let defaults = NSUserDefaults.standardUserDefaults()

  class func loginWithUsername(username:String) {
    defaults.setObject(username, forKey: UsernameKey)
    defaults.setBool(true, forKey: IsLoggedInKey)

    defaults.synchronize()
  }

  class func logout() {
    defaults.setObject("", forKey: UsernameKey)
    defaults.setBool(false, forKey: IsLoggedInKey)
    defaults.synchronize()
  }

  class func isLoogedIn() -> Bool {
    let isLoggedIn = defaults.boolForKey(IsLoggedInKey)
    if (isLoggedIn) {
      return true
    }
    return false
  }

  class func getUsername() -> String {
    if let username = defaults.objectForKey(UsernameKey) as? String {
      return username
    }
    return ""
  }
}
