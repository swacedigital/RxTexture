//
//  ASControlTarget.swift
//
//  Created by Andreas Östman on 2018-01-16.
//  Copyright © 2018 Froggli Studios. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit


// This should be only used from `MainScheduler`
final class ASControlTarget: ASRxTarget {
    typealias Control = ASControlNode
    typealias ControlEvents = ASControlNodeEvent
    typealias Callback = (Control) -> Void

    let selector: Selector = #selector(ASControlTarget.eventHandler(_:))

    weak var control: Control?
    let controlEvents: ASControlNodeEvent
    var callback: Callback?

    init(control: Control, controlEvents: ControlEvents, callback: @escaping Callback) {
        MainScheduler.ensureExecutingOnScheduler()

        self.control = control
        self.controlEvents = controlEvents
        self.callback = callback

        super.init()

        control.addTarget(self, action: selector, forControlEvents: controlEvents)

        let method = self.method(for: selector)
        if method == nil {
            fatalError("Can't find method")
        }
    }

    @objc func eventHandler(_ sender: Control!) {
        if let callback = self.callback, let control = self.control {
            callback(control)
        }
    }

    override func dispose() {
        super.dispose()
        self.control?.removeTarget(self, action: self.selector, forControlEvents: self.controlEvents)
        self.callback = nil
    }
}

class ASRxTarget : NSObject, Disposable {

    private var retainSelf: ASRxTarget?

    override init() {
        super.init()
        self.retainSelf = self

        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }

    func dispose() {
        self.retainSelf = nil
    }

    #if TRACE_RESOURCES
    deinit {
    _ = Resources.decrementTotal()
    }
    #endif
}


