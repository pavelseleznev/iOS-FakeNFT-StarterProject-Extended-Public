import SwiftUI

struct TabBarView: View {
	let appContainer: AppContainer
    let myNFTStore: MyNFTViewModel
    let favoriteNFTStore: FavoriteNFTViewModel
	let push: (Page) -> Void
	let present: (Sheet) -> Void
	let dismiss: () -> Void
	let pop: () -> Void
	
	@State private var tab: Tab = .catalog
	
    var body: some View {
		TabView(selection: $tab) {
			ForEach(
				Array(Tab.allCases.enumerated()),
				id: \.offset
			) { index, tab in
				tab.view(
                    appContainer: appContainer,
                    myNFTStore: myNFTStore,
                    favoriteNFTStore: favoriteNFTStore,
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
    }
}
