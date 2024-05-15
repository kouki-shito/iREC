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
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isFocussed : Bool

  @State private var session : AVAudioSession!
  @State private var recorder : AVAudioRecorder!
  @State private var isRec : Bool = false
  @State private var alert = false
  @State private var Text :String = ""
  @Binding var audios : [URL]
  @Binding var REC : Bool
  @Binding var isAnimating : Bool


  var body: some View {
    ZStack {

      Color.base
        .ignoresSafeArea()

      VStack{
        //MARK: -BackButton
        HStack {
          Button(){

            REC = false
            isAnimating = false
            if isRec{
              self.recorder.stop()
              self.isRec = false
            }
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
            
            REC.toggle()
            isAnimating = true

            if isRec {
              // stop Audio Recording and Save...
              self.recorder.stop()
              self.isRec.toggle()

              return

            }else{
              // init Recording and start ...
              do{

                let url = FileManager.default.urls(
                  for: .documentDirectory,
                  in: .userDomainMask)[0]

                let fileName = url.appendingPathComponent("New_Rec\(self.audios.count + 1).m4a")

                let settings =  [

                  AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                  AVSampleRateKey : 12000,
                  AVNumberOfChannelsKey : 1,
                  AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                ]

                self.recorder = try AVAudioRecorder(
                  url: fileName,settings: settings)

                self.recorder.record()

                self.isRec.toggle()

              }catch{

                print(error.localizedDescription)

              }

            }//:if

          }label: {
            //RECButtonView
            ZStack{
              Circle()
                .stroke(Color(red:0.8,green:0.8,blue:0.8
                              ,opacity: 1),lineWidth: 4)
                .frame(width: 60, height: 60)

              Image(systemName: REC == false ? "circle.fill" : "stop.fill")
                .resizable()
                .frame(width: REC == false ? 50:30,height: REC == false ? 50:30)
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
                    .linear(duration: 2.5)
                    .repeatForever(autoreverses: false),
                  value: isAnimating)
                  .opacity(REC ? 1 : 0)

            }
            .padding(.bottom,30)

          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .alert("Error",isPresented: $alert){
      Button("戻る",role: .cancel){
        dismiss()
      }
      Button("設定画面へ"){
        let url = URL(string:UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        dismiss()
      }
    }message: {
      SwiftUI.Text("マイクが許可されていません")
    }
    .onAppear(){
      do{

        self.session = AVAudioSession.sharedInstance()
        try self.session.setCategory(.playAndRecord)
        self.session.requestRecordPermission{ (status) in

          if !status{
            self.alert.toggle()
          }else{
            print("Permission granted")
          }

        }

      }
      catch {
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
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
