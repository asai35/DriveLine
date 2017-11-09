//
//  LoginTextField.swift
//  DriveLine
//
//  Created by mac on 6/26/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//
import UIKit

class LoginTextField: UITextField {
    
    //---------------------------------------------------------------------
    // MARK: CHANGE RECTS FOR TEXT FIELD
    //---------------------------------------------------------------------
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return self.rectForBounds(bounds)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return self.rectForBounds(bounds)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        return self.rectForBounds(bounds)
    }
    
    //---------------------------------------------------------------------
    // MARK: CUSTOM METHOD (TO RETURN REQUIRED BOUNDS FOR TEXT IN TEXTFIELD)
    //---------------------------------------------------------------------
    
    let deltaX : CGFloat = 20.0
    
    func rectForBounds(_ bounds:CGRect) -> CGRect {
        
        return bounds.insetBy(dx: deltaX, dy: 5)
    }
}
