//
//  CKTextField.swift
//  TextFieldDemo
//
//  Created by Christian Klaproth on 22.06.15.
//  Copyright (c) 2015 Christian Klaproth. All rights reserved.
//

import UIKit

enum CKTextFieldValidationResult: Int {
    case Unknown = 0, Passed, Failed
}

protocol CKTextFieldValidationDelegate: NSObjectProtocol {
    func textField(textField: CKTextField, validationResult:CKTextFieldValidationResult, forText:String)
}

/**
 * TODO override didSet for textAlignment -> create leftView on the fly
 * TODO override didSet for placeholder -> create placeholderLabel on the fly
 */
class CKTextField: UITextField, UITextFieldDelegate {

    // IB fields for attribute inspector
    @IBInspectable var validationType: String?
    @IBInspectable var minLength: String?
    @IBInspectable var maxLength: String?
    @IBInspectable var minValue: String?
    @IBInspectable var maxValue: String?
    @IBInspectable var pattern: String?

    static let VALIDATION_TYPE_INTEGER = "integer"
    static let VALIDATION_TYPE_TEXT = "text"
    
    var validationDelegate: CKTextFieldValidationDelegate?
    
    override var delegate: UITextFieldDelegate? {
        willSet {
            if (self.readyForExternalDelegate) {
                self.externalDelegate = self.delegate
            }
        }
        didSet(newDelegate) {
            if (!self.readyForExternalDelegate) {
                self.externalDelegate = newDelegate
            }
        }
    }

    // private instance variables
    private var originalPlaceholder: String?
    private var placeholderLabel: UILabel?
    private var placeholderHideInProgress = false
    private var readyForExternalDelegate = false
    private var externalDelegate: UITextFieldDelegate?
    private var acceptButton: UIButton?
    private var originalTextAlignment = NSTextAlignment.Natural

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let placeholder = self.placeholder {
            self.originalPlaceholder = placeholder
            self.delegate = self
            self.readyForExternalDelegate = true
            self.placeholder = nil
            
            self.placeholderLabel = UILabel(frame: CGRectMake(7.0, 0.0, self.bounds.width - 14.0, self.bounds.height))
            self.placeholderLabel!.backgroundColor = UIColor.clearColor()
            // placeholder color is not exactly gray ;)
            self.placeholderLabel!.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            self.placeholderLabel!.textAlignment = self.textAlignment
            self.placeholderLabel!.text = self.originalPlaceholder
            self.placeholderLabel!.font = self.font
            self.addSubview(self.placeholderLabel!)

            if (self.textAlignment == NSTextAlignment.Center) {
                self.originalTextAlignment = self.textAlignment
                let leftView = UIView(frame: CGRectMake(0.0, 0.0, self.bounds.width / 2 - 8, self.bounds.height))
                leftView.backgroundColor = UIColor.clearColor()
                leftView.userInteractionEnabled = false
                self.leftView = leftView
                self.leftViewMode = UITextFieldViewMode.WhileEditing
                self.textAlignment = NSTextAlignment.Left
            }

            if (count(self.text) > 0) {
                self.placeholderLabel!.hidden = true
            } else {
                self.placeholderLabel!.hidden = false
            }
            
            self.placeholderHideInProgress = false
        }
        
        self.acceptButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        self.acceptButton!.setBackgroundImage(UIImage(named: "accept"), forState: UIControlState.Normal)
        self.acceptButton!.frame = CGRectMake(self.bounds.width, 2.0, self.bounds.height - 4.0, self.bounds.height - 4.0)
        self.acceptButton!.backgroundColor = UIColor(red: 0.5, green: 0.75, blue: 0.5, alpha: 1.0)
        self.acceptButton!.layer.cornerRadius = self.bounds.height - 4.0 / 2
        self.acceptButton!.userInteractionEnabled = true
        self.acceptButton!.hidden = true
        self.acceptButton!.addTarget(self, action: "acceptButtonTouchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.acceptButton!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if let label = self.placeholderLabel {
            label.frame = CGRectMake(7.0, 0.0, self.bounds.width - 14.0, self.bounds.height)
        }

