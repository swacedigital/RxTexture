//
//  ASControlNode+Rx.swift
//  Godisdags
//
//  Created by Andreas Östman on 2018-01-16.
//  Copyright © 2018 Froggli Studios. All rights reserved.
//

import UIKit
import RxCocoa.Swift
import RxSwift.Swift
import AsyncDisplayKit

extension Reactive where Base: ASControlNode {

    /// Reactive wrapper for `TouchUpInside` control event.
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

extension Reactive where Base: ASButtonNode {

    public var title: Binder<NSAttributedString> {
        return Binder(self.base) { control, value in
            control.setAttributedTitle(value, for: .normal)
        }
    }
}

extension Reactive where Base: ASEditableTextNode {

    public var title: Binder<NSAttributedString> {
        return Binder(self.base) { control, value in
            control.attributedText = value
        }
    }
}


extension Reactive where Base: ASControlNode {

    /// Bindable sink for `enabled` property.
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }

    /// Bindable sink for `selected` property.
    public var isSelected: Binder<Bool> {
        return Binder(self.base) { control, selected in
            control.isSelected = selected
        }
    }

    /// Reactive wrapper for target action pattern.
    ///
    /// - parameter controlEvents: Filter for observed event types.
    public func controlEvent(_ controlEvents: ASControlNodeEvent) -> ControlEvent<Void> {
        let source: Observable<Void> = Observable.create { [weak control = self.base] observer in
            MainScheduler.ensureExecutingOnScheduler()

            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let controlTarget = ASControlTarget(control: control, controlEvents: controlEvents) {
                control in
                observer.on(.next(()))
            }

            return Disposables.create(with: controlTarget.dispose)
            }.takeUntil(deallocated)

        return ControlEvent(events: source)
    }
}


extension ASControlNode {
     static func valuePublic<T, ControlType: ASControlNode>(_ control: ControlType, getter:  @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> ()) -> ControlProperty<T> {
        let values: Observable<T> = Observable.deferred { [weak control] in
            guard let existingSelf = control else {
                return Observable.empty()
            }

            return (existingSelf as ASControlNode).rx.controlEvent([.valueChanged])
                .flatMap { _ in
                    return control.map { Observable.just(getter($0)) } ?? Observable.empty()
                }
                .startWith(getter(existingSelf))
        }
        return ControlProperty(values: values, valueSink: Binder(control) { control, value in
            setter(control, value)
        })
    }
}


