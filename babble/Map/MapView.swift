//
//  ContentView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/08.
//

import SwiftUI

struct MapView: View {
    @State var draw: Bool = false
    var chatRoomsViewModel: ChatRoomsViewModel
    
    var body: some View {
        VStack {
            KakaoMapVCWrapper(chatRoomsViewModel: chatRoomsViewModel)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        var chatRoomsViewModel = ChatRoomsViewModel()
        MapView(chatRoomsViewModel: chatRoomsViewModel)
    }
}
