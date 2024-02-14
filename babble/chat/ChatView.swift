//
//  ChatView.swift
//  babble
//
//  Created by 박정헌 on 2024/02/09.
//

import Foundation
import SwiftUI



struct ChatRoomView:View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject
    var viewModel: ChatViewModel
    var body: some View{
       
       
            NavigationView{
                VStack(spacing: 0.0){
                    ChatHeaderView(name: viewModel.chatroom.name, tag: viewModel.chatroom.hashTag, members_count:     viewModel.chatterCount){
                        viewModel.stopPolling()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    ChatDisplayView(chats:viewModel.chatDays)
                    
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        ).padding(EdgeInsets(top: 5.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                    WriteView()
                 /*   NavigationLink("enter chatroom", isActive: $viewModel.notEntered){
                        RoomEnterView(viewModel: viewModel)                    .navigationBarBackButtonHidden(true)
                        
                    }.frame(width: 0,height: 0).hidden()*/
                    
                }
            }.sheet(isPresented: $viewModel.notEntered, content: {
                RoomEnterView(viewModel: viewModel)                    .navigationBarBackButtonHidden(true)
            })
        
    }
}


struct ChatDisplayView:View{
    let chats:[ChatDay]
    var body:some View{
        
        ScrollView{
           LazyVStack(alignment:.leading,pinnedViews: .sectionHeaders){
                ForEach(chats) { dayChat in
                    Section(header:Text(dayChat.date).font(.system(size:12)).padding(EdgeInsets(top: 5.0, leading: 10.0, bottom: 5.0, trailing: 10.0)).background(Color("Blue4").cornerRadius(5.0)).frame(minWidth: 0,
                                               maxWidth: .infinity).background(Color.white)){
                        ForEach(dayChat.chats) { chat in
                            ChatView(content: chat.content, time: chat.time, nickname: chat.nickname, color: chat.color)
                        }
                    }
                }
            }
        }
    }
}
struct ChatView:View{
    var content:String
    var time:String
    var nickname:String
    var color:Color
    var body:some View{
        VStack(alignment: .leading){
            Text(nickname).font(.system(size:12))
            HStack(alignment: .bottom){
                Text(content)
                
                    .padding(EdgeInsets(top: 5.0, leading: 20.0, bottom: 5.0, trailing: 20.0))
                    .background(color)
                    .cornerRadius(20)
                Text(time)
                    .font(.system(size:12))
                
            }
        }.padding()
    }
    
    
}
struct WriteView:View{
    @State
    var text:String = ""
    @FocusState
    private var isFocused:Bool
    var body:some View{
        HStack(alignment:.center){
            TextField("", text: $text, axis: .vertical)    .background(RoundedRectangle(cornerRadius: 5).fill(Color("Blue5"))).padding().focused($isFocused)
               
            Button(action: {
                isFocused = false
            }, label: {
                Image(systemName: "paperplane").foregroundColor(Color("Blue5"))
            }).padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 20.0))
        }.background(Color("Blue4"))
    }
}








