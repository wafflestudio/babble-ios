//
//  RootView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/10.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

/*struct ContentView: View {
    @StateObject var contentViewModel = AppViewModel()
    
    @StateObject var viewModel = ChatRoomsViewModel()
   
    var body: some View {
        if contentViewModel.isAuthenticated {
            MapView(chatRoomsViewModel: viewModel)
        } else {
            ZStack {
                Color(hex: "80A6F2").edgesIgnoringSafeArea(.all)
                LoginView(isLoggedIn: $contentViewModel.isAuthenticated)
                    .onOpenURL { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            _ = AuthController.handleOpenUrl(url: url)
                        }
                    }
            }
        }
    }
}
*/

struct ContentView: View {
    @StateObject var contentViewModel = AppViewModel()
    
    @StateObject var viewModel = ChatRoomsViewModel()

    var body: some View {
        if contentViewModel.isAuthenticated {
            MapView(chatRoomsViewModel: viewModel)
        } else {
            FloatingBubblesBackground {
                // Your LoginView content here
                LoginView(isLoggedIn: $contentViewModel.isAuthenticated)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct FloatingBubblesBackground<Content: View>: View {
    let content: Content
    private let bubbleCount = 30 // Adjust the number of bubbles as needed

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            ForEach(0..<bubbleCount, id: \.self) { _ in
                BubbleView()
            }
            content
        }
        .background(Color.lightBlue.edgesIgnoringSafeArea(.all)) // Your light blue background color
    }
}

struct BubbleView: View {
    @State private var isAnimating = false

    // Generate random properties for each bubble
    private let size = CGFloat.random(in: 10...30)
    private let speed = Double.random(in: 7...20)
    private let delay = Double.random(in: 0...2)
    private let opacity = Double.random(in: 0.3...0.7)
    private let positionX = CGFloat.random(in: 0...UIScreen.main.bounds.width)

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .position(x: positionX, y: isAnimating ? -100 : UIScreen.main.bounds.height + 100)
            .animation(
                Animation.linear(duration: speed)
                    .delay(delay)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension Color {
    static let lightBlue = Color(red: 173/255, green: 216/255, blue: 230/255) // Define your light blue color
}
