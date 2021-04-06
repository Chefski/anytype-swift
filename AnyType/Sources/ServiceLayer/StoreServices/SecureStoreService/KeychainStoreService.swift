private enum StoreServiceConstants {
    static let serviceName = "com.AnyType.seed"
    static let defaultName = "defaultAnyTypeSeed"
}

/// Keychain store serivce
final class KeychainStoreService: SecureStoreServiceProtocol {
    private let keychainStore: KeychainStore
    init(keychainStore: KeychainStore) {
        self.keychainStore = keychainStore
    }
    
    func containsSeed(for publicKey: String?) -> Bool {
        let seedQuery = GenericPasswordQueryable(account: publicKey ?? StoreServiceConstants.defaultName, service: StoreServiceConstants.serviceName)
        
        return keychainStore.contains(queryable: seedQuery)
    }
    
    func removeSeed(for publicKey: String?, keyChainPassword: KeychainPasswordType) throws {
        let seedQuery = GenericPasswordQueryable(account: publicKey ?? StoreServiceConstants.defaultName, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
        try keychainStore.removeItem(queryable: seedQuery)
    }
    
    func obtainSeed(for name: String?, keyChainPassword: KeychainPasswordType) throws -> String {
        let seedQuery = GenericPasswordQueryable(account: name ?? StoreServiceConstants.defaultName, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
        let seed = try keychainStore.retreiveItem(queryable: seedQuery)
        return seed
    }
    
    func saveSeedForAccount(name: String?, seed: String, keyChainPassword: KeychainPasswordType) throws {
        let seedQuery = GenericPasswordQueryable(account: name ?? StoreServiceConstants.defaultName, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
        try keychainStore.storeItem(item: seed, queryable: seedQuery)
    }
}
