import BlocksModels

struct ImageBlockRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    let turnIntoStyles = [BlockContentType]()
    let availableAlignments = LayoutAlignment.allCases
}
