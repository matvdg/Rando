//
//  CollectionDateView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CollectionDateView: View {
    
    @Binding var showEditDateSheet: Bool
    
    var body: some View {
        DatePicker(selection: .constant(Date()), label: { Text("Date") })
    }
}

#Preview {
    CollectionDateView(showEditDateSheet: .constant(true))
}
