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
    var body: some View {
        VStack{
            TextField("닉네임",text:$nickname)
            Button{
                viewModel.enterRoom(nickname: nickname)
            }label:{
                Text("입장")
            }
        }
    }
}

