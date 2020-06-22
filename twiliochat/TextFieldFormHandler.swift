import UIKit

@objc public protocol TextFieldFormHandlerDelegate {
    @objc optional func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler)
}

public class TextFieldFormHandler: NSObject {
    var textFields: [UITextField]!
    var keyboardSize: CGFloat = 0
    var animationOffset: CGFloat = 0
    var topContainer: UIView!
    
    var _lastTextField: UITextField?
    var lastTextField: UITextField? {
        get {
            return _lastTextField
        }
        set (newValue){
            if let textField = _lastTextField {
                setTextField(textField: textField, returnKeyType: .next)
            }
            _lastTextField = newValue
            
            if let textField = newValue {
                setTextField(textField: textField, returnKeyType: .done)
            }
            else if let textField = textFields.last {
                setTextField(textField: textField, returnKeyType: .done)
            }
        }
    }
    
    public weak var delegate: TextFieldFormHandlerDelegate?
    
    public var firstResponderIndex: Int? {
        if let firstResponder = self.firstResponder {
            return self.textFields.firstIndex(of: firstResponder)
        }
        return nil
    }
    
    public var firstResponder: UITextField? {
        return self.textFields.filter { textField in textField.isFirstResponder }.first
    }
    
    // MARK: - Initialization
    
    init(withTextFields textFields: [UITextField], topContainer: UIView) {
        super.init()
        self.textFields = textFields
        self.topContainer = topContainer
        initializeTextFields()
        initializeObservers()
    }
    
    func initializeTextFields() {
        for (index, textField) in self.textFields.enumerated() {
            textField.delegate = self
            setTextField(textField: textField, returnKeyType: (index == self.textFields.count - 1 ? .done : .next))
        }
    }
    
    func initializeObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(TextFieldFormHandler.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextFieldFormHandler.backgroundTap(sender:)))
        self.topContainer.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Public Methods
    
    public func resetScroll() {
        if let firstResponder = self.firstResponder {
            setAnimationOffsetForTextField(textField: firstResponder)
            moveScreenUp()
        }
    }
    
    public func setTextFieldAtIndexAsFirstResponder(index:Int) {
        textFields[index].becomeFirstResponder()
    }
    
    public func cleanUp() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    func doneEnteringData() {
        topContainer.endEditing(true)
        moveScreenDown()
        delegate?.textFieldFormHandlerDoneEnteringData?(handler: self)
    }
    
    func moveScreenUp() {
        shiftScreenYPosition(position: -keyboardSize - animationOffset, duration: 0.3, curve: .easeInOut)
    }
    
    func moveScreenDown() {
        shiftScreenYPosition(position: 0, duration: 0.2, curve: .easeInOut)
    }
    
    func shiftScreenYPosition(position: CGFloat, duration: TimeInterval, curve: UIView.AnimationCurve) {
        UIView.beginAnimations("moveView", context: nil)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationDuration(duration)
        
        topContainer.frame.origin.y = position
        UIView.commitAnimations()
    }
    
    @objc func backgroundTap(sender: UITapGestureRecognizer) {
        topContainer.endEditing(true)
        moveScreenDown()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (keyboardSize == 0) {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardSize = min(keyboardRect.height, keyboardRect.width)
            }
        }
        moveScreenUp()
    }
    
    func setAnimationOffsetForTextField(textField: UITextField) {
        let screenHeight = UIScreen.main.bounds.size.height
        let textFieldHeight = textField.frame.size.height
        let textFieldY = textField.convert(CGPoint.zero, to: topContainer).y
        
        animationOffset = -screenHeight + textFieldY + textFieldHeight
    }
    
    func setTextField(textField: UITextField, returnKeyType type: UIReturnKeyType) {
        if (textField.isFirstResponder) {
            textField.resignFirstResponder()
            textField.returnKeyType = type
            textField.becomeFirstResponder()
        }
        else {
            textField.returnKeyType = type
        }
    }
    
    deinit {
        cleanUp()
    }
}

extension TextFieldFormHandler : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let lastTextField = self.lastTextField, textField == lastTextField {
            doneEnteringData()
            return true
        }
        else if let lastTextField = self.textFields.last, lastTextField == textField {
            doneEnteringData()
            return true
        }
        
        let index = self.textFields.firstIndex(of: textField)
        let nextTextField = self.textFields[index! + 1]
        nextTextField.becomeFirstResponder()
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setAnimationOffsetForTextField(textField: textField)
        return true
    }
}
