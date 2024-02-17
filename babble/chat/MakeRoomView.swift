//
//  MakeRoomView.swift
//  babble
//
//  Created by Chaehyun Park on 2/17/24.
//

import SwiftUI

struct MakeRoomView: View {
    @ObservedObject var viewModel: ChatRoomsViewModel
    var navigateToChatView: (Room) -> Void
    
    @State var nickname: String = ""
    @State var roomName: String = ""
    
    private let options = RoomType.allCases
    @State private var selectedOption: RoomType?

    @State private var shouldNavigateToChatRoom = false
    @State private var room : Room?
    
    var body: some View {
        VStack {
            Text("새로운 채팅방 생성")
            Text("태그를 선택해주세요")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            self.selectedOption = option
                        }) {
                            Text(option.rawValue)
                                .padding()
                                .background(self.selectedOption == option ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }



            switch selectedOption?.rawValue {
                case "강의실":
                    Text("강의동, 호수를 입력해주세요")
                    TextField("301동 308호, 83동 301호, ...", text: $roomName)
                case "학생 식당":
                    Text("식당 이름을 입력해주세요")
                    TextField("학생회관 식당, 자하연 식당, ...", text: $roomName)
                case "식당":
                    Text("식당 이름을 입력해주세요")
                    TextField("포포인, 비비큐, ...", text: $roomName)
                case "도서관":
                    Text("도서관 이름, 층을 입력해주세요")
                    TextField("관정도서관 7층, 신양공학학술정보관 1층, ...", text: $roomName)
                case "동아리방":
                    Text("동아리 이름을 입력해주세요")
                    TextField("와플스튜디오, SCSC, ...", text: $roomName)
                case "과방":
                    Text("과 이름을 입력해주세요")
                    TextField("전기정보공학부, 컴퓨터공학부, ...", text: $roomName)
                case "카페":
                    Text("카페 이름을 입력해주세요")
                    TextField("관정 파스쿠찌, 자하연 느티나무, ...", text: $roomName)
                default:
                    EmptyView()
            }
            
            if selectedOption != nil {
                Text("채팅방에서 사용할 이름을 입력해주세요")
                TextField("닉네임", text: $nickname)
                if roomName != "" {
                    Button(action: {
                        print(selectedOption!.hashTag)
                        viewModel.createChatRoom(hashTag: selectedOption!.hashTag, nickname: nickname, roomName: roomName) { room in
                            self.room = room
                            navigateToChatView(room)
                        }
                    }) {
                        Text("만들기")
                            .padding()
                            .background(!nickname.isEmpty ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(roomName.isEmpty) // Disables the button if roomName is empty
                }
            }
            
            /*NavigationLink(destination: ChatRoomView(viewModel: ChatViewModel(chatRoom: room!)), isActive: $shouldNavigateToChatRoom) {
                EmptyView()
            }*/
            
        }
        .padding(.horizontal)

    }

}

enum RoomType: String, CaseIterable {
    case lectureRoom = "강의실"
    case cafeteria = "학생 식당"
    case restaurant = "식당"
    case library = "도서관"
    case departmentRoom = "과방"
    case clubActivityRoom = "동아리방"
    case cafe = "카페"
    
    var hashTag: String {
        switch self {
        case .lectureRoom: return "LECTURE_ROOM"
        case .cafeteria: return "CAFETERIA"
        case .restaurant: return "RESTAURANT"
        case .library: return "LIBRARY"
        case .departmentRoom: return "DEPARTMENT_ROOM"
        case .clubActivityRoom: return "CLUB_ACTIVITY_ROOM"
        case .cafe: return "CAFE"
        }
    }
}
