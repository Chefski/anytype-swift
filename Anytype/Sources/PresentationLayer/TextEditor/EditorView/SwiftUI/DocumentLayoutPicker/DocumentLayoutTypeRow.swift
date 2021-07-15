//
//  DocumentLayoutTypeRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct DocumentLayoutTypeRow: View {
    
    let layout: DetailsLayout
    let isSelected: Bool
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        }
        label: {
            HStack(spacing: 9) {
                layout.icon.frame(width: 24, height: 24)
                AnytypeText(layout.title, style: .headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image.LayoutSettings.checkmark.frame(width: 24, height: 24)
                }
            }
        }
        .padding(.top, 12)
        .modifier(DividerModifier(spacing: 12))
            
    }
}

private extension DetailsLayout {
    
    var icon: Image {
        switch self {
        case .basic:
            return Image.LayoutSettings.basic
        case .profile:
            return Image.LayoutSettings.profile
        }
    }
    
    var title: String {
        switch self {
        case .basic:
            return "Basic"
        case .profile:
            return "Profile"
        }
    }
    
}

struct DocumentLayoutTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        DocumentLayoutTypeRow(layout: .basic, isSelected: true, onTap: {})
            .background(Color.blue)
    }
}
