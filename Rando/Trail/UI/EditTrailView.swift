import SwiftUI

struct EditTrailView: View {
    
    var trail: Trail
    @State var nameInput: String = ""
    @State var descriptionInput: String = ""
    @Binding var showEditTrailSheet: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        NavigationView {
            
            List {
                Section(header: Text("rename")) {
                    TextField("RenameDescription", text: $nameInput, axis: .vertical)
                        .focused($isFocused)
                        .textInputAutocapitalization(.sentences)
                }
                
                Section(header: Text("description")) {
                    TextField(trail.description.isEmpty ? "addDescription" : "editDescription", text: $descriptionInput, axis: .vertical)
                        .focused($isFocused)
                        .lineLimit(15...15)
                        .textInputAutocapitalization(.sentences)
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("edit", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("cancel", action: {
                showEditTrailSheet = false
            })
            .foregroundColor(.tintColorTabBar)
                                , trailing:
                                    Button("save", action: {
                trail.name = nameInput
                trail.description = descriptionInput
                TrailManager.shared.save(trail: trail)
                showEditTrailSheet = false
            })
            .foregroundColor(.tintColorTabBar))
            .onAppear {
                nameInput = trail.name
                descriptionInput = trail.description
                isFocused = true
            }
        }
        
    }
}

#Preview {
    EditTrailView(trail: Trail(), showEditTrailSheet: .constant(true))
}
