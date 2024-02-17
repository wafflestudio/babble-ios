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
    var chatRoomsViewModel: ChatRoomsViewModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let kakaomapVC = KakaoMapVC()
        kakaomapVC.viewmodel = chatRoomsViewModel // Pass the ViewModel to the UIViewController
        return kakaomapVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
