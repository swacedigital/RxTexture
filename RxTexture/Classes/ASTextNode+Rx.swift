//
//  ASTextNode+Rx.swift
//  Godisdags
//
//  Created by Andreas Östman on 2018-01-16.
//  Copyright © 2018 Froggli Studios. All rights reserved.
//

import UIKit
import RxCocoa.Swift
import RxSwift.Swift
import AsyncDisplayKit

extension Reactive where Base: ASTextNode {

    public var title: Binder<NSAttributedString> {
        return Binder(self.base) { control, value in
            control.attributedText = value
        }
    }
}

extension Reactive where Base: ASTextNode {

    /// Reactive wrapper for `text` property.
    public var text: ControlProperty<String?> {
        return value
    }

    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        return ASControlNode.valuePublic(
            base,
            getter: { textField in
                textField.attributedText?.string
        }, setter: { textField, value in
            // This check is important because setting text value always clears control state
            // including marked text selection which is imporant for proper input
            // when IME input method is used.
            if textField.attributedText?.string != value {
                textField.attributedText = NSAttributedString(string: value ?? "")
            }
        }
        )
    }

}
