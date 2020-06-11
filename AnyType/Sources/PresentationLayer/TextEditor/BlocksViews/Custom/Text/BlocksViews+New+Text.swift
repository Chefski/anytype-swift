//
//  BlocksViews+New+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.New.Text {
    enum Text {} // -> Text.ContentType.text
    enum Header {} // -> Text.ContentType.header
    enum Quote {} // -> Text.ContentType.quote
    enum Checkbox {} // -> Text.ContentType.todo
    enum Bulleted {} // -> Text.ContentType.bulleted
    enum Numbered {} // -> Text.ContentType.numbered
    enum Toggle {} // -> Text.ContentType.toggle
    enum Callout {} // -> Text.ContentType.callout
}

// MARK: UserInteraction
extension BlocksViews.New.Text {
    /// This is Event wrapper enumeration.
    ///
    /// Consider following scenario.
    ///
    /// You have several delegates that sends events.
    ///
    /// `ADelegate` sends `AEvent` and `BDelegate` sends `BEvent`
    ///
    /// Let us wrap them into one action.
    ///
    /// enum Action {
    ///  .aAction(AEvent)
    ///  .bAction(BEvent)
    /// }
    ///
    /// This `UserInteraction` enumeration wrap `TextView.UserAction` and `ButtonView.UserAction` together
    ///
    enum UserInteraction {
        case textView(TextView.UserAction)
        case buttonView(ButtonView.UserAction)
    }
}

extension BlocksViews.New.Text.UserInteraction {
    enum ButtonView {
        enum UserAction {
            enum Toggle {
                case toggled(Bool)
                case insertFirst(Bool)
            }
            case toggle(Toggle)
            case checkbox(Bool)
        }
    }
}

