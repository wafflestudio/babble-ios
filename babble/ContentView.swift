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
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "isLogin")

    @StateObject var viewModel = ChatRoomsViewModel()

    var body: some View {
        //if isLoggedIn {
            //VStack {
                MapView()
                /*NavigationView {
                    List(viewModel.rooms) { room in
                        VStack(alignment: .leading) {
                            Text(room.name)
                                .font(.headline)
                            Text("#\(room.hashTag)")
                                .font(.subheadline)
                        }
                    }
                    .navigationTitle("Chat Rooms")
                    .onAppear {
                        viewModel.fetchChatRooms(longitude: "0.0", latitude: "0.0")
                    }
                }*/
            //}

        /*} else {
           LoginView(isLoggedIn: $isLoggedIn)
                .onOpenURL { url in
                                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                    _ = AuthController.handleOpenUrl(url: url)
                                }
                            }
        }*/
    }
}
