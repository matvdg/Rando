//
//  GridStack.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/08/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct GridStack<Content: View>: View {
    
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(0 ..< self.rows, id: \.self) { row in
                HStack(alignment: .top, spacing: 20) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
            
        }
    }
    
}
