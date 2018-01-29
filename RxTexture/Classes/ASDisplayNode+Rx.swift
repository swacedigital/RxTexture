//
//  ASDisplayNode+Rx.swift
//  Alamofire
//
//  Created by Andreas Östman on 2018-01-27.
//

import Foundation
import RxCocoa
import RxSwift
import AsyncDisplayKit

extension Reactive where Base: ASDisplayNode {

    public var visible: Binder<Bool> {
        return Binder(self.base) { node, value in
            node.isHidden = !value
        }
    }
}
