//
//  KakaoMapView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/11.
//

import KakaoMapsSDK
import SwiftUI
import UIKit

struct KakaoMapVCWrapper : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {  
        return CurrentPositionPOI()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
