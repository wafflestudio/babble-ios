//
//  HeaderView.swift
//  babble
//
//  Created by 박정헌 on 2024/02/09.
//

import Foundation
import SwiftUI


struct ChatHeaderView:View{
    let name:String
    let tag:String
    let members_count:Int
    var body:some View{
        ZStack{
            HStack(){
                backButton
                Spacer()
            }.padding()
            HStack(){
                Text(name)
                    .font(.system(size: 20))
                Text("\(members_count)").foregroundColor(Color("Blue5"))
            }
            HStack(){
                Spacer()
                Text(tag).foregroundColor(Color("Blue5"))
                  
            }.padding()
        } .background(Color("Blue4"))
     
    }
  
}
let backButton:some View = Image(systemName: "chevron.left")
    .aspectRatio(contentMode: .fit)
struct ChatHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(){
            ChatHeaderView(name: "중앙도서관채팅방", tag: "#도서관", members_count: 20)
               
            Spacer()
        }
    }
}
