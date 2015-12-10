import UIKit

class InputDialogController: NSObject {

  var saveAction: UIAlertAction!

  static func showWithTitle(title: String, message: String, placeholder: String, presenter: UIViewController, handler: String -> Void) {
    InputDialogController().showWithTitle(title, message: message, placeholder: placeholder, presenter: presenter, handler: handler)
  }

  func showWithTitle(title: String, message: String, placeholder: String, presenter: UIViewController, handler: String -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

    let defaultAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
      self.removeTextFieldObserver()
    }

    saveAction = UIAlertAction(title: "Save", style: .Default) { action in
      self.removeTextFieldObserver()
      let textFieldText = alert.textFields![0].text ?? String()
      handler(textFieldText)
    }

    saveAction.enabled = false

    alert.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = placeholder
      NSNotificationCenter.defaultCenter().addObserver(self,
        selector: "handleTextFieldTextDidChangeNotification:",
        name: UITextFieldTextDidChangeNotification,
        object: nil)
    }

    alert.addAction(defaultAction)
    alert.addAction(saveAction)
    presenter.presentViewController(alert, animated: true, completion: nil)
  }

  func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
    let textField = notification.object as? UITextField
    saveAction.enabled = !(textField!.text?.isEmpty ?? false)
  }

  func removeTextFieldObserver() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}
