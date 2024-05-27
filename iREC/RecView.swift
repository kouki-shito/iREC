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
  @State private var title : String = ""

  @State private var amplitudes : [CGFloat] = []
  @State private var nowLevel : CGFloat = 0.0
  private let interval : CGFloat = 5.0
  @State private var timer : Timer?
  @State private var timerCount : TimeInterval = 0.0
  @State private var isPause : Bool = false
  @State private var fadeInOut = false

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
              stopRec()
              isPause = false
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

        SwiftUI.Text(timeToString(time: timerCount) + "")
          .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 25, weight: .light)))
          .foregroundStyle(.white)
          .opacity(fadeInOut ? 0:1)
          .onChange(of: isPause){
            if isPause{
              withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)){
                fadeInOut.toggle()
              }
            }else{
              fadeInOut = false
            }
          }

          .opacity(fadeInOut ? 0:1)
          .padding()

        //MARK: -waveform
        GeometryReader{ render in
          Path{ path in
            let y_0 = render.size.height * 0.5
            var x = 0.0

            for i in amplitudes {

              path.move(to: .init(x: x, y: y_0 - i * 150))
              path.addLine(to: .init(x: x, y: y_0 + i * 150))
              x += interval

            }

          }
          .stroke(lineWidth: 1.0)
          .fill(Color.red)
          .onAppear(){
            if amplitudes.isEmpty == false{return}
            let count = render.size.width / interval
            amplitudes = Array(repeating: 0.01, count: Int(count))
          }
          .onChange(of: nowLevel){ _ ,newLevel in
            if amplitudes.isEmpty {return}
            amplitudes.append(newLevel)
            amplitudes.remove(at: 0)
          }

        }



        //MARK: -Bottom Buttons
          HStack {
            //MarkerButton
            Button(){
              
            }label: {

              ZStack {
                ZStack {
                  Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50,height: 50)
                    .foregroundStyle(.sub)
                  Image(systemName: "flag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
                    .foregroundStyle(.white)
                }
                .padding(.trailing,50)
                .padding(.bottom,30)
              }
            }

            Button(){
              
              REC.toggle()
              isAnimating = true
              if isRec {
                // stop Audio Recording and Save...
                self.recorder.stop()
                stopTimer()
                isPause = false
                self.isRec.toggle()
                return

              }else{
                // init Recording and start ...
                record()
                startTimer()
              }
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

            //Pause Button
            Button(){
              if isRec{
                isPause.toggle()
                if isPause{
                  pauseRec()
                }else{
                  record()
                  startTimer()
                }
              }
            }label: {
              ZStack {
                Image(systemName: "circle.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 50,height: 50)
                  .foregroundStyle(.sub)
                Image(systemName: isPause == false ? "pause.fill" : "play.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 20,height: 20)
                  .foregroundStyle(.white)
              }
              .padding(.leading,50)
              .padding(.bottom,30)
            }
            .frame(alignment: .center)
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
      setupSession()
      setupRecord()
    }

  }

  private func setupSession(){
    do{
      self.session = AVAudioSession.sharedInstance()
      try self.session.setCategory(.playAndRecord)
      self.session.requestRecordPermission{ (status) in

        if !status{
          self.alert.toggle()
        }

      }
    }
    catch {
      print(error.localizedDescription)
    }
  }

  private func setupRecord(){
    do{
      let url = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask)[0]

      let fileName = url.appendingPathComponent("Record_\(self.audios.count + 1).m4a")

      let settings =  [

        AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey : 44100,
        AVNumberOfChannelsKey : 1,
        AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
      ]

      self.recorder = try AVAudioRecorder(
        url: fileName,settings: settings)

      self.recorder.prepareToRecord()

      self.recorder.isMeteringEnabled = true
    }
    catch{
      print(error.localizedDescription)
    }
  }

//  private func numberOfOccurrences(of word: String) -> Int {
//    var count = 0
//    var range = word.
//    return count
//  }

  private func record(){
    self.recorder.record()
    isRec = true
  }

  private func pauseRec(){
    self.recorder.pause()
    timer?.invalidate()
    timer = nil
  }

  private func stopRec(){
    self.recorder.stop()
    stopTimer()
    self.isRec = false
  }

  private func amplitude() -> CGFloat{
    self.recorder.updateMeters()
    let decibel = recorder.averagePower(forChannel: 0)
    let amp = pow(10, decibel / 20)
    return CGFloat(max(0, min(amp, 1)))
  }

  private func updateAmplitude(){
    let amplitude = amplitude()
    nowLevel = amplitude
  }

  private func startTimer(){
    self.timer?.invalidate()
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){ time in
      timerCount += 0.01
      updateAmplitude()
    }
  }

  private func stopTimer(){
    timer?.invalidate()
    timerCount = 0.0
    timer = nil
  }

  private func timeToString(time : TimeInterval) -> String{
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.unitsStyle = .positional
    dateFormatter.allowedUnits = [.hour,.minute, .second]
    dateFormatter.zeroFormattingBehavior = .pad
    let timerStr = dateFormatter.string(from: time)!
    return timerStr
  }

}
//import UIKit
//struct WaveformView : UIViewRepresentable{
//
//  @Binding var amplitudes : [Float]
//
//  func makeUIView(context: Context) -> UICollectionView {
//    let Layout = UICollectionViewFlowLayout()
//    let collectionView = UICollectionView(frame: .zero,collectionViewLayout: Layout)
//
//    collectionView.delegate = context.coordinator
//    collectionView.dataSource = context.coordinator
//
//    return collectionView
//  }
//
//  func updateUIView(_ uiView : UICollectionView, context: Context) {
//    uiView.reloadData()
//  }
//
//  func makeCoordinator() -> Coordinator {
//    Coordinator(amplitudes: amplitudes)
//  }
//
//  class Coordinator :NSObject,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
//
//    @Binding var amplitudes : [Float]
//
//    init(amplitudes: [Float]) {
//      self.amplitudes = amplitudes
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//      amplitudes.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//      let cell = collectionView.dequeueReusableCell(for: IndexPath) as WaveCollectionViewCell
//      let amplitude = amplitudes[indexPath.row]
//      let waveheight = CGFloat(amplitude) * collectionViewHeight
//    }
//
//  }
//
//  class WaveCollectionViewCell : UICollectionViewCell{
//    var waveheight = NSLayoutConstraint()
//    var waveView = UIView()
//
//    func draw(height:CGFloat,index : Int){
//      waveheight.constant = height
//      waveView.isHidden = index % 2 != 0
//    }
//  }
//}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
