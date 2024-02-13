//
//  LoginView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/10.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    private let network = Network()

    var body: some View {
        Button("Login with Kakao") {
            print("button pressed")
            network.kakaoLogin { result in
                if result == "success" {
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    isLoggedIn = true
                } else {
                    print("Login failed")
                }
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
