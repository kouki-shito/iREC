//
//  ContentView.swift
//  iREC
//
//  Created by 市東 on 2024/05/11.
//

import SwiftUI
import SwiftData

struct ContentView: View {

  enum SamplePath {
    case REC, Edit, Settings
  }

  @Environment(\.modelContext) private var modelContext

  @Query private var items: [Item]
  @State private var searchText = ""
  @State private var titleText : String = ""
  @State private var navigationPath : [SamplePath] = []
  @State private var isAnimating : Bool = false

  @State var REC : Bool = false
  @State var audios : [URL] = []

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

                Text(i.relativeString)
                  .fontWeight(.bold)
                  .font(.title2)
                  .frame(maxWidth: .infinity,alignment: .leading)

                Text("2024/5/11")
                  .frame(maxWidth: .infinity,alignment: .leading)
                  .font(.headline)
                  .opacity(0.7)

                HStack{
                  //tag
                }

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

          //MARK: -RECButton
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
        }
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
        print(audios)
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

      for i in result{

        self.audios.append(i)

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

}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
