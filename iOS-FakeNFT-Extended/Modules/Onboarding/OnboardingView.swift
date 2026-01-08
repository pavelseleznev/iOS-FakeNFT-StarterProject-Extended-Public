//
//  OnboardingView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 27.12.2025.
//

import SwiftUI
import Combine

// MARK: - fileprivate enum
fileprivate enum Selection: String, CaseIterable, Identifiable {
	case explore, collect, compete
	
	var id: String { rawValue }
	
	var isLast: Bool {
		self == .compete
	}
	
	var next: Self {
		switch self {
		case .explore:
			.collect
		case .collect:
			.compete
		case .compete:
			.compete
		}
	}
	
	var title: LocalizedStringResource {
		switch self {
		case .explore:
			.onboardingExploreTitle
		case .collect:
			.onboardingCollectTitle
		case .compete:
			.onboardingCompeteTitle
		}
	}
	
	var body: LocalizedStringResource {
		switch self {
		case .explore:
			.onboardingExploreBody
		case .collect:
			.onboardingCollectBody
		case .compete:
			.onboardingCompeteBody
		}
	}
	
	var image: Image {
		switch self {
		case .explore:
			Image(.onboardingExplore)
		case .collect:
			Image(.onboardingCollect)
		case .compete:
			Image(.onboardingCompete)
		}
	}
}

// MARK: - Local constants
fileprivate let autoRollInterval: TimeInterval = 0.05

// MARK: - View
struct OnboardingView: View {
	let onComplete: () -> Void
	
	@State private var selection: Selection = .explore
	@State private var autoscrollProgress: CGFloat = 0
	@State private var cancellable: Cancellable?
	
	var body: some View {
		GeometryReader { geo in
			TabView(selection: $selection) {
				ForEach(Selection.allCases) { tab in
					pageView(tab: tab, height: geo.size.height)
				}
			}
			.ignoresSafeArea()
			.background(.ypBlackUniversal)
			.tabViewStyle(.page(indexDisplayMode: .never))
			.safeAreaInset(edge: .top, content: topToolbar)
			.safeAreaInset(edge: .bottom, content: completeButton)
			.animation(.default, value: selection)
			.onAppear(perform: rollNext)
			.onDisappear(perform: clearCancellable)
			.onChange(of: selection, performSelectionChange)
		}
		.ignoresSafeArea(edges: .bottom)
	}
}

// MARK: - OnboardingView Extensions
// --- private methods ---
fileprivate extension OnboardingView {
	func rollNext() {
		cancellable = Timer
			.publish(every: autoRollInterval, on: .main, in: .common)
			.autoconnect()
			.sink { _ in
				guard !selection.isLast else {
					clearCancellable()
					return
				}
				
				autoscrollProgress += autoRollInterval / 4
				
				if autoscrollProgress >= 1 {
					selection = selection.next
				}
			}
	}
	
	func performSelectionChange(_ oldValue: Selection, _ newValue: Selection) {
		HapticPerfromer.shared.play(.selection)
		clearCancellable()
		autoscrollProgress = 0
		rollNext()
	}
	
	func clearCancellable() {
		cancellable?.cancel()
		cancellable = nil
	}
}

// --- private subviews ---
fileprivate extension OnboardingView {
	func pageView(tab: Selection, height: CGFloat) -> some View {
		tab.image
			.resizable()
			.overlay {
				ZStack(alignment: .leading) {
					LinearGradient(
						colors: [.ypBlackUniversal, .clear],
						startPoint: .top,
						endPoint: .bottom
					)
					
					VStack(alignment: .leading, spacing: 12) {
						Text(tab.title)
							.font(.bold32)
							.foregroundStyle(.ypWhiteUniversal)
						
						Text(tab.body)
							.font(.regular15)
							.foregroundStyle(.ypWhiteUniversal)
					}
					.padding(.bottom, height * 0.3)
					.padding(.horizontal)
				}
			}
			.tag(tab)
			.ignoresSafeArea()
	}
	
	@ViewBuilder
	func completeButton() -> some View {
		if selection.isLast {
			Button(action: onComplete) {
				Text(.onboardingCompleteButtonTitle)
					.font(.bold17)
					.padding(.vertical, 8)
			}
			.nftButtonStyle(filled: true)
			.padding()
			.safeAreaPadding(.bottom)
			.safeAreaPadding(.bottom)
			.colorScheme(.light)
			.shadow(color: .ypWhiteUniversal.opacity(0.1), radius: 20)
			.transition(.move(edge: .bottom).combined(with: .opacity))
		}
	}
	
	func topToolbar() -> some View {
		VStack(alignment: .trailing, spacing: 12) {
			TabIndicatorsView(
				items: Selection.allCases,
				selection: selection,
				autoscrollProgress: autoscrollProgress,
				isConstantAppearance: true
			)
			.padding(.horizontal)
			
			if !selection.isLast {
				Button(action: onComplete) {
					Image.xmark
						.font(.xmarkIcon)
						.foregroundStyle(.ypWhiteUniversal)
						.frame(width: 24, height: 24)
						.frame(width: 48, height: 48)
				}
				.transition(.move(edge: .trailing).combined(with: .opacity))
				.padding(.trailing, 8)
			}
		}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	OnboardingView(onComplete: {})
}
#endif
