//
//  ContentView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/08.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
     ChatRoomView(chatRoom: ChatRoom(name: "중앙도서관채팅방", tag: "#도서관", members_count: 20), chats: dayChats)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
