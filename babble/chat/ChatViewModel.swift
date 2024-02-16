//
//  ChatViewModel.swift
//  babble
//
//  Created by 박정헌 on 2/13/24.
//

import Foundation
import SwiftUI

typealias NetworkChat = Chat
struct ChatDay:Identifiable{
    struct Chat:Identifiable{
        var id: Int
        var isMine:Bool
        let nickname:String
        let time:String
        let content:String
        let color:Color
        let parentId:Int?
        let parentContent:String?
    }
    var id: Int
    let date:String
    var chats:[Chat]
    static func addChat(chatDays:[ChatDay],chat:NetworkChat)->[ChatDay]{
        var result = chatDays
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "y년 M월 d일"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "a h시 m분"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        let date = Date(timeIntervalSince1970: TimeInterval(chat.createdTimeInSec))
        let day = dayFormatter.string(from: date)
        let time = timeFormatter.string(from: date)
        if chatDays.isEmpty || chatDays.last!.date != day{
            result.append(ChatDay(id: chatDays.count, date: day, chats: [Chat(id: chat.id, isMine: chat.isMine, nickname: chat.chatterNickname, time: time, content: chat.content, color: colorFromNickname(chat.chatterNickname),parentId: chat.parent?.chatterId,parentContent: chat.parent?.content)]))
            

        }
        else{
            result[result.count - 1].chats.append(Chat(id: chat.id, isMine:chat.isMine, nickname: chat.chatterNickname, time: time, content: chat.content, color: colorFromNickname(chat.chatterNickname),parentId: chat.parent?.chatterId,parentContent: chat.parent?.content))
        }
        return result
    }
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
                chatdays.append(ChatDay(id: chatdays.count, date: day, chats: [Chat(id: chat.id, isMine: chat.isMine, nickname: chat.chatterNickname, time: time, content: chat.content, color: colorFromNickname(chat.chatterNickname),parentId: chat.parent?.chatterId,parentContent: chat.parent?.content)]))
            }
            else{
                chatdays[chatdays.count - 1].chats.append(Chat(id: chat.id, isMine: chat.isMine, nickname: chat.chatterNickname, time: time, content: chat.content, color: colorFromNickname(chat.chatterNickname),parentId: chat.parent?.chatterId,parentContent: chat.parent?.content))
            }
            
        }
        return chatdays
    }
    static func colorFromNickname(_ nickname:String)->Color{
        let hash = abs(nickname.hashValue)
        let MAX_RGBVALUE = 200
        let blue = min(hash % 256,MAX_RGBVALUE)
        let green = min(hash / 256 % 256,MAX_RGBVALUE)
        let red = min(hash / 256 / 256 % 256,MAX_RGBVALUE)
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
    @Published
    var writingParentChat: ChatDay.Chat?
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
    func postChat(content:String){
        network.postChat(longitude: "0.0", latitude: "0.0", content: content, roomId: chatroom.id,parentId: writingParentChat?.id){ [weak self]
            response in
            if let self{
                chatDays = ChatDay.addChat(chatDays: chatDays, chat: response)
            }
        }onError: { error in
            
        }
    }
    func stopPolling(){
        timer?.invalidate()
    }
    
    
}
