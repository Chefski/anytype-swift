import Combine
import Services
import AnytypeCore

protocol SetObjectCreationSettingsInteractorProtocol {
    var mode: SetObjectCreationSettingsMode { get }
    
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { get }
    var objectTypeId: ObjectTypeId { get }
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> { get }
    func setObjectTypeId(_ objectTypeId: ObjectTypeId)
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws
    func setDefaultTemplate(templateId: BlockId) async throws
}

final class SetObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol {
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { $canChangeObjectType.eraseToAnyPublisher() }
    
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> {
        Publishers.CombineLatest($objectTypes, $objectTypeId)
            .map { objectTypes, objectTypeId in
                return ObjectTypesConfiguration(
                    objectTypes: objectTypes,
                    objectTypeId: objectTypeId
                )
            }
            .eraseToAnyPublisher()
    }
    
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> {
        Publishers.CombineLatest3($templatesDetails, $defaultTemplateId, $typeDefaultTemplateId)
            .map { details, defaultTemplateId, typeDefaultTemplateId in
                let templateId = defaultTemplateId.isNotEmpty ? defaultTemplateId : typeDefaultTemplateId
                return details.map {
                    TemplatePreviewModel(
                        objectDetails: $0,
                        isDefault: $0.id == templateId
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    @Published var objectTypeId: ObjectTypeId
    @Published var canChangeObjectType = false
    @Published private var objectTypes = [ObjectType]()
    
    let mode: SetObjectCreationSettingsMode
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let objectTypesProvider: ObjectTypeProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: BlockId
    @Published private var typeDefaultTemplateId: BlockId = .empty
    
    private var dataView: DataviewView
    
    private var cancellables = [AnyCancellable]()
    
    init(
        mode: SetObjectCreationSettingsMode,
        setDocument: SetDocumentProtocol,
        viewId: String,
        objectTypesProvider: ObjectTypeProviderProtocol,
        subscriptionService: TemplatesSubscriptionServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.mode = mode
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataView = setDocument.view(by: viewId)
        self.defaultTemplateId = dataView.defaultTemplateID ?? .empty
        self.subscriptionService = subscriptionService
        self.objectTypesProvider = objectTypesProvider
        self.dataviewService = dataviewService
        
        let defaultObjectTypeID = dataView.defaultObjectTypeIDWithFallback
        if setDocument.isTypeSet() {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.objectTypeId = .dynamic(firstSetOf)
            } else {
                self.objectTypeId = .dynamic(defaultObjectTypeID)
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        } else {
            self.objectTypeId = .dynamic(defaultObjectTypeID)
        }
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    func setObjectTypeId(_ objectTypeId: ObjectTypeId) {
        updateState(with: objectTypeId)
    }
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: "", defaultObjectTypeID: objectTypeId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    func setDefaultTemplate(templateId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    private func updateState(with objectTypeId: ObjectTypeId) {
        self.objectTypeId = objectTypeId
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.syncPublisher.sink { [weak self] in
            guard let self else { return }
            dataView = setDocument.view(by: dataView.id)
            if defaultTemplateId != dataView.defaultTemplateID {
                defaultTemplateId = dataView.defaultTemplateID ?? .empty
            }
            
            guard mode == .default else { return }
            
            if !setDocument.isTypeSet(), objectTypeId.rawValue != dataView.defaultObjectTypeIDWithFallback {
                updateState(with: .dynamic(dataView.defaultObjectTypeIDWithFallback))
            }
        }.store(in: &cancellables)
        
        setDocument.detailsPublisher.sink { [weak self] details in
            guard let self else { return }
            let isNotTypeSet = !setDocument.isTypeSet()
            if canChangeObjectType != isNotTypeSet {
                canChangeObjectType = isNotTypeSet
            }
        }
        .store(in: &cancellables)
    
        objectTypesProvider.syncPublisher.sink { [weak self] in
            self?.updateObjectTypes()
            self?.updateTypeDefaultTemplateId()
        }.store(in: &cancellables)
    }
    
    private func updateObjectTypes() {
        let objectTypes = objectTypesProvider.objectTypes.filter {
            !$0.isArchived && DetailsLayout.visibleLayouts.contains($0.recommendedLayout)
        }
        self.objectTypes = objectTypes.reordered(
            by: [
                ObjectTypeId.bundled(.page).rawValue,
                ObjectTypeId.bundled(.note).rawValue,
                ObjectTypeId.bundled(.task).rawValue,
                ObjectTypeId.bundled(.collection).rawValue
            ]
        ) { $0.id }
    }
    
    private func updateTypeDefaultTemplateId() {
        let defaultTemplateId = objectTypes.first { [weak self] in
            guard let self else { return false }
            return $0.id == objectTypeId.rawValue
        }?.defaultTemplateId ?? .empty
        if typeDefaultTemplateId != defaultTemplateId {
            typeDefaultTemplateId = defaultTemplateId
        }
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: objectTypeId) { [weak self] _, update in
            guard let self else { return }
            templatesDetails.applySubscriptionUpdate(update)
            updateTypeDefaultTemplateId()
        }
    }
}
