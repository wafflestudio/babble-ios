//
//  ContentViewModel.swift
//  babble
//
//  Created by Chaehyun Park on 2/18/24.
//

import Foundation

class AppViewModel: ObservableObject {
    @Published var isAuthenticated = UserDefaults.standard.bool(forKey: "isLogin")

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(authTokenExpired), name: NSNotification.Name("AuthTokenExpired"), object: nil)
    }
    
    @objc private func authTokenExpired() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}
