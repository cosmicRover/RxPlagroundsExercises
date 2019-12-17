//
//  ViewController.swift
//  RxSwift_Exercise
//
//  Created by Joy Paul on 12/12/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

//extension ObservableType {
//    func myMap<R>(transform: @escaping (E) -> R) -> Observable<R> {
//        return Observable.create { observer in
//            let subscription = self.subscribe { e in
//                    switch e {
//                    case .next(let value):
//                        let result = transform(value)
//                        observer.on(.next(result))
//                    case .error(let error):
//                        observer.on(.error(error))
//                    case .completed:
//                        observer.on(.completed)
//                    }
//                }
//
//            return subscription
//        }
//    }
//}

