//
//  DifficultyColorView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/09/2024.
//  Copyright © 202width Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct DifficultyColorView: View {
    
    var difficulty: Trail.Difficulty
    
    var width: CGFloat = 5
    
    var body: some View {
        
        HStack(alignment:.bottom, spacing: width) {
            switch difficulty {
            case .beginner:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .easy:
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .medium:
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .hard:
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .extreme:
                Rectangle()
                    .fill(Color.red)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.red)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.red)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.red)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.red)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            }
            
        }
        .frame(width: 60, height: 10, alignment: .center)
    
    }
}

struct DifficultyMultiColorView: View {
    
    var difficulty: Trail.Difficulty
    
    var width: CGFloat = 5
    
    var body: some View {
        
        HStack(alignment:.bottom, spacing: width) {
            switch difficulty {
            case .beginner:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.primary, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .easy:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .medium:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .hard:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.background)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            case .extreme:
                Rectangle()
                    .fill(Color.green)
                    .frame(width: width, height: 10)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.grgreen)
                    .frame(width: width, height: 12)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width, height: 14)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: width, height: 16)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color.red)
                    .frame(width: width, height: 18)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 1)
                    )
            }
            
        }
        .frame(width: 60, height: 10, alignment: .center)
    
    }
}

struct DifficultyView: View {
    
    var difficulty: Trail.Difficulty
    
    var body: some View {
        
        HStack(spacing: 3) {
            
            switch difficulty {
            case .beginner:
                Circle().foregroundColor(.primary)
                Circle().stroke(Color.primary, lineWidth: 1)
                Circle().stroke(Color.primary, lineWidth: 1)
                Circle().stroke(Color.primary, lineWidth: 1)
                Circle().stroke(Color.primary, lineWidth: 1)
            case .easy:
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().stroke(Color.primary, lineWidth: 1)
                Circle().stroke(Color.primary, lineWidth: 1)
                Circle().stroke(Color.primary, lineWidth: 1)
            case .medium:
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().stroke(Color.primary, lineWidth: 1)
                Circle().stroke(Color.primary, lineWidth: 1)
            case .hard:
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().stroke(Color.primary, lineWidth: 1)
            case .extreme:
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
                Circle().foregroundColor(.primary)
            }
            
        }
        .frame(width: 60, height: 10, alignment: .center)
    
    }
}

#Preview {
    HStack(alignment: .center, spacing: 30) {
        Spacer()
        VStack(alignment: .center, spacing: 30) {
            Text("difficultyColorView")
            DifficultyColorView(difficulty: .beginner)
            DifficultyColorView(difficulty: .easy)
            DifficultyColorView(difficulty: .medium)
            DifficultyColorView(difficulty: .hard)
            DifficultyColorView(difficulty: .extreme)
        }
        Spacer()
        VStack(alignment: .center, spacing: 30) {
            Text("difficultyMultiColorView")
            DifficultyMultiColorView(difficulty: .beginner)
            DifficultyMultiColorView(difficulty: .easy)
            DifficultyMultiColorView(difficulty: .medium)
            DifficultyMultiColorView(difficulty: .hard)
            DifficultyMultiColorView(difficulty: .extreme)
        }
        Spacer()
        VStack(alignment: .center, spacing: 30) {
            Text("difficultyView")
            DifficultyView(difficulty: .beginner)
            DifficultyView(difficulty: .easy)
            DifficultyView(difficulty: .medium)
            DifficultyView(difficulty: .hard)
            DifficultyView(difficulty: .extreme)
        }
        Spacer()
    }
}
