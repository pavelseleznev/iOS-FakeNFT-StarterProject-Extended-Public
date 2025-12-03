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
	@Binding var isLoading: Bool
	var colorScheme: ColorScheme
	var onProgress: (Double) -> Void = { _ in }
	
	func makeUIView(context: Context) -> some UIView {
		let config = WKWebViewConfiguration()

		let userScript = WKUserScript(source: helperJS, injectionTime: .atDocumentStart, forMainFrameOnly: true)
		config.userContentController.addUserScript(userScript)
		
		let webView = WKWebView(frame: .zero, configuration: config)
		
		webView.navigationDelegate = context.coordinator
		context.coordinator.attach(to: webView)
		
		webView.load(URLRequest(url: url))
		return webView
	}
	
	func updateUIView(_ uiView: UIViewType, context: Context) {
		if let webView = uiView as? WKWebView {
			webView.overrideUserInterfaceStyle = (colorScheme == .dark) ? .dark : .light
			let themeString = (colorScheme == .dark) ? "dark" : "light"
			let js = "window.__applyNativeTheme && window.__applyNativeTheme('\(themeString)');"
			webView.evaluateJavaScript(js, completionHandler: nil)
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			isLoading: $isLoading,
			onProgress: onProgress
		)
	}
	
	class Coordinator: NSObject, WKNavigationDelegate {
		@Binding var isLoading: Bool
		let onProgress: (Double) -> Void
		
		weak var webView: WKWebView?
		
		private var isObservingProgress = false
		
		private var progressObservation: NSKeyValueObservation?
		private let estimatedProgressKeyPath = "estimatedProgress"
		
		init(
			isLoading: Binding<Bool>,
			onProgress: @escaping (Double) -> Void
		) {
			self._isLoading = isLoading
			self.onProgress = onProgress
		}

		func attach(to webView: WKWebView) {
			self.webView = webView
			guard !isObservingProgress else { return }
			webView.addObserver(
				self,
				forKeyPath: #keyPath(WKWebView.estimatedProgress),
				options: .new,
				context: nil
			)
			isObservingProgress = true
		}
		
		@MainActor
		@objc private func applyProgressNumber(_ number: NSNumber) {
			let progress = number.doubleValue
			onProgress(progress)
			isLoading = progress < 0.999
		}
		
		override func observeValue(
			forKeyPath keyPath: String?,
			of object: Any?,
			change: [NSKeyValueChangeKey : Any]?,
			context: UnsafeMutableRawPointer?
		) {
			guard
				keyPath == estimatedProgressKeyPath
			else {
				super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
				return
			}
			
			// --- берем значение из change, чтобы не читать @MainActor объект ---
			let progress = (change?[.newKey] as? NSNumber)?.doubleValue ?? 0.0
			
			// --- главный поток без @Sendable ---
			self.performSelector(
				onMainThread: #selector(applyProgressNumber(_:)),
				with: NSNumber(value: progress),
				waitUntilDone: false
			)
		}
		
		deinit {
			if
				let webView,
				isObservingProgress
			{
				webView
					.removeObserver(
						self,
						forKeyPath: estimatedProgressKeyPath
					)
			}
			isObservingProgress = false
		}
		
		// --- WKNavigationDelegate ---
		@MainActor
		func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
			isLoading = true
			onProgress(0.0)
		}
		
		@MainActor
		func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
			isLoading = true
		}
		
		@MainActor
		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			onProgress(1.0)
			isLoading = false
		}
		
		@MainActor
		func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
			isLoading = false
		}
		
		@MainActor
		func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
			isLoading = false
		}
	}
	
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