        if (self.originalTextAlignment == NSTextAlignment.Center) {
            if let view = self.leftView {
                view.frame = CGRectMake(0.0, 0.0, self.bounds.width / 2 - 8, self.bounds.height);
            }
        }
    }

    override var text: String! {
        get {
            return super.text
        }
        set(newText) {
            if (self.performValidationOnInput(newText)) {
                super.text = newText
                self.sendActionsForControlEvents(UIControlEvents.EditingChanged)
                
                if let placeholderLabel = self.placeholderLabel {
                    if (count(self.text) == 0 && placeholderLabel.hidden) {
                        if (self.originalTextAlignment == NSTextAlignment.Center) {
                            self.leftView?.frame = CGRectMake(0.0, 0.0, self.bounds.width / 2 - 8, self.bounds.height)
                            self.textAlignment = NSTextAlignment.Left
                        }
                        placeholderLabel.alpha = 0.0
                        placeholderLabel.hidden = false
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            placeholderLabel.alpha = 1.0
                        })
                    } else if (count(self.text) > 0 && !placeholderLabel.hidden) {
                        if (self.originalTextAlignment == NSTextAlignment.Center) {
                            self.leftView?.frame = CGRectMake(0.0, 0.0, 0.0, self.bounds.height)
                            self.textAlignment = NSTextAlignment.Center
                        }
                        
                        if (!self.placeholderHideInProgress) {
                            self.placeholderHideInProgress = true
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                placeholderLabel.alpha = 0.0
                                placeholderLabel.transform = CGAffineTransformMakeScale(1.1, 1.1)
                            }, completion: { (finished) -> Void in
                                placeholderLabel.hidden = true
                                placeholderLabel.transform = CGAffineTransformIdentity
                                self.placeholderHideInProgress = false
                            })
                        }
                    }
                }
            }
        }
    }
    
    func performValidationOnInput(text: String) -> Bool {
        if let type = self.validationType {
            if (type == CKTextField.VALIDATION_TYPE_TEXT) {
                let minLength: Int
                let maxLength: Int
                if let pattern = self.pattern {
                    minLength = count(pattern)
                    maxLength = count(pattern)
                } else {
                    if let min = self.minLength {
                        minLength = min.toInt()!
                    } else {
                        minLength = 0
                    }
                    if let max = self.maxLength {
                        maxLength = max.toInt()!
                    } else {
                        maxLength = Int.max
                    }
                }
                
                if (count(text) < minLength) {
                    if let delegate = self.validationDelegate {
                        delegate.textField(self, validationResult: CKTextFieldValidationResult.Unknown, forText: text)
                    }
                    return true
                }
                
                if (count(text) > maxLength) {
                    if let delegate = self.validationDelegate {
                        delegate.textField(self, validationResult: CKTextFieldValidationResult.Failed, forText: text)
                    }
                    return false
                }
                
                if let delegate = self.validationDelegate {
                    delegate.textField(self, validationResult: CKTextFieldValidationResult.Passed, forText: text)
                }
                return true
            }
        }
        return true
    }
    
    // MARK: visual effect methods
    
    func shake() {
        self.layer.transform = CATransform3DMakeTranslation(10.0, 0.0, 0.0)
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.transform = CATransform3DIdentity
        }, completion: { (finished) -> Void in
            self.layer.transform = CATransform3DIdentity
        })
    }
    
    func showAcceptButton() {
        if let button = self.acceptButton {
            button.alpha = 0.0
            button.hidden = false
            self.bringSubviewToFront(button)
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                button.alpha = 1.0
                button.transform = CGAffineTransformMakeTranslation(-self.bounds.height + 2.0, 0)
            }, completion: { (finished) -> Void in
                button.alpha = 1.0
            })
        }
    }
    
    func hideAcceptButton() {
        if let button = self.acceptButton {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                button.alpha = 0.0
            }, completion: { (finished) -> Void in
                button.hidden = true
                button.transform = CGAffineTransformIdentity
            })
        }
    }
    
    private func acceptButtonTouchUpInside() {
        self.hideAcceptButton()
        self.resignFirstResponder()
    }

}
