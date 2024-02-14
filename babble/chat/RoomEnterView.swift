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
        VStack{
            Button{
                onBackButtonPressed()
            }label:{
                Image(systemName: "chevron.left")
            }
            TextField("닉네임",text:$nickname)
            Button{
                viewModel.enterRoom(nickname: nickname)
            }label:{
                Text("입장")
            }
        }
    }
}

