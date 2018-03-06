//
//  ASColletionNode.swift
//  Pods-RxTexture_Example
//
//  Created by Andreas Östman on 2018-03-06.
//

import RxCocoa.Swift
import RxSwift.Swift
import AsyncDisplayKit

extension Reactive where Base: ASCollectionNode {
    
    /// Reactive wrapper for `contentOffset`.
    public var contentOffset: ControlProperty<CGPoint> {
        let proxy = RxTextureCollectionNodeDelegateProxy.proxy(for: base)
        
        let bindingObserver = Binder(self.base) { node, contentOffset in
            node.contentOffset = contentOffset
        }
        
        return ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
    }
    
    var reachedBottom: ControlEvent<Void> {
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
}

    extension ASCollectionNode: HasDelegate {
        public typealias Delegate = ASCollectionDelegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open class RxTextureCollectionNodeDelegateProxy
        : DelegateProxy<ASCollectionNode, ASCollectionDelegate>
        , DelegateProxyType
    , ASCollectionDelegate {
        
        /// Typed parent object.
        public weak private(set) var node: ASCollectionNode?
        
        /// - parameter scrollView: Parent object for delegate proxy.
        public init(collectionNode: ParentObject) {
            self.node = collectionNode
            super.init(parentObject: collectionNode, delegateProxy: RxTextureCollectionNodeDelegateProxy.self)
        }
        
        // Register known implementations
        public static func registerKnownImplementations() {
            self.register { RxTextureCollectionNodeDelegateProxy(collectionNode: $0) }
        }
        
        fileprivate var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
        fileprivate var _contentOffsetPublishSubject: PublishSubject<()>?
        
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
        
        // MARK: delegate methods
        
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
        
        deinit {
            if let subject = _contentOffsetBehaviorSubject {
                subject.on(.completed)
            }
            
            if let subject = _contentOffsetPublishSubject {
                subject.on(.completed)
            }
        }
    }

