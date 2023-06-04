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

struct RandomPathPreview: View {
    
    var color: Color
    var lineWidth: CGFloat
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            Array(stride(from: 0, to: 200, by: 10)).forEach {
                path.addLine(to: CGPoint(x: $0, y: Int.random(in: 0...20)))
            }
        }
        .stroke(lineWidth: lineWidth)
        .fill(color)
        .frame(width: 200, height: 20)

    }
}

struct RandomPathPreview_Previews: PreviewProvider {
    static var previews: some View {
        RandomPathPreview(color: .red, lineWidth: 3)
    }
}

