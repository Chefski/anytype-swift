import Foundation
import AnytypeCore
import SwiftProtobuf

public struct ObjectDetails: Hashable, RelationValuesProtocol {
    
    public let id: String
    public let values: [String: Google_Protobuf_Value]
    
    public init(id: String, values: [String: Google_Protobuf_Value]) {
        self.id = id
        self.values = values
    }
    
    public func updated(by rawDetails: [String: Google_Protobuf_Value]) -> ObjectDetails {
        guard !rawDetails.isEmpty else { return self }
        
        let newValues = self.values.merging(rawDetails) { (_, new) in new }
        
        return ObjectDetails(
            id: self.id,
            values: newValues
        )
    }
    
    public func removed(keys: [String]) -> ObjectDetails {
        guard keys.isNotEmpty else { return self }
        
        var currentValues = self.values
        
        keys.forEach {
            currentValues.removeValue(forKey: $0)
        }
        
        return ObjectDetails(
            id: self.id,
            values: currentValues
        )
    }
    
}
