//
//  WebViewRepresentable.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//


import WebKit
import SwiftUI

struct WebViewRepresentable: UIViewRepresentable {
	let url: URL
	@Binding var loadingState: LoadingState
	var colorScheme: ColorScheme
	var onProgress: (Double) -> Void = { _ in }

	func makeUIView(context: Context) -> WKWebView {
		let config = WKWebViewConfiguration()

		let userScript = WKUserScript(
			source: helperJS,
			injectionTime: .atDocumentStart,
			forMainFrameOnly: true
		)
		config.userContentController.addUserScript(userScript)

		let webView = WKWebView(frame: .zero, configuration: config)
		webView.navigationDelegate = context.coordinator
		context.coordinator.attach(to: webView)

		webView.load(URLRequest(url: url))
		return webView
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.overrideUserInterfaceStyle = (colorScheme == .dark) ? .dark : .light
		let themeString = (colorScheme == .dark) ? "dark" : "light"
		let js = "window.__applyNativeTheme && window.__applyNativeTheme('\(themeString)');"
		uiView.evaluateJavaScript(js, completionHandler: nil)
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(
			loadingState: $loadingState,
			onProgress: onProgress
		)
	}

	// MARK: - Coordinator

	class Coordinator: NSObject, WKNavigationDelegate {
		@Binding var loadingState: LoadingState
		let onProgress: (Double) -> Void

		weak var webView: WKWebView?

		private var progressObservation: NSKeyValueObservation?

		init(
			loadingState: Binding<LoadingState>,
			onProgress: @escaping (Double) -> Void
		) {
			self._loadingState = loadingState
			self.onProgress = onProgress
		}

		func attach(to webView: WKWebView) {
			self.webView = webView
			guard progressObservation == nil else { return }

			progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
				guard let self, let value = change.newValue else { return }
				DispatchQueue.main.async {
					self.onProgress(value)
					self.loadingState = value < 0.999 ? .idle : .fetching
				}
			}
		}

		deinit {
			progressObservation?.invalidate()
		}

		// MARK: - WKNavigationDelegate

		@MainActor
		func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
			loadingState = .fetching
			onProgress(0.0)
		}

		@MainActor
		func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
			loadingState = .fetching
		}

		@MainActor
		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			onProgress(1.0)
			loadingState = .idle
		}

		@MainActor
		func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
			// code -999 = cancelled load / redirect, можно игнорировать как ошибку
			loadingState = .error
		}

		@MainActor
		func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
			loadingState = .error
		}
	}

	// MARK: - helperJS
	
	// window.__applyNativeTheme(theme)
	private let helperJS = """
		(function() {
			window.__applyNativeTheme = function(theme) {
				try {
					// remove previous style if exists
					var prev = document.getElementById('native-theme-style');
					if (prev) prev.parentNode.removeChild(prev);
		
					var style = document.createElement('style');
					style.id = 'native-theme-style';
		
					// basic rules — can extend
					var darkCSS = `
						html, body, * {
							background-color: #1B1C22 !important;
							color: #E6E6E6 !important;
							border-color: rgba(255,255,255,0.12) !important;
							box-shadow: none !important;
							background-image: none !important;
						}
						a { color: #0A84FF !important; }
						img, svg, video { opacity: 0.98 !important; filter: none !important; }
					`;
					var lightCSS = `
						html, body, * {
							background-color: #FFFFFF !important;
							color: #111111 !important;
							border-color: rgba(0,0,0,0.12) !important;
							box-shadow: none !important;
						}
						a { color: #007AFF !important; }
					`;
		
					style.innerHTML = (theme === 'dark') ? darkCSS : lightCSS;
					if (document.head) document.head.appendChild(style);
		
					// target to check from native
					document.documentElement.setAttribute('data-native-theme', theme);
		
					// Replacing matchMedia, site that receives preferes-color-sceheme, receive corrent response
					(function(origMatchMedia, currentTheme) {
						window.matchMedia = function(query) {
							if (query === '(prefers-color-scheme: dark)') {
								var mql = {
									matches: (currentTheme === 'dark'),
									media: query,
									onchange: null,
									addListener: function(){},    // deprecated but sometimes used
									removeListener: function(){},
									addEventListener: function(){},
									removeEventListener: function(){},
									dispatchEvent: function(){ return false; }
								};
								return mql;
							}
							return origMatchMedia(query);
						};
					})(window.matchMedia.bind(window), theme);
		
				} catch(e) {
					// swallow so it won't break site
					console && console.error && console.error('applyNativeTheme error', e);
				}
			};
		})();
		"""
}
