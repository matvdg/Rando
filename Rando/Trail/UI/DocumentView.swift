//
//  DocumentView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 07/07/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

let GPX_TYPE = "com.matvdg.rando.document.gpx"

extension UTType {
    static var gpx: UTType { UTType(exportedAs: GPX_TYPE) }
}

struct DocumentView: UIViewControllerRepresentable {
    
    private var callback: ([URL]) -> Void
    
    init(callback: @escaping ([URL]) -> ()) {
        self.callback = callback
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentView>) {}
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [
            .xml,
            UTType(filenameExtension: "gpx", conformingTo: .xml)!,
            UTType(filenameExtension: "gpx", conformingTo: .data)!,
            UTType(exportedAs: GPX_TYPE)
        ]
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = true
        return controller
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentView
        init(_ pickerController: DocumentView) {
            self.parent = pickerController
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.callback(urls)
        }
    }
}
