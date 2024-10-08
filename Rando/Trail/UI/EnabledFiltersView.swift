//
//  EnabledFiltersView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 27/05/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct EnabledFiltersView: View {
    
    @Binding var onlyDisplayed: Bool
    @Binding var onlyFavs: Bool
    @Binding var onlyLoops: Bool
    @Binding var grFilter: GRFilter
    @Binding var difficultyFilter: DifficultyFilter
    @Binding var department: String
    @Binding var searchText: String
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(alignment: .center, spacing: 8) {
                
                Spacer()
                
                Button {
                    Feedback.selected()
                    searchText = ""
                } label: {
                    FilterButton(label: searchText)
                }
                .isHidden(searchText.isEmpty, remove: true)
                
                Button {
                    Feedback.selected()
                    onlyFavs.toggle()
                } label: {
                    FilterButton(label: "favs".localized)
                }
                .isHidden(!onlyFavs, remove: true)
                
                Button {
                    Feedback.selected()
                    onlyDisplayed.toggle()
                } label: {
                    FilterButton(label: "displayed".localized)
                }
                .isHidden(!onlyDisplayed, remove: true)
                
                Button {
                    Feedback.selected()
                    onlyLoops.toggle()
                } label: {
                    FilterButton(label: "loops".localized)
                }
                .isHidden(!onlyLoops, remove: true)
                
                Button {
                    Feedback.selected()
                    department = "all"
                } label: {
                    FilterButton(label: department)
                }
                .isHidden(department == "all", remove: true)
                
                Button {
                    Feedback.selected()
                    grFilter = .all
                } label: {
                    FilterButton(label: grFilter.localized)
                }
                .isHidden(grFilter == .all, remove: true)
                
                Button {
                    Feedback.selected()
                    difficultyFilter = .all
                } label: {
                    FilterButton(label: difficultyFilter.localized)
                }
                .isHidden(difficultyFilter == .all, remove: true)
                
                Spacer()
            }
        }
        .background(.clear)
        .foregroundColor(.primary)
        
    }
}

#Preview {
    EnabledFiltersView(onlyDisplayed: .constant(true), onlyFavs: .constant(true), onlyLoops: .constant(true), grFilter: .constant(.gr), difficultyFilter: .constant(.medium), department: .constant("Ariège"), searchText: .constant("Cagateille"))
}
