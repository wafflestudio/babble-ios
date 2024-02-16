//
//  Network.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/10.
//

import Alamofire
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

class Network {
    let baseURL = "http://localhost:8080"

    func kakaoLogin(completionHandler:@escaping (String)->Void){
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    completionHandler("error")
                } else {
                    let kakaoAccessToken = oauthToken?.accessToken
                    self.sendKakaoToken(token: kakaoAccessToken!, completionHandler: { completion in
                        
                        if(completion == "success"){
                            UserDefaults.standard.set(true, forKey: "kakaoLogin")
                            completionHandler("success")
                        }
                        
                        else{
                            completionHandler("failure")
                        }
                    })
                }
            }
        }
        
        else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print(error)
                    completionHandler("error")
                } else {
                    let kakaoAccessToken = oauthToken?.accessToken
                    self.sendKakaoToken(token: kakaoAccessToken!, completionHandler: { completion in
                        
                        if(completion == "success"){
                            UserDefaults.standard.set(true, forKey: "kakaoLogin")
                            completionHandler("success")
                        }
                        
                        else{
                            completionHandler("failure")
                        }
                    })
                }
            }
        }
    }
    
    func sendKakaoToken(token: String, completionHandler:@escaping (String)->Void){
        let fullURL = URL(string: baseURL + "/api/auth/login?token=\(token)")
        
        AF.request(fullURL!,
           method: .post,
           interceptor: JWTInterceptor()
        )
        .responseData(){
            response in
            
            switch response.result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let accessToken = json["accessToken"] as? String {
                        UserDefaults.standard.set(accessToken, forKey: "accessToken")
                        completionHandler("success")
                    } else {
                        completionHandler("error")
                    }
                } catch {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print(errorMessage)
                    completionHandler("error")
                }
                
            case .failure(let error):
                print(error)
                completionHandler("error")
            }
        }
    }
    
    func loadChatrooms(longitude: String, latitude: String, completion: @escaping ([Room]) -> Void) {
        let fullURL = URL(string: baseURL + "/api/chat/rooms?latitude=\(latitude)&longitude=\(longitude)")

        AF.request(fullURL!,
                   method: .get,
                   interceptor: JWTInterceptor()
                )
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let chatRooms = try decoder.decode(ChatRoomResponse.self, from: data)
                        completion(chatRooms.rooms)
                    } catch {
                        print("Decoding error: \(error)")
                        completion([])
                    }
                case .failure(let error):
                    print("Request error: \(error)")
                    completion([])
                }
            }
    }
    func enterChatroom(longitude:String,latitude:String,id:Int,nickname:String,completion: @escaping (EnterChatRoomResponse) -> Void,onError:@escaping (String)->Void){
        let fullURL = URL(string: baseURL + "/api/chat/rooms/\(id)/chatters")!
        let header:HTTPHeaders = ["Content-Type":"application/json"]
        let params:Parameters = ["latitude":latitude,"longitude":longitude,"nickname":nickname]
          
            AF.request(fullURL,method:.post,parameters: params,encoding: JSONEncoding.default,headers: header,interceptor: JWTInterceptor()).responseData{ response in

                switch response.result{
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let chats = try decoder.decode(EnterChatRoomResponse.self, from: data)
                        completion(chats)
                    } catch {
                        print("Decoding error: \(error)")
                        onError("decoding error")
                    }
                
                case .failure(let error):
                    print("Request error: \(error)")
                    onError("error")//TODO: 상세 에러 메시지

                }
            }
        
       
    
    }
    func loadChats(longitude: String, latitude:String, id:Int,completion: @escaping (ChatsResponse) -> Void,onError:@escaping (String)->Void){
        let fullURL = URL(string: baseURL + "/api/chat/rooms/\(id)?latitude=\(latitude)&longitude=\(longitude)")
        AF.request(fullURL!,method: .get,interceptor: JWTInterceptor()).responseData{ response in
            print(String(decoding: response.data!, as: UTF8.self))

            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let chats = try decoder.decode(ChatsResponse.self, from: data)
                    completion(chats)
                } catch {
                    print("Decoding error: \(error)")
                    onError("decoding error")
                }
            case .failure(let error):
                print("Request error: \(error)")
                onError("error")//TODO: 상세 에러 메시지
            }
            
        }

    }
    func postChat(longitude:String,latitude:String,content:String,roomId:Int,parentId:Int?,completion:@escaping (Chat)->(), onError:@escaping(String)->()){
        let fullURL = URL(string:baseURL + "/api/chat/rooms/\(roomId)/chats")!
        let params = parentId == nil ? ["content":content,"latitude":latitude,"longitude":longitude] :
        ["content":content,"latitude":latitude,"longitude":longitude,"parentChatId":"\(parentId!)"]
        let header:HTTPHeaders = ["Content-Type":"application/json"]
        AF.request(fullURL,method:.post,parameters: params,encoder: JSONParameterEncoder.default,headers:header,interceptor:JWTInterceptor()).responseData{
                response in
            print(String(decoding: response.data!, as: UTF8.self))
                switch response.result{
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let chat = try decoder.decode(Chat.self, from: data)
                        completion(chat)
                    } catch {
                        print("Decoding error: \(error)")
                        onError("decoding error")
                    }
                case .failure(let error):
                    print("Request error: \(error)")
                    onError("error")//TODO: 상세 에러 메시지
                }
            }
            
        
    }


}

struct ChatRoomResponse: Codable {
    let rooms: [Room]
}
struct ChatsResponse: Codable{
    let room:Room
    let isChatter: Bool
    let chatterCount:Int
    let chats:[Chat]
}
struct EnterChatRoomResponse:Codable{
    let id:Int
    let nickname:String
}
struct Room: Codable, Identifiable {
    let hashTag: String
    let id: Int
    let latitude: Double
    let longitude: Double
    let name: String
}
struct ParentChat:Codable{
    let chatterId: Int
    let chatterNickname: String
    let content: String
    let id:Int
    let isMine:Bool
    let createdTimeInSec: Int
}
struct Chat: Codable{
    let chatterId: Int
    let chatterNickname: String
    let content: String
    let id:Int
    let isMine:Bool
    let createdTimeInSec: Int
    let parent: ParentChat?
}

