//
//  ContentView.swift
//  iREC
//
//  Created by 市東 on 2024/05/11.
//

import SwiftUI
import SwiftData
import Foundation
import AVKit

struct ContentView: View {

  enum SamplePath {
    case REC, Edit, Settings
  }

  struct Audios{

    var path:URL
    var createDate:Date

  }
  @Environment(\.modelContext) private var modelContext

  @Query private var items: [Item]
  @State private var searchText = ""
  @State private var titleText : String = ""
  @State private var navigationPath : [SamplePath] = []
  @State private var isAnimating : Bool = false
  @State private var play : Bool = false
  @State private var isPlayView : Bool = false
  @State var REC : Bool = false
  @State private var SortArray : [Audios] = []
  @State var audios : [URL] = []

  @State private var player : AVAudioPlayer!
  @State private var session : AVAudioSession!
  @State private var totalTime : TimeInterval = 0.0
  @State private var currentTime : TimeInterval = 0.0
  @State private var playingName : String = ""

  var body: some View {
    NavigationStack(path: $navigationPath) {

      ZStack {
        Color.base
          .ignoresSafeArea()

        VStack{
          //MARK: -List
          List(){

            ForEach(self.audios,id: \.self) { i in

              VStack{
                let CreateDate = getCreationDateStr(url: i)
                Text(i.relativeString)
                  .fontWeight(.bold)
                  .font(.title2)
                  .frame(maxWidth: .infinity,alignment: .leading)

                Text(CreateDate)
                  .frame(maxWidth: .infinity,alignment: .leading)
                  .font(.headline)
                  .opacity(0.7)
                
                HStack{
                  //tag
                }
              }
              .contentShape(Rectangle())
              .onTapGesture {
                setupPlayerAudio(url: i)
                playAudio()
              }
              .foregroundStyle(.white)
              .listRowBackground(Color.subAcc)
            }
            .onDelete(perform: { indexSet in
              deleteFiles(offsets: indexSet)
            })
          }

          .searchable(text: $searchText)
          .scrollContentBackground(.hidden)

          Spacer()

          //MARK: -player

          if isPlayView{
            ZStack {
              Rectangle()
                .foregroundStyle(.sub).opacity(0.4)
                .blur(radius: 1)
                .frame(height: 80)
              HStack{

                Image(systemName: "mic.fill")
                  .resizable()
                  .scaledToFit()
                  .foregroundStyle(.white)
                  .frame(maxWidth:40,maxHeight: 30)
                  .padding(.leading)

                Text(playingName)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity,alignment: .leading)
                  .padding(.leading)

                Button(){
                  if play{
                    stopAudio()
                  }else{
                    playAudio()
                  }

                }label: {

                  Image(systemName: play ? "pause.fill":"play.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 25,height: 25,alignment: .trailing)
                    .padding(.trailing,20)

                }

              }
              .frame(maxWidth:.infinity,maxHeight: 80)
            }

          }

        }
        //MARK: -Prop
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            EditButton()
              .fontWeight(.bold)
              .font(.title3)
              .foregroundStyle(.subAcc)
              .padding(.bottom,10)
          }
          ToolbarItem(placement: .topBarLeading){
            Button(){

            }label: {
              Image(systemName: "gearshape")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.subAcc)
                .padding(.bottom,10)
            }
          }
          ToolbarItem(placement: .bottomBar){

            HStack {

              Button(){

                navigationPath.append(.REC)

              }label: {
                //RECButtonView
                ZStack{

                  Circle()
                    .stroke(Color(red:0.8, green:0.8, blue:0.8, opacity: 1),lineWidth: 4)
                    .frame(width: 60, height: 60)

                  Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 50,height: 50)
                    .foregroundStyle(.red)
                }
                .padding(.bottom,30)
              }

            }

          }

        }
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbarBackground(.base,for: .bottomBar)


      }
      .navigationDestination(for: SamplePath.self){ value in
        switch value{

        case .REC:
          RecView(audios: $audios, REC: $REC, isAnimating:$isAnimating)
        case .Edit:
          EditView()
        case .Settings:
          SettingsView()

        }

      }
      .onAppear(){
        getAudios()
        //print(audios)
      }

    }//:navi

  }//:body

  //MARK: -Other func
  private func addItem() {
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }

  private func getAudios(){

    do{

      let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

      //fetch all Data ...

      let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)

      self.audios.removeAll()
      self.SortArray.removeAll()

      for i in result{

        let attribute = try FileManager.default.attributesOfItem(atPath: i.path)
        let creationDate = attribute[.creationDate] as? Date
        let st = Audios(path: i, createDate: creationDate!)
        self.SortArray.append(st)
        self.SortArray.sort(by: {$0.createDate>$1.createDate})
      }
      for i in SortArray{
        self.audios.append(i.path)
      }

    }
    catch{

      print(error.localizedDescription)

    }

  }//:func

  private func deleteFiles(offsets: IndexSet){
    
    for index in offsets{
      do{
        try FileManager.default.removeItem(at: audios[index])
        self.audios.remove(atOffsets: offsets)
      }
      catch{
        print(error.localizedDescription)
      }
    }

  }

  private func getCreationDateStr(url:URL) -> String {

      let attribute = try? FileManager.default.attributesOfItem(atPath: url.path)
      let creationDate = attribute?[.creationDate] as? Date
      let DateStr = creationDate?.formatted(date: .numeric, time: .shortened) ?? "Error"
      return DateStr
  }

  private func setupPlayerAudio(url : URL){
    do{
      player = try AVAudioPlayer(contentsOf: url)
      player?.prepareToPlay()
      playingName = url.relativePath
      totalTime = player?.duration ?? 0.0
    }
    catch{
      print(error.localizedDescription)
    }
  }

  private func playAudio(){
    if !isPlayView{
      isPlayView = true
    }
    play = true
    player?.play()
  }

  private func stopAudio(){
    player?.pause()
    play = false
  }

  private func updateProgress(){
    guard let player = player else{return}
    currentTime = player.currentTime
  }

  private func seekAudio(to time: TimeInterval){
    player?.currentTime = time
  }

  private func timeString(time: TimeInterval) -> String{
    let minute = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minute,seconds)

  }


}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
