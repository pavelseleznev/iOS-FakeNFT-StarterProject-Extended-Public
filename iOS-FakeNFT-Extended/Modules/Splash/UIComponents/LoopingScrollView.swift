//
//  LoopingScrollView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct LoopingScrollView<Content: View, Items: RandomAccessCollection>: View where Items.Element: Identifiable {
	private let items: Items
	private let layout: Axis.Set
	private let spacing: CGFloat
	private let width: CGFloat
	private let onScrollViewCreated: ((UIScrollView) -> Void)?
	@ViewBuilder private let content: (Items.Element) -> Content
	
	init(
		items: Items,
		layout: Axis.Set = .horizontal,
		spacing: CGFloat = 0,
		width: CGFloat,
		onScrollViewCreated: ((UIScrollView) -> Void)? = nil,
		content: @escaping (Items.Element) -> Content
	) {
		self.items = items
		self.layout = layout
		self.spacing = spacing
		self.width = width
		self.onScrollViewCreated = onScrollViewCreated
		self.content = content
	}
	
	var body: some View {
		GeometryReader { geo in
			ScrollView(layout) {
				stackContainer {
					Group {
						ForEach(items) { item in
							content(item)
								.frame(width: width)
						}
						
						ForEach(
							0..<repeatingCount(screenWidth: geo.size.width),
							id: \.self
						) { index in
							let item = Array(items)[index % items.count]
							content(item)
								.frame(width: width)
						}
					}
				}
				.background(
					ScrollViewHelperRepresentable(
						width: width,
						spacing: spacing,
						itemsCount: items.count,
						onScrollViewCreated: onScrollViewCreated
					)
				)
			}
		}
	}
	
	private func repeatingCount(screenWidth: CGFloat) -> Int {
		width > 0 ? Int((screenWidth / width).rounded()) + 1 : 1
	}
	
	@ViewBuilder
	private func stackContainer<StackContent: View>(_ content: () -> StackContent) -> some View {
		switch layout {
		case .vertical:
			LazyVStack(spacing: spacing, content: content)
		default:
			LazyHStack(spacing: spacing, content: content)
		}
	}
}

// MARK: - ScrollView UIKit helper
fileprivate struct ScrollViewHelperRepresentable: UIViewRepresentable {
	let width: CGFloat
	let spacing: CGFloat
	let itemsCount: Int
	let onScrollViewCreated: ((UIScrollView) -> Void)?
	
	func makeCoordinator() -> Coordinator {
		.init(
			width: width,
			spacing: spacing,
			itemsCount: itemsCount
		)
	}
	
	func makeUIView(context: Context) -> some UIView {
		.init()
	}
	
	func updateUIView(_ uiView: UIViewType, context: Context) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			if
				let scrollView = uiView.superview?.superview?.superview as? UIScrollView,
				!context.coordinator.isAdded
			{
				scrollView.delegate = context.coordinator
				context.coordinator.isAdded = true
				onScrollViewCreated?(scrollView)
			}
		}
		
		context.coordinator.width = width
		context.coordinator.spacing = spacing
		context.coordinator.itemsCount = itemsCount
	}
	
	class Coordinator: NSObject, UIScrollViewDelegate {
		var width: CGFloat
		var spacing: CGFloat
		var itemsCount: Int
		
		init(
			width: CGFloat,
			spacing: CGFloat,
			itemsCount: Int
		) {
			self.width = width
			self.spacing = spacing
			self.itemsCount = itemsCount
		}
		
		var isAdded = false // Tells us whether the delegate is added or not
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			guard itemsCount > 0, width > 0 else { return }

			 let offset = scrollView.contentOffset.x
			 let itemContentSize = width + spacing
			 let mainContentSize = CGFloat(itemsCount) * itemContentSize

			 if offset > mainContentSize {
				 scrollView.contentOffset.x = offset - mainContentSize
			 } else if offset < 0 {
				 scrollView.contentOffset.x = mainContentSize + offset
			 }
		}
	}
}
