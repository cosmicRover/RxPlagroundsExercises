import UIKit
import RxSwift
import RxCocoa

//MARK: Subscribing, disposing, creating Observables and 'just' operator
/**
 In Rx, you must subscribe to an observable sequence to receive values/events.
 Events can be values, error types and/or any other custom states that you configure.
 If a subscription to an observable encounters an Error/Completed event, the subscription
 is no longer active.
 
 Must terminate a subscription using a dispose bag or a 'takeUntil' operator
 to free up resources when a subscription is no longer needed. 'takeUntil' looks for other
 vars that will signal it to stop.
 
 Note that an event can be triggered after dispose has been called only if scheduler isn't
 a SerialScheduler and Dispose() is not being called on the same scheduler
 */

//let scheduler = SerialDispatchQueueScheduler(qos: .default)
let dispose_bag = DisposeBag()

//example of subscribing and disposing
//let subscription = Observable<Int>.interval(.milliseconds(100), scheduler: scheduler)
//    .observeOn(MainScheduler.instance)
//    .subscribe{
//        event in
//        print(event)
//    }
//subscription.disposed(by: dispose_bag)

/**When creating an observavble it is important to keep in mind that no work related to subscription will be
 taking place until specifically called to subscribe to an obseravable.
 
 In swift, there are lot of ways to create your own obseravable sequence. For example the easiest way
 would be to use 'just'. It only returns one element.
 */

//this type E func takes and element E and returns an observable for E
//func justExample<E>(_ element: E) -> Observable<E>{
//    return Observable.create{ observer in
//        observer.on(.next(element))
//        observer.on(.completed)
//        return Disposables.create()
//    }
//}
//
//justExample(1).subscribe(onNext: { (n) in
//    print("first example ",n)
//})

//can also be used to get elemnts from an array
//func justExample2<E>(_ sequence: [E]) -> Observable<E>{
//    return Observable.create{ observer in
//        for item in sequence{
//            observer.on(.next(item))
//        }
//        observer.on(.completed)
//        return Disposables.create()
//    }
//}
//
//justExample2([1, 2, 3, 4, 5, 6, 7, 8]).subscribe(onNext: { (n) in
//    print("second exapmle ",n)
//})

/** below an example of a fucntion that combines the above concepts to emmit values
 within a given timer
 */

func myInterval(_ interval: DispatchTimeInterval) -> Observable<Int>{
    return Observable.create{ observer in
        print("subscribed")
        
        //define how long we will perform the work of sequence generation
        let work_timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        work_timer.schedule(deadline: DispatchTime.now() + interval, repeating: interval)
        
        //defining vals to cancel work_timer later
        let cancel_work = Disposables.create{
            print("Disposed")
            work_timer.cancel()
        }
        
        var next_val = 0 //value to mutate
        
        //as long as work_timer isnt cancelled, there will be onNext() events
        work_timer.setEventHandler{
            if cancel_work.isDisposed{
                return
            }
            observer.on(.next(next_val))
            next_val += 1
        }
        work_timer.resume()
        
        return cancel_work
    }
}

//get the obserable
//let counter = myInterval(.milliseconds(100))
//
//print("Started ----")
//
////subscribe to onNext, can even call multiple times
//let subscription1 = counter
//    .subscribe(onNext: { n in
//        print("sub1 ",n)
//    })
//
//let subscription2 = counter
//.subscribe(onNext: { n in
//    print("sub2 ",n)
//})
//
////sleep for 0.5 seconds so the subscription can continue
//Thread.sleep(forTimeInterval: 0.5)
//
////dispose it afterwards manaully
//subscription1.dispose()
//subscription2.dispose()

//print("Ended ----")

//MARK: Sharing subscriptions and 'share' operator

/**What if you need multiple subscriptions from a single source and you need the subscribers to get the latest values
 from their one single source. Use 'share(replay: )' to achieve that. share(replay: Int) doesnt isolate themselves from their source
 and their will only be one subscribe event and one dispose event. Share always returns calculated results.
 */

//let counter = myInterval(.milliseconds(100)).share(replay: 1)
//
//print("started")
//
//let sub1 = counter.subscribe(onNext: {
//    n in
//    print("first ", n)
//})
//
//let sub2 = counter.subscribe(onNext: {
//    n in
//    print("second ", n)
//})
//
//Thread.sleep(forTimeInterval: 0.5)
//sub1.dispose()
//
////even after disposing sub1, sub2 can continue from the latest values emittex from source
//Thread.sleep(forTimeInterval: 0.5)
//sub2.dispose()
//
//print("ended")

//MARK: Operators and their usage. Visit the link to view a decision tree for operators http://reactivex.io/documentation/operators.html#tree

/*creating a custom operator here. creating operators are all about creating observables
 below is an example of an unoptimized map.
*/
extension ObservableType {
    
