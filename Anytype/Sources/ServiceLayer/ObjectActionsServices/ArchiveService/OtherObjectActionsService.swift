import ProtobufMessages
import Combine
import BlocksModels

protocol OtherObjectActionsServiceProtocol {
    func setArchive(_ isArchived: Bool)
    func setFavorite(_ isFavorite: Bool)
}

final class OtherObjectActionsService: OtherObjectActionsServiceProtocol {
    private var objectId: String

    init(objectId: String) {
        self.objectId = objectId
    }

    func setArchive(_ isArchived: Bool) {
        _ = Anytype_Rpc.Object.SetIsArchived.Service.invoke(contextID: objectId, isArchived: isArchived)
    }

    func setFavorite(_ isFavorite: Bool) {
        _ = Anytype_Rpc.Object.SetIsFavorite.Service.invoke(contextID: objectId, isFavorite: isFavorite)
    }
}

