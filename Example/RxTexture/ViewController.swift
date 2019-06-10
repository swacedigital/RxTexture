//
//  ViewController.swift
//  RxTexture
//
//  Created by andreasostman on 01/17/2018.
//  Copyright (c) 2018 andreasostman. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Texture

class ViewController: UIViewController {
    
    private lazy var list = ASTableNode()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        list.rx.itemSelected
            .subscribe(onNext: { print("Item was selected: ", $0) })
            .disposed(by: disposeBag)
    }
}

