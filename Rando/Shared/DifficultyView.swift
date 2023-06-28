//
//  DifficultyView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI



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

struct DifficultyView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DifficultyView(difficulty: .easy).previewDisplayName("easy")
            DifficultyView(difficulty: .medium).previewDisplayName("medium")
            DifficultyView(difficulty: .hard).previewDisplayName("hard")
        }
    }
}
