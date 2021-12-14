enum BlockBookmarkState: Hashable, Equatable {
    case onlyURL(String)
    case fetched(BlockBookmarkPayload)
}

struct BlockBookmarkPayload: Hashable, Equatable {
    let url: String
    let title: String
    let subtitle: String
    let imageHash: String
    let faviconHash: String
}