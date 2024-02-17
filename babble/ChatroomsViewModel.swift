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

    func fetchChatRooms(longitude: Double, latitude: Double, completion: @escaping () -> Void) {
        network.loadChatrooms(longitude: longitude, latitude: latitude) { rooms in
            DispatchQueue.main.async {
                self.rooms = rooms
                completion()
            }
        }
    }
}
