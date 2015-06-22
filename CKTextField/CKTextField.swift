//
//  CKTextField.swift
//  TextFieldDemo
//
//  Created by Christian Klaproth on 22.06.15.
//  Copyright (c) 2015 creative-mindworks.de. All rights reserved.
//

import UIKit

enum CKTextFieldValidationResult: Int {
    case CKTextFieldValidationUnknown = 0, CKTextFieldValidationPassed, CKTextFieldValidationFailed
}

@objc protocol CKTextFieldValidationDelegate: NSObjectProtocol {
    optional func textField(textField: CKTextField, validationResult:Int, forText:String)
}

class CKTextField: UITextField {

    @IBInspectable var validationType: String?
    @IBInspectable var minLength: String?
    @IBInspectable var maxLength: String?
    @IBInspectable var minValue: String?
    @IBInspectable var maxValue: String?
    @IBInspectable var pattern: String?
    
}
