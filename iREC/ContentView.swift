//
//  ContentView.swift
//  iREC
//
//  Created by 市東 on 2024/05/11.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]

  var body: some View {
    NavigationStack {
      VStack{
        //MARK: -List
        List{
        }
      }
      //MARK: -Prop
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem(placement: .bottomBar){
          
          Button(){

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
          }
          .padding(.bottom,60)
        }

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
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
