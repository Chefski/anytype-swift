//
//  StatusRelationView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct StatusRelationView: View {
    let value: StatusRelationValue?
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if let value = value {
            AnytypeText(value.text, style: style.font, color: value.color.asColor)
                .lineLimit(1)
        } else {
            RelationsListRowHintView(hint: hint)
        }
    }
}

struct StatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationView(value: StatusRelationValue(text: "text", color: .pureTeal), hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
