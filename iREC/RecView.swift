//
//  RecView.swift
//  iREC
//
//  Created by 市東 on 2024/05/11.
//

import SwiftUI

struct RecView: View {
  @Binding var isREC : Bool
  @Environment(\.dismiss) private var dismiss
  @State private var Text :String = ""

  var body: some View {
    ZStack {
      Color.base
        .ignoresSafeArea()

      VStack{
        //MARK: -BackButton
        HStack {
          Button(){
            isREC = false
            dismiss()
          }label: {
            Image(systemName: "chevron.backward")
              .font(.title)
              .fontWeight(.bold)
              .foregroundStyle(.subAcc)
              .frame(maxWidth: .infinity,alignment: .leading)
              .padding(.leading,20)
          }
          Button(){

          }label: {
            Image(systemName: "metronome")
              .font(.title)
              .fontWeight(.bold)
              .foregroundStyle(.subAcc)
              .frame(maxWidth: .infinity,alignment: .trailing)
              .padding(.trailing,20)
          }
        }
        .padding(.top)
        //MARK: -TextView
        TextEditor(text: $Text)
          .scrollContentBackground(.hidden)
          .background(Color.sub)
          .frame(height: 250)
          .padding(.top,30)
        Spacer()
        //MARK: -RECButton
        HStack {
          Button(){
            isREC.toggle()
          }label: {
            //RECButtonView
            ZStack{
              Circle()
                .stroke(Color(red:0.8, green:0.8, blue:0.8, opacity: 1),lineWidth: 4)
                .frame(width: 60, height: 60)
              Image(systemName: isREC == false ? "circle.fill" : "stop.fill")
                .resizable()
                .frame(width: isREC == false ? 50:30,height: isREC == false ? 50:30)
                .foregroundStyle(.red)
            }
            .padding(.bottom,30)
          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
  }

}


#Preview {
  RecView(isREC: .constant(false))
    .modelContainer(for: Item.self, inMemory: true)

}
