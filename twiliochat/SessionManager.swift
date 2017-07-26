import UIKit

class SessionManager {
    static let UsernameKey: String = "username"
    static let IsLoggedInKey: String = "loggedIn"
    static let defaults = UserDefaults.standard
    
    class func loginWithUsername(username:String) {
        defaults.set(username, forKey: UsernameKey)
        defaults.set(true, forKey: IsLoggedInKey)
        
        defaults.synchronize()
    }
    
    class func logout() {
        defaults.set("", forKey: UsernameKey)
        defaults.set(false, forKey: IsLoggedInKey)
        defaults.synchronize()
    }
    
    class func isLoggedIn() -> Bool {
        let isLoggedIn = defaults.bool(forKey: IsLoggedInKey)
        if (isLoggedIn) {
            return true
        }
        return false
    }
    
    class func getUsername() -> String {
        if let username = defaults.object(forKey: UsernameKey) as? String {
            return username
        }
        return ""
    }
}
