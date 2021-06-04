protocol SeedServiceProtocol {
    
    /// Obtain seed for public key
    /// - Parameter name: public key
    /// - Parameter keychainPassword: keychain password
    /// - Returns: seed
    func obtainSeed(for name: String?, keychainPassword: KeychainPasswordType?) throws -> String
    
    /// Save seed to keychain
    /// - Parameter name: public key
    /// - Parameter seed: seed
    /// - Parameter keychainPassword: keychain password that will protect seed
    func saveSeedForAccount(name: String?, seed: String, keychainPassword: KeychainPasswordType?) throws
    
    /// Check if seed exists for public key
    /// - Parameter publicKey: public key
    /// - Returns: true if seed exists otherwise false
    func containsSeed(for publicKey: String?) -> Bool
    
    /// Remove seed
    /// - Parameter publicKey: public key
    func removeSeed(for publicKey: String?, keychainPassword: KeychainPasswordType?) throws
}
