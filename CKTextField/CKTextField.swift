//
//  CKTextField.swift
//  TextFieldDemo
//
//  Created by Christian Klaproth on 22.06.15.
//  Copyright (c) 2015 Christian Klaproth. All rights reserved.
//

import UIKit

enum CKTextFieldValidationResult: Int {
    case CKTextFieldValidationUnknown = 0, CKTextFieldValidationPassed, CKTextFieldValidationFailed
}

@objc protocol CKTextFieldValidationDelegate: NSObjectProtocol {
    optional func textField(textField: CKTextField, validationResult:Int, forText:String)
}

class CKTextField: UITextField, UITextFieldDelegate {

    // IB fields for attribute inspector
    @IBInspectable var validationType: String?
    @IBInspectable var minLength: String?
    @IBInspectable var maxLength: String?
    @IBInspectable var minValue: String?
    @IBInspectable var maxValue: String?
    @IBInspectable var pattern: String?

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
