//
//  ASEditableTextField+Rx.swift
//
//  Created by Andreas Östman on 2018-01-16.
//  Copyright © 2018 Froggli Studios. All rights reserved.
//

import UIKit
import RxCocoa.Swift
import RxSwift.Swift
import AsyncDisplayKit

extension Reactive where Base: ASEditableTextNode {

    /// Reactive wrapper for `text` property
    public var text: ControlProperty<String?> {
        return value
    }

    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak textNode = self.base] in
            let text = textNode?.attributedText?.string

            let textChanged = textNode?.textView.textStorage
                // This project uses text storage notifications because
                // that's the only way to catch autocorrect changes
                // in all cases. Other suggestions are welcome.
                .rx.didProcessEditingRangeChangeInLength
                // This observe on is here because text storage
                // will emit event while process is not completely done,
                // so rebinding a value will cause an exception to be thrown.
                .observeOn(MainScheduler.asyncInstance)
                .map { _ in
                    return textNode?.textView.textStorage.string
                }
                ?? Observable.empty()

            return textChanged
                .startWith(text)
        }

        let bindingObserver = Binder(self.base) { (textNode, text: String?) in
            // This check is important because setting text value always clears control state
            // including marked text selection which is imporant for proper input
            // when IME input method is used.
            if textNode.attributedText?.string != text {
                textNode.attributedText = NSAttributedString(string: text ?? "")
            }
        }

        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
