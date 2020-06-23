//
//  ImagePicker.swift
//  Scannerator
//
//  Created by Andrew Pirkl on 6/21/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Vision

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    var completion: (Result<String, ScanError>) -> Void

    init(completion: @escaping (Result<String, ScanError>)->Void) {
        self.completion = completion
    }
    
//    func startDetection() {
//       let request = VNDetectBarcodesRequest(completionHandler: self.detectHandler)
//        request.symbologies = [.Code39] // or use .QR, etc
//       self.requests = [request]
//    }
//
//    func detectHandler(request: VNRequest, error: Error?) {
//        guard let observations = request.results else {
//            //print("no result")
//            return
//        }
//        let results = observations.map({$0 as? VNBarcodeObservation})
//        for result in results {
//              print(result!.payloadStringValue!)
//        }
//    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
        }
        return picker
    }
    

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker

    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func detectHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            self.parent.completion(.failure(.badOutput))
            return
        }
        let results = observations.map({$0 as? VNBarcodeObservation})
        for result in results {
              print(result!.payloadStringValue!)
            print("somethiong")
            parent.completion(.success(result!.payloadStringValue ?? ""))
        }
        print(results)
        self.parent.presentationMode.wrappedValue.dismiss()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let qrcodeImg = info[.originalImage] as? UIImage {
  
            let imageRequestHandler = VNImageRequestHandler(cgImage: qrcodeImg.cgImage!,
                                                            orientation: CGImagePropertyOrientation(qrcodeImg.imageOrientation), options: [:])
            let barcodeRequest = VNDetectBarcodesRequest(completionHandler: detectHandler)
            barcodeRequest.symbologies = [ .Aztec, .Code128, .Code39, .Code93, .DataMatrix, .EAN13, .EAN8, .ITF14, .PDF417, .UPCE, .QR]
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try imageRequestHandler.perform([barcodeRequest])

                } catch let error as NSError {
                    print("Failed to perform image request: \(error)")
                    self.parent.completion(.failure(.badOutput))
//                    self.presentAlert("Image Request Failed", error: error)
                    self.parent.presentationMode.wrappedValue.dismiss()
                    return
                }
            }
//
//            if qrCodeLink.count < 1 {
//                parent.completion(.failure(.badOutput))
//            }else{
//                parent.completion(.success(qrCodeLink))
//            }
        }
        else{
            print("Something went wrong")
        }
//        parent.presentationMode.wrappedValue.dismiss()
    }
}
