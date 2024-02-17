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
                ChatDisplayView(chats:viewModel.chatDays, viewModel: viewModel)
                
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    ).padding(EdgeInsets(top: 5.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                WriteView(onPost:{
                    content in
                    viewModel.postChat(content: content)
                }, parent:$viewModel.writingParentChat)
                /*   NavigationLink("enter chatroom", isActive: $viewModel.notEntered){
                 RoomEnterView(viewModel: viewModel)                    .navigationBarBackButtonHidden(true)
                 
                 }.frame(width: 0,height: 0).hidden()*/
                
            }
        }
        .alert("채팅방 위치에서 벗어났습니다.",isPresented: $viewModel.outOfLocation){
            Button("OK"){
                viewModel.stopPolling()
                viewModel.outOfLocation = false
                presentationMode.wrappedValue.dismiss()
            }
        }
     
        
        
    }
}


struct ChatDisplayView:View{
    let chats:[ChatDay]
    var viewModel:ChatViewModel
    var body:some View{
        ScrollViewReader{value in
            ScrollView{
                LazyVStack(alignment:.leading,pinnedViews: .sectionHeaders){
                    list(value:value)
                }
            }
        }
    }
    @ViewBuilder
    func chatsOfDay(value:ScrollViewProxy,chats:[ChatDay.Chat],isLastDay:Bool)->some View{
        ForEach(chats) { chat in
           ChatView(content: chat.content, time: chat.time, nickname: chat.nickname, color: chat.color, isMine: chat.isMine,parentId: chat.parentId,parentContent: chat.parentContent).id(Int(chat.id))
                    .onTapGesture {
                        if let parentId = chat.parentId{
                            value.scrollTo(parentId)
                        }
                    }.contextMenu(ContextMenu(menuItems: {
                Button(action: {
                    viewModel.writingParentChat = chat
                }, label: {
                    Text("답장")
                })
                
                
            }))
                   
            
                
        }
      
        .onChange(of:chats.count){
            if isLastDay{
                if let lastChat = chats.last{
                    value.scrollTo(Int(lastChat.id))
                }
            }
            
        }
    }
    @ViewBuilder
    func sectionHeader(text:String)->some View{
        Text(text)
            .font(.system(size:12))
            .padding(EdgeInsets(top: 5.0, leading: 10.0, bottom: 5.0, trailing: 10.0))
            .background(Color("Blue4").cornerRadius(5.0)).frame(minWidth: 0,maxWidth:.infinity)
            .background(Color.white)
    }
    @ViewBuilder
    func list(value:ScrollViewProxy)->some View {
        ForEach(chats) { dayChat in
            Section(header:sectionHeader(text:dayChat.date)){
                chatsOfDay(value: value, chats: dayChat.chats,isLastDay:((dayChat.id ) == (chats.last!.id)))
            }
        }
    }

}
struct ChatView:View{
    var content:String
    var time:String
    var nickname:String
    var color:Color
    var isMine:Bool
    var parentId:Int?
    var parentContent:String?
    var body:some View{
            VStack(alignment: isMine ? .trailing : .leading){
                if !isMine{
                    Text(nickname).font(.system(size:12))
                }
                HStack(alignment: .bottom){
                    if isMine{
                        timeView(time: time)
                        bubble(parentContent:parentContent,content: content)
                    } else{
                        bubble(parentContent:parentContent,content: content)
                        timeView(time:time)
                    }
                    
                }
            }.frame(width:UIScreen.main.bounds.width,alignment: isMine ? .trailing : .leading).padding(EdgeInsets(top: 5, leading: isMine ? -10 : 10, bottom: 5, trailing: 0))
            
        
    }
    func bubble(parentContent:String?,content:String)->some View{
        VStack(alignment: .leading){
                if let parentContent{
                    Text(parentContent).font(.system(size: 12))
                }
                Text(content)
            }.padding(EdgeInsets(top: 5.0, leading: 20.0, bottom: 5.0, trailing: 20.0))
                .background(color.clipShape(RoundedRectangle(cornerRadius: 20)))
               
        
      /*  else{
            Text(content).padding(EdgeInsets(top: 5.0, leading: 20.0, bottom: 5.0, trailing: 20.0))
                .background(color)
                .cornerRadius(20)
        }*/
    }
    func timeView(time:String)->some View{
        Text(time)
            .font(.system(size:12))
    }
    
    
}
struct WriteView:View{
    var onPost:(String)->()
    
    @Binding
    var parent:ChatDay.Chat?
    @State
    var text:String = ""
    @FocusState
     var isFocused:Bool
    var body:some View{
        VStack{
            if let curParent = parent{
                HStack{
                    Text(curParent.content)
                    Spacer()
                    Button(action: {
                        parent = nil
                    }, label: {
                        Text("x")
                    })
                }
            }
            HStack(alignment:.center){
                TextField("", text: $text, axis: .vertical)    .background(RoundedRectangle(cornerRadius: 5).fill(Color("Blue5"))).padding().focused($isFocused)
                
                Button(action: {
                    onPost(text)
                    text = ""
                    isFocused = false
                }, label: {
                    Image(systemName: "paperplane").foregroundColor(Color("Blue5"))
                }).padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 20.0))
            }
        }.background(Color("Blue4"))
    }
}








