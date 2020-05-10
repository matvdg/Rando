//
//  String.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension String {
  
  var localized: String { NSLocalizedString(self, comment: self) }
    
}
