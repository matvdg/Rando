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
            case .easy:
                Circle().foregroundColor(.green)
                Circle().foregroundColor(.lightgray)
                Circle().foregroundColor(.lightgray)
            case .medium:
                Circle().foregroundColor(.orange)
                Circle().foregroundColor(.orange)
                Circle().foregroundColor(.lightgray)
            case .hard:
                Circle().foregroundColor(.red)
                Circle().foregroundColor(.red)
                Circle().foregroundColor(.red)
            }
            
        }
        .frame(width: 30, height: 9, alignment: .center)
        
    
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
