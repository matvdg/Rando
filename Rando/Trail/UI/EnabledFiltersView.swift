//
//  EnabledFiltersView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 27/05/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct EnabledFiltersView: View {
    
    @Binding var onlyDisplayed: Bool
    @Binding var onlyFavs: Bool
    @Binding var gr10filter: Gr10filter
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
                    FilterButton(label: "Favs".localized)
                }
                .isHidden(!onlyFavs, remove: true)
                
                Button {
                    Feedback.selected()
                    onlyDisplayed.toggle()
                } label: {
                    FilterButton(label: "Displayed".localized)
                }
                .isHidden(!onlyDisplayed, remove: true)
                
                Button {
                    Feedback.selected()
                    department = "all"
                } label: {
                    FilterButton(label: department)
                }
                .isHidden(department == "all", remove: true)
                
                Button {
                    Feedback.selected()
                    gr10filter = .all
                } label: {
                    FilterButton(label: gr10filter.localized)
                }
                .isHidden(gr10filter == .all, remove: true)
                
                
                Spacer()
            }
        }
        .background(.clear)
        .foregroundColor(.primary)
        
    }
}

struct EnabledFiltersView_Previews: PreviewProvider {
    
    @State static var onlyDisplayed: Bool = true
    @State static var onlyFavs: Bool = true
    @State static var gr10filter: Gr10filter = .notgr10
    @State static var department: String = "Ariège"
    @State static var searchText: String = "Cagateille"
    
    static var previews: some View {
        EnabledFiltersView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, gr10filter: $gr10filter, department: $department, searchText: $searchText)
    }
}
