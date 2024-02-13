//
//  babbleApp.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/08.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct babbleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    private let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String
    
    init() {
        // Kakao SDK 초기화
        if let key = kakaoKey {
            KakaoSDK.initSDK(appKey: key)
        } else {
            print("Kakao app key is missing.")
        }
    }
}
