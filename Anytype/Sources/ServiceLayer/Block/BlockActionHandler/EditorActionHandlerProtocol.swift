//
//  EditorActionHandlerProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()
    
    func uploadMediaFile(
        itemProvider: NSItemProvider,
        type: MediaPickerContentType,
        blockId: ActionHandlerBlockIdSource
    )
    func uploadFileAt(localPath: String, blockId: ActionHandlerBlockIdSource)
        
    func turnIntoPage(blockId: ActionHandlerBlockIdSource) -> BlockId?
    func createPage(targetId: BlockId) -> BlockId?
    func showPage(blockId: ActionHandlerBlockIdSource)
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    func handleTypeChange(selectedType: String)
}
