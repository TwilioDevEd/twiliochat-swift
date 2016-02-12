import UIKit
import Alamofire

class TokenRequestHandler {
  class func fetchToken() {
    Alamofire.request(.POST, "http://localhost:8000/token")
      .responseJSON { response in
        debugPrint(response)
    }
  }
}
