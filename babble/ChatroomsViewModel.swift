//
//  ChatroomsViewModel.swift
//  babble
//
//  Created by Chaehyun Park on 2/13/24.
//

import Foundation
import SwiftUI

class ChatRoomsViewModel: ObservableObject {
    let network = Network()
  
    @Published var rooms: [Room] = []

    func fetchChatRooms(longitude: String, latitude: String) {
        network.loadChatrooms(longitude: longitude, latitude: latitude) { rooms in
            DispatchQueue.main.async {
                self.rooms = rooms
            }
        }
    }
}
