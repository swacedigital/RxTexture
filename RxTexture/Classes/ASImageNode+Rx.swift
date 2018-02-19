//
//  ASImageNode+Rx.swift
//
//  Created by Andreas Östman on 2018-01-16.
//  Copyright © 2018 Froggli Studios. All rights reserved.
//

import UIKit
import RxCocoa.Swift
import RxSwift.Swift
import AsyncDisplayKit

extension Reactive where Base: ASImageNode {

    /// Bindable sink for `image` property.
    public var image: Binder<UIImage> {
        return Binder(self.base) { control, value in
            control.image = value
        }
    }
}

extension Reactive where Base: ASNetworkImageNode {

    /// Bindable sink for `url` property.
    public var url: Binder<URL> {
        return Binder(self.base) { control, value in
            control.image = nil
            control.url = value
        }
    }
}