    /*myMap returns an observable of type result after it transforms it with some other inputs
    *first.
    */
    func myMap<Result>(transform: @escaping (Element) -> Result) -> Observable<Result> {
        //return an observable
        return Observable.create{observer in
            
            //emmit values based on events
            let sub = self.subscribe{e in
                switch e {
                case .next(let value):
                    let result = transform(value)
                    observer.on(.next(result))
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
            
            return sub
        }
    }
}

/**use that custom operator to do some work. This will simply print a number
incrementally every 1 second. Sometimes, it is too hard to solve something with Rx operators
 if that's the case, we can exit rX monad and call any regular functions:
 
 let match: Observable<ReactiveMatch> = beignMatch()
 
 match.subscribe(onNext: {value in
    self.doSomeRegularSwift()
 }).dispose(by: dispose_bag)
 
 It is recommended that we dont do this.
*/

//let sub = myInterval(.seconds(1))
//    .myMap{e in
//        return "this is simply \(e)" //using myMap to transform e using the custom string
//    }.subscribe(onNext: { value_from_myMap in
//        print("after calling myMap ", value_from_myMap) //printing everything here
//    })

//MARK: UI layer tips

/**
 Events data binding events must take place on the MainScheduler just as usual. Can't find any failures to any controls on the UI layer
 since it's an undefined behavior, but after an error, the underlying sequence will still complete (use retry operator). Always share subscriptions
 to reudce any extra work necessary to achieve your desired output. Using the share(replay: ) operator, we can get away with one subscribe/dispose for
 a collection of observables.
 */

//MARK: Fetch data from the internet

//define a URL, compose a request and make a request using URLSession.shared.rx.json(request)
//let req = URLRequest(url: URL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=Pizza&format=json")!)
//
//let response_JSON = URLSession.shared.rx.json(request: req)
//
//let get_request = response_JSON.subscribe(onNext:{ json in
//    print(json)
//})
//
//Thread.sleep(forTimeInterval: 0.5)
//get_request.dispose()

/**Can be used to get things such as status code as well with URLSession.shared.rx*/


//MARK: Trits, formerly known as Units
/**
 Single: Returns only one element or an error. Can be used in situation where you only need a val once such as performing a
 fetch from the internet once.
 */

enum ErrorState: Error{
    case CantParseData
    case ErrorOnDoingWork
    case MeaningOfLifeIsToComplex
}

//func fetchdata(_ repo: String) -> Single<[String:Any]>{
//
//    //returns a single http fetch request
//    return Single<[String:Any]>.create{single in
//        let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!){
//            data, _, error in
//
//            //push error value if error state encountered
//            if let error = error{
//                single(.error(error))
//            }
//
//            //unpack data and convert them into json onjects and then assign them to results
//            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves), let result = json as? [String:Any]
//            else{ //otherwise provide an error from error state
//                single(.error(ErrorState.CantParseData))
//                return
//            }
//
//            //return the json data on success
//            single(.success(result))
//        }
//        task.resume()
//
//        //sever conenction when task is done
//        return Disposables.create {
//            task.cancel()
//        }
//    }
//}
//
////subscribe to fetchData
//fetchdata("ReactiveX/RxSwift").subscribe{event in
//    switch event {
//    case .error(let error):
//        print(error.localizedDescription)
//    case .success(let json):
//        print(json)
//    }
//}.disposed(by: dispose_bag)

//MARK: Completeables.
/**
 Completeables are a variation of observables that can only complete or emit an error. It can emit any elements.
    -emits 0 elements
    -emits a completion event or an error
    -Doesnt share side effects
 */

//func doSomeContextualWork() -> Completable{
//    return Completable.create{ completable in
//        //do some work
//        let success = true
//        //...
//        //..
//        //.....
//        guard success else{
//            completable(.error(ErrorState.ErrorOnDoingWork))
//            return Disposables.create {}
//        }
//
//        completable(.completed)
//        return Disposables.create {}
//    }
//}
//
//doSomeContextualWork().subscribe{completable in
//    switch completable {
//    case .error(let error):
//        print(error.localizedDescription)
//    case .completed:
//        print("completeable is completed")
//    }
//}.disposed(by: dispose_bag)

//MARK: Maybe
/**
 A maybe is right between single and observable. It can emit an element, complete without emittinng or emit an error. Any one of these three events
 will terminate the maybe operator
    -Emits element, completed, error
    -Dosesnt share side effects
 */

func calculateMeaningOfLife() -> Maybe<Int>{
    return Maybe<Int>.create{ maybe in
        
        //do some meaningful work
        //...
        //..
        //.
        
        maybe(.success(42))
        
        maybe(.completed)
        
        maybe(.error(ErrorState.MeaningOfLifeIsToComplex))
        
        return Disposables.create {}
    }
}

calculateMeaningOfLife().subscribe{maybe in
    switch maybe {
    case .success(let value):
        print("meaning of life is \(value)")
    case .completed:
        print("calculation is complete")
    case .error(let error):
        print(error.localizedDescription)
    }
}.disposed(by: dispose_bag)


//MARK: RxCocoa traits

//MARK: Driver







