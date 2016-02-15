import UIKit
import Alamofire

class TokenRequestHandler {

  class func fetchToken(params:[String:String], completion:(NSDictionary, NSError?) -> Void) {
    if let filePath = NSBundle.mainBundle().pathForResource("Keys", ofType:"plist"),
      dictionary = NSDictionary(contentsOfFile:filePath) as? [String: AnyObject],
      tokenRequestUrl = dictionary["TokenRequestUrl"] as? String {

        Alamofire.request(.POST, tokenRequestUrl, parameters: params)
          .validate()
          .responseJSON { response in
            switch response.result {
            case .Success:
              completion(response.result.value as! NSDictionary, nil)
            case .Failure(let error):
              completion(NSDictionary(), error)
            }
        }
    }
    else {
      let userInfo = [NSLocalizedDescriptionKey : "TokenRequestUrl Key is missing"]
      let error = NSError(domain: "app", code: 404, userInfo: userInfo)

      completion(NSDictionary(), error)
    }
  }
}
