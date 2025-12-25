import SwiftUI

struct TabBarView: View {
	let appContainer: AppContainer
	let push: (Page) -> Void
	let present: (Sheet) -> Void
	let dismiss: () -> Void
	let pop: () -> Void
	
	@State private var tab: Tab = .catalog
	@State private var isVisible = false
	
    var body: some View {
		TabView(selection: $tab) {
			ForEach(
				Array(Tab.allCases.enumerated()),
				id: \.offset
			) { index, tab in
				tab.view(
					appContainer: appContainer,
					push: push,
					present: present,
					dismiss: dismiss
				)
				.tag(tab)
				.tabItem {
					Group {
						tab.imageView()
						Text(tab.title)
					}
				}
			}
        }
		.opacity(isVisible ? 1 : 0.6)
		.blur(radius: isVisible ? 0 : 10)
		.onAppear {
			withAnimation(.easeInOut(duration: 0.3)) {
				isVisible = true
			}
		}
    }
}
