//
//  ImagePicker.swift
//  Scannerator
//
//  Created by Andrew Pirkl on 6/21/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

// not currently implemented
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
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.failure(.noCamera))
            return picker
        }
        picker.sourceType = .camera
        
        picker.showsCameraControls = false
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            picker.takePicture()
        }
        
//        var myView = UIView()
//        myView.frame = (picker.cameraOverlayView?.frame)!
//        picker.cameraOverlayView = myView
        picker.cameraOverlayView = guideForCameraOverlay()


    
        return picker
    }
    

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//        uiViewController.showsCameraControls = false
//        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
//        uiViewController.takePicture()
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func found(code: String) {
        self.completion(.success(code))
    }

    func didFail(reason: ScanError) {
        self.completion(.failure(reason))
    }
    
    func dismiss(){
        DispatchQueue.main.async {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    
    func guideForCameraOverlay() -> UIView {
        let guide = UIView(frame: UIScreen.main.fullScreenSquare())
        guide.backgroundColor = UIColor.clear
        guide.layer.borderWidth = 4
        guide.layer.borderColor = UIColor.red.cgColor
        guide.isUserInteractionEnabled = false
        return guide
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
            self.parent.dismiss()
            return
        }
        let results = observations.map({$0 as? VNBarcodeObservation})
        for result in results {
              print(result!.payloadStringValue!)
            print("somethiong")
            parent.completion(.success(result!.payloadStringValue ?? ""))
            self.parent.dismiss()
            return
        }
        print(results)
    }
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.parent.completion(.failure(.cancelled))
//        self.parent.dismiss()
//    }
    
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
                    self.parent.dismiss()
                    return
                }
            }
        }
        else{
            print("Something went wrong")
        }
    }
}



extension UIScreen {
    func fullScreenSquare() -> CGRect {
        var hw:CGFloat = 0
        var isLandscape = false
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
        hw = UIScreen.main.bounds.size.width
    }
    else {
        isLandscape = true
        hw = UIScreen.main.bounds.size.height
    }

    var x:CGFloat = 0
    var y:CGFloat = 0
    if isLandscape {
        x = (UIScreen.main.bounds.size.width / 2) - (hw / 2)
    }
    else {
        y = (UIScreen.main.bounds.size.height / 2) - (hw / 2)
    }
        return CGRect(x: x, y: y, width: hw, height: hw)
    }
    func isLandscape() -> Bool {
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}
