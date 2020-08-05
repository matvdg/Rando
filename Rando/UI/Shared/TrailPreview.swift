//
//  TrailPreview.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailPreview: View {
    
    var points: [CGPoint]
    var body: some View {
        Path { path in
            path.move(to: points[0])
            points.forEach {
                path.addLine(to: $0)
            }
        }
        .stroke(Color.tintColor, lineWidth: 1)
    }
}

struct TrailPreview_Previews: PreviewProvider {
    static var previews: some View {
        TrailPreview(points: [CGPoint(x: 1, y: 1), CGPoint(x: 10, y: 1), CGPoint(x: 1, y: 10)])
    }
}
