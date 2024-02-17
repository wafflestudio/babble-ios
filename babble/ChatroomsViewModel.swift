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
    
    var latitude: Double?
    var longitude: Double?
    
    @Published var rooms: [Room] = []
    
    func fetchChatRooms(longitude: Double, latitude: Double, completion: @escaping () -> Void) {
        network.loadChatrooms(longitude: longitude, latitude: latitude) { rooms in
            DispatchQueue.main.async {
                self.rooms = rooms
                completion()
            }
        }
    }
    
    func createChatRoom(hashTag: String, nickname: String, roomName: String, completion: @escaping (Room) -> Void){
        if let latitude = self.latitude, let longitude = self.longitude {
            network.createChatRoom(hashTag: hashTag, latitude: latitude, longitude: longitude, nickname: nickname, roomName: roomName, completion: {[weak self] roomid in
                let newRoom = Room(distance: 0, hashTag: hashTag, id: roomid, latitude: latitude, longitude: longitude, name: roomName)
                DispatchQueue.main.async {
                    self?.rooms.append(newRoom)
                    completion(newRoom)
                }
            }, onError: { error in
                // Handle error
                print(error)
            })
        }
    }
}
