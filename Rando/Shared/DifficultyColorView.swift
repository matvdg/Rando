//
//  DifficultyColorView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/09/2024.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI



struct DifficultyColorView: View {
    
    var difficulty: Trail.Difficulty
    
    var body: some View {
        
        HStack(alignment:.bottom, spacing: 3) {
            switch difficulty {
            case .beginner:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 3)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 6)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 9)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 15)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
            case .easy:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 3)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: 3, height: 6)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 9)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 15)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
            case .medium:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 3)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: 3, height: 6)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 3, height: 9)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 15)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
            case .hard:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 3)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: 3, height: 6)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 3, height: 9)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 3, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: 3, height: 15)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
            case .extreme:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 3, height: 3)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: 3, height: 6)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 3, height: 9)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 3, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 3, height: 15)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
            }
            
        }
        .frame(width: 60, height: 10, alignment: .center)
    
    }
}

struct DifficultyColorView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DifficultyColorView(difficulty: .beginner).previewDisplayName("beginner")
            DifficultyColorView(difficulty: .easy).previewDisplayName("easy")
            DifficultyColorView(difficulty: .medium).previewDisplayName("medium")
            DifficultyColorView(difficulty: .hard).previewDisplayName("hard")
            DifficultyColorView(difficulty: .extreme).previewDisplayName("extreme")
        }
    }
}
