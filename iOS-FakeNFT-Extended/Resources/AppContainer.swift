//
//  AppContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


struct AppContainer {
    let profileService: ProfileServiceProtocol
    let purchasedNFTsService: NFTsIDsServiceProtocol
    //TODO: Uncomment for merge
    //let cartService: CartServiceProtocol
    let nftService: NFTServiceProtocol
    let api: ObservedNetworkClient
    
    @MainActor
    static var mock: Self {
        let api = ObservedNetworkClient()
        let orderService = NFTsIDsService(api: api, kind: .order)
        
        return .init(
            profileService: ProfileService(
                api: api,
                storage: ProfileStorage()
            ),
            purchasedNFTsService: NFTsIDsService(
                api: api,
                kind: .purchased
            ),
            //TODO: Uncomment for merge
//            cartService: CartService(
//                orderService: orderService,
//                api: api
//            ),
            nftService: NFTService(
                favouritesService: NFTsIDsService(
                    api: api,
                    kind: .favorites
                ),
                orderService: orderService,
                loadNFT: api.getNFT
            ),
            api: api
        )
    }
}
