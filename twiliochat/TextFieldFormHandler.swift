import UIKit

@objc public protocol TextFieldFormHandlerDelegate {
    optional func textFieldFormHandlerDoneEnteringData(handler: TextFieldFormHandler)
}

public class TextFieldFormHandler: NSObject, UITextFieldDelegate {
    
    // MARK: - Properties
    
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
                setTextField(textField, returnKeyType: .Next)
            }
            _lastTextField = newValue
            
            if let textField = newValue {
                setTextField(textField, returnKeyType: .Done)
            }
            else if let textField = textFields.last {
                setTextField(textField, returnKeyType: .Done)
            }
        }
    }
    
    public weak var delegate: TextFieldFormHandlerDelegate?
    
    public var firstResponderIndex: Int? {
        if let firstResponder = self.firstResponder {
            return self.textFields.indexOf(firstResponder)
        }
        return nil
    }
    
    public var firstResponder: UITextField? {
        return self.textFields.filter { textField in textField.isFirstResponder() }.first
    }
    
    // MARK: - Initialization
    
    init(withTextFields textFields: [UITextField], topContainer: UIView) {
        super.init()
        self.textFields = textFields
        self.topContainer = topContainer
        initializeTextFields();
        initializeObservers();
    }
    
    func initializeTextFields() {
        for (index, textField) in self.textFields.enumerate() {
            textField.delegate = self
            setTextField(textField, returnKeyType: (index == self.textFields.count - 1 ? .Done : .Next))
        }
    }
    
    func initializeObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "backgroundTap:")
        self.topContainer.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Public Methods
    
    public func resetScroll() {
        if let firstResponder = self.firstResponder {
            setAnimationOffsetForTextField(firstResponder)
            moveScreenUp()
        }
    }
    
    public func setTextFieldAtIndexAsFirstResponder(index:Int) {
        textFields[index].becomeFirstResponder()
    }
    
    public func cleanUp() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let lastTextField = self.lastTextField where textField == lastTextField {
            doneEnteringData()
            return true
        }
        else if let lastTextField = self.textFields.last where lastTextField == textField {
            doneEnteringData()
            return true
        }
        
        let index = self.textFields.indexOf(textField)
        let nextTextField = self.textFields[index! + 1]
        nextTextField.becomeFirstResponder()
        return true
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        setAnimationOffsetForTextField(textField)
        return true
    }
    
    // MARK: - Private Methods
    
    func doneEnteringData() {
        topContainer.endEditing(true)
        moveScreenDown()
        delegate?.textFieldFormHandlerDoneEnteringData?(self)
    }
    
    func moveScreenUp() {
        shiftScreenYPosition(-keyboardSize - animationOffset, duration: 0.3, curve: .EaseInOut)
    }
    
    func moveScreenDown() {
        shiftScreenYPosition(0, duration: 0.2, curve: .EaseInOut)
    }
    
    func shiftScreenYPosition(position: CGFloat, duration: NSTimeInterval, curve: UIViewAnimationCurve) {
        UIView.beginAnimations("moveView", context: nil)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationDuration(duration)
        
        topContainer.frame.origin.y = position
        UIView.commitAnimations()
    }
    
    func backgroundTap(sender: UITapGestureRecognizer) {
        topContainer.endEditing(true)
        moveScreenDown()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (keyboardSize == 0) {
            if let keyboardRect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardSize = min(keyboardRect.height, keyboardRect.width)
            }
        }
        moveScreenUp()
    }
    
    func setAnimationOffsetForTextField(textField: UITextField) {
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let textFieldHeight = textField.frame.size.height
        let textFieldY = textField.convertPoint(CGPointZero, toView: topContainer).y
        
        animationOffset = -screenHeight + textFieldY + textFieldHeight
    }
    
    func setTextField(textField: UITextField, returnKeyType type: UIReturnKeyType) {
        if (textField.isFirstResponder()) {
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
