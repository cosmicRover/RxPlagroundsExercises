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
    
    /**Constants*/
    let text:UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 210, width: 250, height: 30))
//    let tableView = UITableView(frame: CGRect(x: 0, y: 250, width: 300, height: 300))
    let disposeBag = DisposeBag()
    
    enum ErrorState: Error {
        case DefaultError
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(text)
        view.addSubview(label)
//        view.addSubview(tableView)
        label.backgroundColor = UIColor.gray
        text.backgroundColor = UIColor.gray
        bindUIElements()
    }
    
    //MARK: Driver
    /**Bind the UI elemnts using rx note that no need to extend any delegate properties*/
    func bindUIElements(){
        let result = text.rx.text.asDriver()
            .throttle(.milliseconds(800)) //adds artificail delays before performing work
            .flatMapLatest{
                query in
                self.perfomrWork(query)
                .asDriver(onErrorJustReturn: "An error occoured") //in case of an error, return. This is a short way to make sure:
                                                                    /*
                                                                    .observeOn(MainScheduler.instance)        observe events on main scheduler
                                                                    .catchErrorJustReturn(onErrorJustReturn)  can't error out
                                                                    .share(replay: 1, scope: .whileConnected) side effects sharing
                                                                    The 3 criterias that are needed to satisfy asDriver
                                                                    */
        }
        
        result
            .map{"\($0?.count ?? 42)"}
            .drive(label.rx.text) // if this drive method is available instead of bind to, all the requirements had been satisfied
            .disposed(by: disposeBag)
    }
    
    /**a func that returns an observavble of elements from the text field. It returns three sattes*/
    func perfomrWork<E>(_ element: E) -> Observable<E>{
        return Observable.create{ observer in
            observer.on(.next(element))
            observer.on(.completed)
            observer.on(.error(ErrorState.DefaultError))
            return Disposables.create()
        }
    }

}

//MARK: Signal

/**A signal is similar to driver but it doesn't replay the latest event on subscription, but still shares the computational resources
 A signal
    - cant error out
    - delivers on main scheduler
    - doesnt replay elements on subscription
    - shares computational resources
 */

//MARK: ControlProperty/ControlEvent

//https://github.com/ReactiveX/RxSwift for code info on UI elements

/** A control property init control value of an UI element, and any user initiated value changes afterwards. Typical use cases involve UI components such as UISearchBar
 and UISegmentedControl.
 
    - never fails
    - share(replay: 1) behavior. Upon subscription, last item is immediately replayed
    - its completed once deallocated
    - delivers on main scheduler
 
 A control event dictates an event that occours on an UI element. Events such as a tap, loading a new page.
 
    - never fails
    - doesnt send any initial value on subscription
    - completes sequence once deallocated
    - never produces an error
    - runs on main scheduler
 */

//Be sure to check out the testing!

