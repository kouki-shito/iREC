//
//  RecView.swift
//  iREC
//
//  Created by 市東 on 2024/05/11.
//

import SwiftUI
import Foundation
import AVKit

struct RecView: View {
  @State private var session : AVAudioSession!
  @State private var record : AVAudioRecorder!

  @Binding var isREC : Bool
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isFocussed : Bool
  @State private var Text :String = ""
  @Binding var isAnimating : Bool

  var body: some View {
    ZStack {
      Color.base
        .ignoresSafeArea()
      VStack{
        //MARK: -BackButton
        HStack {
          Button(){
            isREC = false
            isAnimating = false
            dismiss()
          }label: {
            Image(systemName: "chevron.backward")
              .font(.title)
              .fontWeight(.medium)
              .foregroundStyle(.subAcc)
              .frame(maxWidth: .infinity,alignment: .leading)
              .padding(.leading,20)
          }
          Button(){

          }label: {
            Image(systemName: "metronome")
              .font(.title)
              .fontWeight(.medium)
              .foregroundStyle(.subAcc)
              .frame(maxWidth: .infinity,alignment: .trailing)
              .padding(.trailing,20)
          }
        }
        .padding(.top)
        //MARK: -TextView
        TextEditor(text: $Text)
          .focused($isFocussed)
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.leading)
          .padding()
          .scrollContentBackground(.hidden)
          .background(Color.sub.opacity(0.5))
          .foregroundStyle(.acc)
          .frame(height: 250)
          .padding(.top,30)
          .toolbar{
            ToolbarItem(placement: .keyboard){
              HStack {
                Button("Close"){
                  isFocussed = false
                }
                .frame(maxWidth: .infinity,alignment: .trailing)
              }
            }
          }
        //MARK: -waveform

        Spacer()
        //MARK: -RECButton
        HStack {
          Button(){
            isREC.toggle()
            if !isAnimating{
              withAnimation(){
                isAnimating = true
              }
            }else{
            }
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
            .overlay(){
                Circle()
                  .trim(from: 0.0, to: 0.25)
                  .stroke(.red, style: StrokeStyle(lineWidth: 4.0, lineCap: .round, lineJoin: .round))
                  .frame(width: 60, height: 60)
                  .rotationEffect(
                    .degrees(isAnimating ? 360 :0))
                  .animation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false),
                  value: isAnimating)
                  .opacity(isREC ? 1 : 0)
            }
            .padding(.bottom,30)

          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .onAppear(){
      isAnimating = true
    }
    .onAppear(){
      do{
        self.session = AVAudioSession.sharedInstance()
        try self.session.setCategory(.playAndRecord)
        //Next Day
      }
      catch{
        print(error.localizedDescription)
      }
    }
  }
}


extension RecView{
  
//  private var waveform: some View{
//    ScrollView(.horizontal){
//      HStack{
//        GeometryReader{reader in
//          Path{ path in
//            var x = 0.0
//
//
//            path.move(to: .init(x: <#T##CGFloat#>, y: <#T##CGFloat#>))
//          }
//        }
//
//      }
//    }
//  }


}


#Preview {
  RecView(isREC: .constant(true),isAnimating: .constant(true))
    .modelContainer(for: Item.self, inMemory: true)

}
