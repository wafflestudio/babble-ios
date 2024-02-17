//
//  ChatroomInfoView.swift
//  babble
//
//  Created by Chaehyun Park on 2/18/24.
//

import SwiftUI

struct ChatroomInfoView: View {
    weak var delegate: ChatroomInfoViewDelegate?
    var room: Room?
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldNavigateToChatRoom = false
    
    var body: some View {
        VStack {
            header
            chatroomDetails
            enterChatroomButton
        }
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    var header: some View {
        Text(room!.name)
            .font(.headline)
            .padding(10)
    }

    var chatroomDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "graduationcap.fill")
                Text(room!.hashTag) // "Participants: X people"
            }

            HStack {
                Image(systemName: "map.fill")
                Text("거리: \(room!.distance)m") // "Location: Description"
            }
        }
        .padding(.horizontal)
    }

    var enterChatroomButton: some View {
        Button(action: {
            self.delegate?.didRequestToJoinChatroom(room!)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("채팅방 참여하기") // "Enter Chatroom"
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(25)
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}
