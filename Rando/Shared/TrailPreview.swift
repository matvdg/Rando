//
//  TrailPreview.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailPreview: View {
    
    var color: Color
    var points: [CGPoint]
    var lineWidth: CGFloat = 1
    
    var body: some View {
        if let firstPoint = points.first {
            Path { path in
                path.move(to: firstPoint)
                points.forEach {
                    path.addLine(to: $0)
                }
            }
            .stroke(color, lineWidth: lineWidth)
        }
        
    }
}

struct TrailPreview_Previews: PreviewProvider {
    static var previews: some View {
        TrailPreview(color: .red, points: [CGPoint(x: 1, y: 1), CGPoint(x: 10, y: 1), CGPoint(x: 1, y: 10)])
    }
}
