//
//  RoomEnterView.swift
//  babble
//
//  Created by 박정헌 on 2/14/24.
//

import SwiftUI

struct RoomEnterView: View {
    @State
    var nickname:String = ""
    @ObservedObject
    var viewModel:ChatViewModel
    let onBackButtonPressed:()->()
    var body: some View {
        VStack(alignment: .center){
            ChatHeaderView(name: viewModel.chatroom.name, tag: viewModel.chatroom.hashTag, members_count: viewModel.chatterCount, onBackButtonPressed: {
                onBackButtonPressed()
            })
            Text("채팅방 참여하기")
         /*   Button{
                onBackButtonPressed()
            }label:{
                Image(systemName: "chevron.left")
            }*/
            TextField("닉네임", text: $nickname, axis: .vertical)    .background(RoundedRectangle(cornerRadius: 5).fill(Color("Blue5")))
                .padding()
            Button{
                viewModel.enterRoom(nickname: nickname)
            }label:{
                Text("입장")
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .topLeading)
    }
}

