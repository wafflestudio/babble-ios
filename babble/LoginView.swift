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
        VStack (spacing: 30) {
            Text("babble")
                .font(.system(size: 70))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "0C2FF2"))
                .padding(EdgeInsets(top: 100, leading: 0, bottom: 100, trailing: 0))

            Button(action: {
                print("button pressed")
                network.kakaoLogin { result in
                    if result == "success" {
                        UserDefaults.standard.set(true, forKey: "isLogin")
                        isLoggedIn = true
                    } else {
                        print("Login failed")
                    }
                }
            }) {
                // Assuming you have an image named 'kakaoLogin' in your asset catalog
                Image("KakaoLogin") // Use Image(uiImage: UIImage(named: "yourImageName")!) if you need to initialize from a UIImage
                    .resizable() // Make the image resizable
                    .aspectRatio(contentMode: .fit) // Keep the aspect ratio of your image
                    .frame(width: 200, height: 50) // Set the desired frame for your button
            }
            .padding(.all, 10) // Add padding around the button if needed
            
            Spacer()
        }
    }
}

extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}
