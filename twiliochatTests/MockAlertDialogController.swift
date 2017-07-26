import UIKit
@testable import twiliochat

class MockAlertDialogController: AlertDialogController {
    static var showedAlertWithMessage = ""
    
    override class func showAlertWithMessage(message:String?, title:String?, presenter:(UIViewController)) {
        if let message = message {
            showedAlertWithMessage = message
        }
    }
}
