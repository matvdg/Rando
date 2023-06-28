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
                Section(header: Text("Rename")) {
                    TextField("RenameDescription", text: $nameInput, axis: .vertical)
                        .focused($isFocused)
                        .textInputAutocapitalization(.sentences)
                }
                
                Section(header: Text("Description")) {
                    TextField(trail.description.isEmpty ? "AddDescription" : "EditDescription", text: $descriptionInput, axis: .vertical)
                        .focused($isFocused)
                        .lineLimit(15...15)
                        .textInputAutocapitalization(.sentences)
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Edit", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("Cancel", action: {
                showEditTrailSheet = false
            })
            .foregroundColor(.tintColorTabBar)
                                , trailing:
                                    Button("Save", action: {
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

struct EditDescriptionView_Previews: PreviewProvider {
    
    @State static var showEditTrailSheet: Bool = true
    
    static var previews: some View {
        EditTrailView(trail: Trail(), showEditTrailSheet: $showEditTrailSheet)
    }
}
