//
//  ChatViewModel.swift
//  babble
//
//  Created by 박정헌 on 2/13/24.
//

import Foundation
import SwiftUI
struct ChatDay:Identifiable{
    struct Chat:Identifiable{
        var id: Int
        
        let nickname:String
        let time:String
        let content:String
        let color:Color
    }
    var id: Int
    let date:String
    var chats:[Chat]
    static func from(response:ChatsResponse)->[ChatDay]{
        var chatdays:[ChatDay] = []
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "y년 M월 d일"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "a h시 m분"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        for chat in response.chats.reversed(){
            let date = Date(timeIntervalSince1970: TimeInterval(chat.createdTimeInSec))
            let day = dayFormatter.string(from: date)
            let time = timeFormatter.string(from: date)
            if chatdays.isEmpty || chatdays.last!.date != day{
                chatdays.append(ChatDay(id: chatdays.count, date: day, chats: [Chat(id: chat.id, nickname: chat.chatterNickname, time: time, content: chat.content, color: colorFromNickname(chat.chatterNickname))]))
            }
            else{
                chatdays[chatdays.count - 1].chats.append(Chat(id: chat.id, nickname: chat.chatterNickname, time: time, content: chat.content, color: colorFromNickname(chat.chatterNickname)))
            }
            
        }
        return chatdays
    }
    static func colorFromNickname(_ nickname:String)->Color{
        let hash = nickname.hashValue
        let blue = hash % 256
        let green = hash / 256 % 256
        let red = hash / 256 / 256 % 256
        let color = Color(red: Double(red)/255.0, green: Double(green)/255.0, blue: Double(blue)/255.0)
        return color
    }
}
class ChatViewModel:ObservableObject{
    let network = Network()
    private var timer:Timer?
    @Published
    var chatDays:[ChatDay] = []
    @Published
    var notEntered:Bool = false
    @Published
    var chatroom: Room
    @Published
    var chatterCount:Int = 0
    init(chatRoom:Room) {
               
        self.chatroom = chatRoom
        network.loadChats(longitude: "0.0", latitude: "0.0", id: chatroom.id, completion: {[weak self]
            response in
            self?.notEntered = !response.isChatter
            self?.chatDays = ChatDay.from(response: response)
            self?.chatroom = response.room
            self?.chatterCount = response.chatterCount
            self?.startPolling()
        }, onError: {
            _ in
        })
    }
    private func startPolling(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){
            [weak self]
            timer in
            self?.network.loadChats(longitude: "0.0", latitude: "0.0", id: self!.chatroom.id){[weak self]
                response in
                self?.chatroom = response.room
                self?.chatDays = ChatDay.from(response: response)
                self?.chatterCount = response.chatterCount
                self?.notEntered = !response.isChatter
            }onError: { error in
                
            }
        }    }
    func enterRoom(nickname:String){
        network.enterChatroom(longitude: "0.0", latitude: "0.0", id: chatroom.id, nickname: nickname) { [weak self]
            response in
            self?.notEntered = false
        } onError:{
            error in
            
        }
    }
    func stopPolling(){
        timer?.invalidate()
    }
    
    
}
