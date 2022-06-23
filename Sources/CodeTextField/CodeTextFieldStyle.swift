import SwiftUI

/// The properties of a code text field.
public struct CodeTextFieldStyleConfiguration {
  public typealias Label = Text

  /// A digit of a code text field.
  public let label: Label

  /// A boolean that indicates wheter this digit is currently focused.
  public let isFocused: Bool
}

/// A type that applies standard interaction behavior and a custom appearance to all code text fields within a view hierarchy.
public protocol CodeTextFieldStyle {
  typealias Configuration = CodeTextFieldStyleConfiguration
  associatedtype Body: View

  /// Creates a view that represents the body of a code text field.
  func makeBody(configuration: Configuration) -> Body
}

public struct DefaultCodeTextFieldStyle: CodeTextFieldStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .multilineTextAlignment(.center)
      .font(.title)
      .frame(maxWidth: .infinity, maxHeight: 64)
      .background(.regularMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .scaleEffect(configuration.isFocused ? 1.2 : 1.0)
  }
}

extension CodeTextFieldStyle where Self == DefaultCodeTextFieldStyle {
  public static var `default`: DefaultCodeTextFieldStyle { DefaultCodeTextFieldStyle() }
}

public struct AnyCodeTextFieldStyle: CodeTextFieldStyle {

  private var bodyBuild: (Configuration) -> AnyView

  init<S: CodeTextFieldStyle>(_ style: S) {
    self.bodyBuild = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: Configuration) -> AnyView {
    bodyBuild(configuration)
  }
}

private enum CodeTextFieldStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyCodeTextFieldStyle {
    AnyCodeTextFieldStyle(.default)
  }
}

extension EnvironmentValues {
  public var codeTextFieldStyle: AnyCodeTextFieldStyle {
    get { self[CodeTextFieldStyleEnvironmentKey.self] }
    set { self[CodeTextFieldStyleEnvironmentKey.self] = newValue }
  }
}

extension View {
  public func codeTextFieldStyle<S: CodeTextFieldStyle>(_ style: S) -> some View {
    environment(\.codeTextFieldStyle, AnyCodeTextFieldStyle(style))
  }
}
