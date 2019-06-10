//
//  ASTableNode+Rx.swift
//  Pods-RxTexture_Example
//
//  Created by Andreas Östman on 2018-03-06.
//


import RxCocoa.Swift
import RxSwift.Swift
import AsyncDisplayKit

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

extension Reactive where Base: ASTableNode {
    
    /// Reactive wrapper for `contentOffset`.
    public var contentOffset: ControlProperty<CGPoint> {
        let proxy = RxTextureTableNodeDelegateProxy.proxy(for: base)
        
        let bindingObserver = Binder(self.base) { node, contentOffset in
            node.contentOffset = contentOffset
        }
        
        return ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
    }
    
    /// Reactive wrapper for `reachedBottom`.
    public var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let node = base else {
                    return Observable.empty()
                }
                
                let visibleHeight = node.frame.height - node.contentInset.top - node.contentInset.bottom
                let y = contentOffset.y + node.contentInset.top
                
                let threshold = max(0.0, node.view.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just(()) : Observable.empty()
        }
        
        return ControlEvent(events: observable)
    }

    /// Reactive wrapper for `itemSelected`
    public var itemSelected: ControlEvent<IndexPath> {
        let proxy = RxTextureTableNodeDelegateProxy.proxy(for: base)
        let source = proxy.methodInvoked(#selector(ASTableDelegate.tableNode(_:didSelectRowAt:))).map{ params in
            return try castOrThrow(IndexPath.self, params[1])
        }
        return ControlEvent(events: source)
    }
}
    
    extension ASTableNode: HasDelegate {
        public typealias Delegate = ASTableDelegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open class RxTextureTableNodeDelegateProxy
        : DelegateProxy<ASTableNode, ASTableDelegate>
        , DelegateProxyType
    , ASTableDelegate {
        
        /// Typed parent object.
        public weak private(set) var node: ASTableNode?
        
        /// - parameter scrollView: Parent object for delegate proxy.
        public init(tableNode: ParentObject) {
            self.node = tableNode
            super.init(parentObject: tableNode, delegateProxy: RxTextureTableNodeDelegateProxy.self)
        }
        
        // Register known implementations
        public static func registerKnownImplementations() {
            self.register { RxTextureTableNodeDelegateProxy(tableNode: $0) }
        }
        
        fileprivate var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
        fileprivate var _contentOffsetPublishSubject: PublishSubject<()>?
        fileprivate var _itemSelectedPublishSubject: PublishSubject<IndexPath>?
        
        internal var itemSelectedPublishSubject: PublishSubject<IndexPath> {
            if let subject = _itemSelectedPublishSubject {
                return subject
            }
            let subject = PublishSubject<IndexPath>()
            _itemSelectedPublishSubject = subject
            return subject
        }
        
        /// Optimized version used for observing content offset changes.
        internal var contentOffsetBehaviorSubject: BehaviorSubject<CGPoint> {
            if let subject = _contentOffsetBehaviorSubject {
                return subject
            }
            
            let subject = BehaviorSubject<CGPoint>(value: self.node?.contentOffset ?? CGPoint.zero)
            _contentOffsetBehaviorSubject = subject
            
            return subject
        }
        
        /// Optimized version used for observing content offset changes.
        internal var contentOffsetPublishSubject: PublishSubject<()> {
            if let subject = _contentOffsetPublishSubject {
                return subject
            }
            
            let subject = PublishSubject<()>()
            _contentOffsetPublishSubject = subject
            
            return subject
        }
        
        public func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
            itemSelectedPublishSubject.on(.next(indexPath))
            if forwardToDelegate()?.responds(to: #selector(ASTableDelegate.tableNode(_:didSelectRowAt:))) == true {
                self._forwardToDelegate?.tableNode(tableNode, didSelectRowAt: indexPath)
            }
        }
        
        /// For more information take a look at `DelegateProxyType`.
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if let subject = _contentOffsetBehaviorSubject {
                subject.on(.next(scrollView.contentOffset))
            }
            if let subject = _contentOffsetPublishSubject {
                subject.on(.next(()))
            }
            self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
        }
        
        
        public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            return self._forwardToDelegate?.tableView?(tableView, editActionsForRowAt: indexPath)
        }
        
        deinit {
            if let subject = _contentOffsetBehaviorSubject {
                subject.on(.completed)
            }
            
            if let subject = _contentOffsetPublishSubject {
                subject.on(.completed)
            }
            if let subject = _itemSelectedPublishSubject {
                subject.on(.completed)
            }
        }
}

