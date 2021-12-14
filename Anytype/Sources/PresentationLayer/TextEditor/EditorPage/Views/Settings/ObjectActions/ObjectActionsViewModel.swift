import Foundation
import Combine
import BlocksModels


final class ObjectActionsViewModel: ObservableObject {
    private let service = ObjectActionsService()
    private let objectId: BlockId

    @Published var details: ObjectDetails = ObjectDetails(id: "", values: [:]) {
        didSet {
            objectActions = ObjectAction.allCasesWith(details: details, objectRestrictions: objectRestrictions)
        }
    }
    @Published var objectRestrictions: ObjectRestrictions = ObjectRestrictions() {
        didSet {
            objectActions = ObjectAction.allCasesWith(details: details, objectRestrictions: objectRestrictions)
        }
    }
    @Published var objectActions: [ObjectAction] = []

    let popScreenAction: () -> ()
    var dismissSheet: () -> () = {}
    
    init(objectId: String, popScreenAction: @escaping () -> ()) {
        self.objectId = objectId
        self.popScreenAction = popScreenAction
    }

    func changeArchiveState() {
        let isArchived = !details.isArchived
        service.setArchive(objectId: objectId, isArchived)
        if isArchived {
            popScreenAction()
            dismissSheet()
        }
    }

    func changeFavoriteSate() {
        service.setFavorite(objectId: objectId, !details.isFavorite)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}