//
//  DocumentView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 07/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import SwiftUI
import MobileCoreServices

struct DocumentView: UIViewControllerRepresentable {

    var callback: (URL) -> ()
    private let onDismiss: () -> Void

    init(callback: @escaping (URL) -> (), onDismiss: @escaping () -> Void) {
        self.callback = callback
        self.onDismiss = onDismiss
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentView>) {
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.xml], asCopy: true)
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentView
        init(_ pickerController: DocumentView) {
            self.parent = pickerController
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.callback(urls[0])
            parent.onDismiss()
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onDismiss()
        }
    }
}
