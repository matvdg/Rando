//
//  CollectionPhotoGalleryView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import PhotosUI

struct CollectionPhotoGalleryView: View {
    
    var collectedPoi: CollectedPoi
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isShowingCameraPicker = false
    @State private var capturedImage: UIImage?
    @ObservedObject private var collectionManager = CollectionManager.shared
    
    var photos: [ImageWithId] { collectedPoi.photosUrl?.compactMap({ collectionManager.loadImage(name: $0) }) ?? [ImageWithId]() }
    
    var body: some View {
        HStack {
            if !(collectedPoi.photosUrl ?? []).isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        Spacer()
                        VStack {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                VStack {
                                    Image("iconPhotoLibrary")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .frame(maxHeight: .infinity)
                                .background(Color.grgreen)
                                .clipShape(Rectangle())
                                .cornerRadius(10)
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                        collectionManager.saveCollectionUserPicture(image: image, collectedPoi: collectedPoi)
                                    }
                                }
                            }
#if !targetEnvironment(macCatalyst)
                            Button(action: {
                                isShowingCameraPicker = true
                            }) {
                                VStack {
                                    Image("iconCamera")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .frame(maxHeight: .infinity)
                                .background(Color.grblue)
                                .clipShape(Rectangle())
                                .cornerRadius(10)
                            }
                            .sheet(isPresented: $isShowingCameraPicker, onDismiss: {
                                if let capturedImage = capturedImage {
                                    collectionManager.saveCollectionUserPicture(image: capturedImage, collectedPoi: collectedPoi)
                                    self.capturedImage = nil
                                }
                            }) {
                                CameraPicker(image: $capturedImage)
                            }
#endif
                        }
                        .frame(height: 200)
                        
                        ForEach(photos, id: \.self) { photo in
                            NavigationLink {
                                photo
                                    .image
                                    .resizable()
                                    .scaledToFill()
                            } label: {
                                PictureView(image: photo.image)
                                    .contextMenu {
                                        Button("delete", role: .destructive) {
                                            collectionManager.deleteCollectionUserPicture(id: photo.id, collectedPoi: collectedPoi)
                                        }
                                    }
                            }
                            
                        }
                        Spacer()
                    }
                }
            } else {
                HStack {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack {
                            Text("addPhoto").foregroundColor(.white)
                            Image("iconPhotoLibrary")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.grgreen)
                        .clipShape(Rectangle())
                        .cornerRadius(20)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                collectionManager.saveCollectionUserPicture(image: image, collectedPoi: collectedPoi)
                            }
                        }
                    }

#if !targetEnvironment(macCatalyst)
                    Button(action: {
                        isShowingCameraPicker = true
                    }) {
                        VStack {
                            Text("takePhoto").foregroundColor(.white)
                            Image("iconCamera")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100, alignment: .center)
                                .foregroundColor(.white)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.grblue)
                        .clipShape(Rectangle())
                        .cornerRadius(20)
                    }
                    .sheet(isPresented: $isShowingCameraPicker, onDismiss: {
                        if let capturedImage = capturedImage {
                            collectionManager.saveCollectionUserPicture(image: capturedImage, collectedPoi: collectedPoi)
                            self.capturedImage = nil
                            
                        }
                    }) {
                        CameraPicker(image: $capturedImage)
                    }
#endif
                }.padding()
            }
        }
    }
    
    
    
}

#Preview {
    CollectionPhotoGalleryView(collectedPoi: CollectionManager.shared.demoCollection)
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraPicker
        
        init(parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

class ImageWithId: Identifiable, Hashable, Equatable {
    
    static func == (lhs: ImageWithId, rhs: ImageWithId) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID
    var image: Image
    
    init(id: UUID, image: Image) {
        self.id = id
        self.image = image
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
