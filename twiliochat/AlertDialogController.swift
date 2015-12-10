import UIKit

class AlertDialogController {

  static func showAlertWithMessage(message:String?, title:String?, presenter:(UIViewController)) {
    showAlertWithMessage(message, title: title, presenter: presenter, completion: nil)
  }

  static func showAlertWithMessage(message:String?, title:String?,
    presenter:(UIViewController), completion:(Void -> Void)?) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

      let defaultAction = UIAlertAction(title: "OK", style: .Cancel) { (_) -> Void in
        if let block = completion {
          block()
        }
      }

      alert.addAction(defaultAction)
      presenter.presentViewController(alert, animated: true, completion: nil)
  }
}
