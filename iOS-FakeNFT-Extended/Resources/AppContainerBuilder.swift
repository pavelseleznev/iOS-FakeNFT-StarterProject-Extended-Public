//
//  AppContainerBuilder.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.01.2026.
//


struct AppContainerBuilder {
	private init() {}
	
	@MainActor
	static func build() -> AppContainer {
		let api = ObservedNetworkClient()
		
		let profileStorage = ProfileStorage()
		
		let favouritedNFTsService = NFTsIDsService(api: api, kind: .favorites)
		let purchasedNFTsService = NFTsIDsService(api: api, kind: .purchased)
		let orderNFTsService = NFTsIDsService(api: api, kind: .order)
		
		let cartService = CartService(
			orderService: orderNFTsService,
			api: api
		)
		
		let profileService = ProfileService(api: api, storage: profileStorage)
		let nftService = NFTService(
			favouritesService: favouritedNFTsService,
			orderService: orderNFTsService,
			loadNFT: api.getNFT
		)
		
		let currenciesService = CurrenciesService(api: api)
		
		let appContainer = AppContainer(
			currenciesService: currenciesService,
			profileService: profileService,
			purchasedNFTsService: purchasedNFTsService,
			cartService: cartService,
			nftService: nftService,
			api: api
		)
		
		return appContainer
	}
}
