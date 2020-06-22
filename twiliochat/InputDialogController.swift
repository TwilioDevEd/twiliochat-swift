import UIKit

class InputDialogController: NSObject {
    
    var saveAction: UIAlertAction!
    
    class func showWithTitle(title: String, message: String,
                             placeholder: String, presenter: UIViewController, handler: @escaping (String) -> Void) {
        InputDialogController().showWithTitle(title: title, message: message,
                                              placeholder: placeholder, presenter: presenter, handler: handler)
    }
    
    func showWithTitle(title: String, message: String, placeholder: String,
                       presenter: UIViewController, handler: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.removeTextFieldObserver()
        }
        
        saveAction = UIAlertAction(title: "Save", style: .default) { action in
            self.removeTextFieldObserver()
            let textFieldText = alert.textFields![0].text ?? String()
            handler(textFieldText)
        }
        
        saveAction.isEnabled = false
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(InputDialogController.handleTextFieldTextDidChangeNotification(notification:)),
                                                   name: UITextField.textDidChangeNotification,
                                                   object: nil)
        }
        
        alert.addAction(defaultAction)
        alert.addAction(saveAction)
        presenter.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as? UITextField
        saveAction.isEnabled = !(textField!.text?.isEmpty ?? false)
    }
    
    func removeTextFieldObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
