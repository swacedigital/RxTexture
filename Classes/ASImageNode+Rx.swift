//
//  ASImageNode+Rx.swift
//  Godisdags
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
    public var image: UIBindingObserver<Base, UIImage> {
        return UIBindingObserver(UIElement: self.base) { control, value in
            control.image = value
        }
    }
}

extension Reactive where Base: ASNetworkImageNode {

    /// Bindable sink for `url` property.
    public var url: UIBindingObserver<Base, URL> {
        return UIBindingObserver(UIElement: self.base) { control, value in
            control.url = value
        }
    }
}
