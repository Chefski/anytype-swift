//
//  LoginViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


class LoginViewModel: ObservableObject {
    @Environment(\.authService) private var authService
    @Environment(\.localRepoService) private var localRepoService
    
    @Published var seed: String = ""
    @Published var showQrCodeView: Bool = false
    @Published var error: String? {
        didSet {
            showError = false
            
            if error != nil {
                showError = true
            }
        }
    }
    @Published var showError: Bool = false
    
    
    func recoverWallet() {
        authService.walletRecovery(mnemonic: seed, path: localRepoService.middlewareRepoPath) { result in
            if case .failure(let .recoverWalletError(error)) = result {
                self.error = error
                return
            }
//            applicationCoordinator?.startNewRootView(content: SelectProfileView())
        }
    }
}
