import ProtobufMessages
import Services

struct AccountData {
    
    let id: BlockId
    let name: String
    let avatar: Anytype_Model_Account.Avatar
    let config: AccountConfiguration
    var status: AccountStatus
    let info: AccountInfo
    
    static var empty: AccountData {
        AccountData(id: "", name: "", avatar: .init(), config: .empty, status: .active, info: .empty)
    }
}

extension Anytype_Model_Account {
    var asModel: AccountData {
        AccountData(
            id: id,
            name: name,
            avatar: avatar,
            config: config.asModel,
            status: status.asModel ?? .active,
            info: info.asModel
        )
    }
}
