//
//  RootView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/10.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

struct ContentView: View {
    @StateObject var contentViewModel = AppViewModel()
    
    @StateObject var viewModel = ChatRoomsViewModel()
   
    var body: some View {
        if contentViewModel.isAuthenticated {
            VStack {
                MapView(chatRoomsViewModel: viewModel)
            }

        } else {
            LoginView(isLoggedIn: $contentViewModel.isAuthenticated)
                .onOpenURL { url in
                                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                    _ = AuthController.handleOpenUrl(url: url)
                                }
                            }
        }
    }
}
