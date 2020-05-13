//
//  UISelectionFeedback.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 13/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation

import UIKit

class Feedback {
    
    class func selected() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    class func success() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    class func failed() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
    }
}
