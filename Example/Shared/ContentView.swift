//
//  ContentView.swift
//  Shared
//
//  Created by Guilherme Souza on 23/06/22.
//

import CodeTextField
import SwiftUI

struct ContentView: View {
  @State var code = ""

  var body: some View {
    CodeTextField(code: $code, numberOfDigits: 6)
      .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
