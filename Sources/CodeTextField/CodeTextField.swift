import SwiftUI

public struct CodeTextField: View {
  @Binding var code: String
  let numberOfDigits: Int
  let spacing: CGFloat?
  let autofocus: Bool

  @Environment(\.codeTextFieldStyle) var codeTextFieldStyle
  @FocusState private var isTextFieldFocused: Bool

  var focusedIndex: Int? {
    guard isTextFieldFocused else {
      return nil
    }

    if code.count == numberOfDigits {
      return numberOfDigits - 1
    }

    return code.count
  }

  public init(
    code: Binding<String>,
    numberOfDigits: Int,
    spacing: CGFloat? = nil,
    autofocus: Bool = true
  ) {
    _code = Binding(
      get: { String(code.wrappedValue.filter(\.isNumber).prefix(numberOfDigits)) },
      set: { newValue, transaction in
        code.transaction(transaction).wrappedValue = String(
          newValue.filter(\.isNumber).prefix(numberOfDigits))
      }
    )
    self.numberOfDigits = numberOfDigits
    self.spacing = spacing
    self.autofocus = autofocus
  }

  public var body: some View {
    ZStack {
      HStack(spacing: spacing) {
        ForEach(0..<numberOfDigits, id: \.self) { index in
          codeTextFieldStyle.makeBody(
            configuration: CodeTextFieldStyleConfiguration(
              label: Text(digit(at: index)),
              isFocused: focusedIndex == index
            )
          )
        }
      }

      TextField("", text: $code)
        .opacity(0)
        .textContentType(.oneTimeCode)
      #if os(iOS)
        .keyboardType(.numberPad)
      #endif
      .focused($isTextFieldFocused)
      .onChange(of: code) { newValue in
        if newValue.count == numberOfDigits {
          isTextFieldFocused = false
        }
      }
      .task {
        if autofocus {
          try? await Task.sleep(nanoseconds: NSEC_PER_MSEC * 500)
          isTextFieldFocused = true
        }
      }
    }
  }

  private func digit(at index: Int) -> String {
    let characters = Array(code)
    if index < characters.count {
      return String(characters[index])
    }

    return ""
  }
}

#if DEBUG
  struct CodeTextField_Previews: PreviewProvider {

    struct Preview: View {
      @State var code = "123456"

      var body: some View {
        CodeTextField(code: $code, numberOfDigits: 6)
          .padding()
      }
    }

    static var previews: some View {
      Group {
        Preview()
          .preferredColorScheme(.light)
        Preview()
          .preferredColorScheme(.dark)
      }

    }
  }
#endif
