//
//  ContentView.swift
//  babble
//
//  Created by Chaehyun Park on 2024/02/08.
//

import SwiftUI

struct MapView: View {
    @State var draw: Bool = false
    
    var body: some View {
        VStack {
            KakaoMapVCWrapper()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
