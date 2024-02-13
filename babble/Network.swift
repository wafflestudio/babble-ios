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


}

struct ChatRoomResponse: Codable {
    let rooms: [Room]
}

struct Room: Codable, Identifiable {
    let hashTag: String
    let id: Int
    let latitude: Double
    let longitude: Double
    let name: String
}
