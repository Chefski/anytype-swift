import Combine
import BlocksModels
import ProtobufMessages

protocol ObjectActionsServiceProtocol {
    func delete(objectIds: [BlockId], completion: @escaping (Bool) -> ())
    
    func setArchive(objectId: BlockId, _ isArchived: Bool)
    func setArchive(objectIds: [BlockId], _ isArchived: Bool)
    func setFavorite(objectId: BlockId, _ isFavorite: Bool)
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> [BlockId]?
    func updateDetails(contextID: BlockId, updates: [DetailsUpdate])
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position)
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: [BundledDetails],
        position: BlockPosition, templateId: String
    ) -> BlockId?
    
    func setObjectType(objectId: BlockId, objectTypeUrl: String)
}