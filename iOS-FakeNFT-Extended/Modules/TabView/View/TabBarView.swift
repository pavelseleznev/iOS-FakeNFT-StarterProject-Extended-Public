import SwiftUI

struct TabBarView: View {
	let appContainer: AppContainer
	let push: (Page) -> Void
	let present: (Sheet) -> Void
	let dismiss: () -> Void
	
    var body: some View {
        TabView {
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
				.tabItem {
					Group {
						tab.imageView()
						Text(tab.title)
					}
				}
			}
        }
    }
}

struct ReplaceThisViewIsteadOfYours: View {
	let appContainer: AppContainer
	let push: (Page) -> Void
	let present: (Sheet) -> Void
	let dismiss: () -> Void
	let title: String
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			Button {
				push(.tabView)
			} label: {
				Text(title)
					.font(.title)
					.bold()
			}
		}
	}
}
