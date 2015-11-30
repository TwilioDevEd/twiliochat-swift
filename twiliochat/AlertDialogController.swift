import UIKit

class AlertDialogController: NSObject {
    
    static func showAlertWithMessage(message:String?, title:String?, presenter:(UIViewController)) {
        showAlertWithMessage(message, title: title, presenter: presenter, handler: nil)
    }
    
    static func showAlertWithMessage(message:String?, title:String?, presenter:(UIViewController), handler:(Void -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Cancel) { (_) -> Void in
            if let block = handler {
                block()
            }
        }
        
        alert.addAction(defaultAction)
        presenter.presentViewController(alert, animated: true, completion: nil)
    }
}
