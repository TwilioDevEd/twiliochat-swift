import UIKit

class AlertDialogController: NSObject {
    
    class func showAlertWithMessage(message:String?, title:String?, presenter:(UIViewController)) {
        showAlertWithMessage(message: message, title: title, presenter: presenter, completion: nil)
    }
    
    class func showAlertWithMessage(message:String?, title:String?,
                                    presenter:(UIViewController), completion:(() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel) { (_) -> Void in
            if let block = completion {
                block()
            }
        }
        
        alert.addAction(defaultAction)
        presenter.present(alert, animated: true, completion: nil)
    }
}
