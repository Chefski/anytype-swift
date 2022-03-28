//
//  PasteboardOperation.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import AnytypeCore

final class PasteboardOperation: AsyncOperation {

    // MARK: - Private variables

    private let pasteboardAction: PasteboardSlotActionProtocol
    private let completion: (_ isSuccess: Bool) -> Void
    private let context: PasteboardActionContext

    // MARK: - Initializers

    init(pasteboardValue: PasteboardSlotActionProtocol, context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void) {
        self.pasteboardAction = pasteboardValue
        self.context = context
        self.completion = completion

        super.init()
    }

    override func start() {
        guard !isCancelled else {
            return
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            self.pasteboardAction.performPaste(context: self.context) { isSuccess in
                self.completion(isSuccess)

                self.state = .finished
            }
        }

        state = .executing
    }
}
