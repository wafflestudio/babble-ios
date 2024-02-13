//
//  ChatView.swift
//  babble
//
//  Created by 박정헌 on 2024/02/09.
//

import Foundation
import SwiftUI


struct ChatRoom{
    let name:String
    let tag:String
    let members_count:Int
}
struct ChatModel:Identifiable{
    var id: Int
    
    let nickname:String
    let time:String
    let content:String
    let color:Color
}
struct DayChats:Identifiable{
    var id: Int
    let date:String
    let chats:[Chat]
    
}
struct ChatRoomView:View{
    let chatRoom:ChatRoom
    let chats:[DayChats]
    var body: some View{
        VStack(spacing: 0.0){
            ChatHeaderView(name: chatRoom.name, tag: chatRoom.tag, members_count:     chatRoom.members_count)
            ChatDisplayView(chats:chats)
            
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                ).padding(EdgeInsets(top: 5.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
            WriteView()
        }
    }
}


struct ChatDisplayView:View{
    let chats:[DayChats]
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







var sample_chat = [
    Chat(id: 1, nickname: "user1", time: "2:30", content: "안녕하세요", color: .yellow),
    Chat(id: 2, nickname: "user1", time: "2:30", content: "안녕하세요2", color: .yellow),
    Chat(id: 3, nickname: "user1", time: "2:30", content: "안녕하세요3", color: .yellow),
    Chat(id: 4, nickname: "user1", time: "2:30", content: "안녕하세요4", color: .yellow),
    Chat(id: 5, nickname: "user1", time: "2:30", content: "안녕하세요5", color: .yellow),
    Chat(id: 6, nickname: "user1", time: "2:30", content: "안녕하세요6\n안녕하세요", color: .yellow)
]
var sample_chat2 = [
    Chat(id: 11, nickname: "user1", time: "2:30", content: "안녕하세요", color: .yellow),
    Chat(id: 12, nickname: "user1", time: "2:30", content: "안녕하세요2", color: .yellow),
    Chat(id: 13, nickname: "user1", time: "2:30", content: "안녕하세요3", color: .yellow),
    Chat(id: 14, nickname: "user1", time: "2:30", content: "안녕하세요4", color: .yellow),
    Chat(id: 15, nickname: "user1", time: "2:30", content: "안녕하세요5", color: .yellow),
    Chat(id: 16, nickname: "user1", time: "2:30", content: "안녕하세요6", color: .yellow)
]
var sample_chat3 = [
    Chat(id: 21, nickname: "user1", time: "2:30", content: "안녕하세요", color: .yellow),
    Chat(id: 22, nickname: "user1", time: "2:30", content: "안녕하세요2", color: .yellow),
    Chat(id: 23, nickname: "user1", time: "2:30", content: "안녕하세요3", color: .yellow),
    Chat(id: 24, nickname: "user1", time: "2:30", content: "안녕하세요4", color: .yellow),
    Chat(id: 25, nickname: "user1", time: "2:30", content: "안녕하세요5", color: .yellow),
    Chat(id: 26, nickname: "user1", time: "2:30", content: "안녕하세요6", color: .yellow)
]
var dayChats = [DayChats(id: 1, date: "2024년 1월 10일", chats: sample_chat),DayChats(id: 2, date: "2024년 1월 11일", chats: sample_chat2),DayChats(id: 3, date: "2024년 1월 12일", chats: sample_chat3)]
struct ChatView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChatRoomView(chatRoom: ChatRoom(name: "중앙도서관채팅방", tag: "#도서관", members_count: 20), chats: dayChats)
    }
}
