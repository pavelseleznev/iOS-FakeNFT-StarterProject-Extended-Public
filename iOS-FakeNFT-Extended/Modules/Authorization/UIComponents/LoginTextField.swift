//
//  LoginTextField.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import SwiftUI

struct LoginTextField: View {
	@Binding private var text: String
	@Binding private var result: LoginResult?
	
	private let placeholder: String
	private let isSecure: Bool
	private let messageAlignment: Edge
	
	@State private var clearButtonIsPresented = false
	@Environment(\.colorScheme) private var theme
	
	init(
		text: Binding<String>,
		placeholder: String = "Enter text",
		isSecure: Bool = false,
		result: Binding<LoginResult?> = .constant(nil),
		messageAlignment: Edge = .top,
	) {
		self._text = text
		self.placeholder = placeholder
		self.isSecure = isSecure
		self._result = result
		self.messageAlignment = messageAlignment
	}
	
	var body: some View {
		Group {
			if isSecure {
				SecureField(placeholder, text: $text)
					.textFieldStyle(.plain)
			} else {
				TextField(placeholder, text: $text)
					.textFieldStyle(.plain)
			}
		}
		.textFieldModifiers()
		.padding()
		.textFieldBackground(result: result, theme: theme)
		.overlay(alignment: .leading, content: fieldIcon)
		.overlay(alignment: .trailing, content: clearButton)
		.onChange(of: text, onTextChange)
		.zIndex(1)
		.background(
			alignment: messageAlignment == .top ? .topLeading : .bottomLeading,
			content: messageView
		)
		.animation(.easeInOut(duration: 0.15), value: result)
	}
}

// MARK: - LoginTextField Extensions
// -- subviews ---
private extension LoginTextField {
	@ViewBuilder
	func messageView() -> some View {
		if let result {
			Group {
				if
					case .failure(let message) = result,
					let message
				{
					Text(message)
						.foregroundStyle(.ypRedUniversal)
						.messageModifiers(alignment: messageAlignment)
				} else if
					case .success(let message) = result,
					let message
				{
					Text(message)
						.foregroundStyle(.ypGreenUniversal)
						.messageModifiers(alignment: messageAlignment)
				}
			}
			.font(.regular15)
			.padding(.leading)
			.zIndex(0)
		}
	}
	
	@ViewBuilder
	func clearButton() -> some View {
		if clearButtonIsPresented {
			Button {
				text = ""
				result = nil
			} label: {
				Image.xmark
					.symbolVariant(.circle)
					.symbolVariant(.fill)
					.foregroundStyle(.ypGrayUniversal)
					.padding(.trailing)
			}
			.transition(.move(edge: .trailing).combined(with: .scale))
		}
	}
	
	func fieldIcon() -> some View {
		Group {
			if isSecure {
				Image(systemName: "lock.shield.fill")
					.resizable()
					.offset(x: 2)
					.foregroundStyle(.ypGreenUniversal)
			} else {
				Image.profilePerson
					.resizable()
					.foregroundStyle(.tertiary)
			}
		}
		.scaledToFit()
		.padding()
	}
}

// --- helpers ---
private extension LoginTextField {
	func onTextChange(_: String, _: String) {
	   withAnimation(.easeInOut(duration: 0.15)) {
		   clearButtonIsPresented = !text.isEmpty
	   }
   }
}

// MARK: - View helpers
fileprivate extension View {
	func messageModifiers(alignment: Edge) -> some View {
		self
			.transition(
				.asymmetric(
					insertion: .move(edge: alignment == .top ? .bottom : .top),
					removal: .scale.combined(with: .opacity)
				)
			)
			.offset(y: (alignment == .top ? 1 : -1) * (-15 - 10))
	}
	
	func textFieldModifiers() -> some View {
		self
			.padding(.horizontal, 30)
			.font(.regular17)
			.autocorrectionDisabled(true)
			.textInputAutocapitalization(.never)
	}
	
	func textFieldBackground(result: LoginResult?, theme: ColorScheme) -> some View {
		self
			.background(
				Capsule()
					.fill(.bar)
					.stroke(strokeColor(result), lineWidth: result == nil ? 0 : 1)
					.shadow(
						color: theme == .light ? .ypBackgroundUniversal
							.opacity(0.5) : .ypBlackUniversal,
						radius: 10
					)
					.background(
						strokeColor(result)
							.opacity(0.3)
							.scaleEffect(
								x: 0.95,
								y: 0.4
							)
					)
			)
	}
	
	private func strokeColor(_ result: LoginResult?) -> Color {
		switch result {
		case .success:
			 .ypGreenUniversal
		case .failure:
			.ypRedUniversal
		case nil:
			.clear
		}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	@Previewable @State var text = ""
	@Previewable @State var secureText = ""
	
	@Previewable @State var loginResult: LoginResult?
	@Previewable @State var passwordResult: LoginResult?
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		VStack {
			LoginTextField(
				text: $text,
				placeholder: "Email",
				result: $loginResult
			)
			
			LoginTextField(
				text: $secureText,
				placeholder: "Password",
				isSecure: true,
				result: $passwordResult,
				messageAlignment: .bottom
			)
		}
		.padding(.horizontal)
		.task(priority: .userInitiated) {
			try? await Task.sleep(for: .seconds(1))
			withAnimation(Constants.defaultAnimation) {
				loginResult = .failure("Some error")
				passwordResult = .success("Success!")
			}
		}
	}
}
#endif
