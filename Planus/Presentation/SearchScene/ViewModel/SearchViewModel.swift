//
//  SearchViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import Foundation
import RxSwift

class SearchViewModel {
    
    var bag = DisposeBag()
    
    var result: [GroupSearchResultViewModel] = [
        GroupSearchResultViewModel(title: "네카라쿠베가보자",imageName: "groupTest1", tag: "#취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발", memCount: "1/2121212121212", captin: "이상민1ddfdfdfdfdfdfdf"),
        GroupSearchResultViewModel(title: "당토직야도가야지",imageName: "groupTest2", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민2"),
        GroupSearchResultViewModel(title: "안갈거야??",imageName: "groupTest3", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "1/2", captin: "이상민3"),
        GroupSearchResultViewModel(title: "취업해야지?",imageName: "groupTest4", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민4")
    ]
    
    var keyword = BehaviorSubject<String?>(value: nil)
    
    var fetchResultProcessing = BehaviorSubject<Void?>(value: nil)
    var didFinishFetchResult = BehaviorSubject<Void?>(value: nil)
    var didAddResult = PublishSubject<Int>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var tappedItemAt: Observable<Int>
        var refreshRequired: Observable<Void>
        var keywordChanged: Observable<String?>
        var searchBtnTapped: Observable<Void>
    }
    
    struct Output {
        var fetchResultProcessing: Observable<Void?>
        var didFinishFetchResult: Observable<Void?>
        var didAddResult: Observable<Int> //amount를 전달해서 insert
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                /*
                 여기서 이제 최초로 받아올 놈들을 가져오면 된다
                 */
                vm.fetchSearchResult(from: 0, amount: 0)
            })
            .disposed(by: bag)
        
        input
            .tappedItemAt
            .subscribe(onNext: { index in
                print(index)
            })
            .disposed(by: bag)
        
        input
            .refreshRequired
            .subscribe(onNext: {
                print("refresh required!")
            })
            .disposed(by: bag)
        
        input
            .keywordChanged
            .bind(to: keyword)
            .disposed(by: bag)
        
        input.searchBtnTapped
            .subscribe(onNext: {
                print("tap!")
            })
            .disposed(by: bag)
        
        
        return Output(
            fetchResultProcessing: fetchResultProcessing.asObservable(),
            didFinishFetchResult: didFinishFetchResult.asObservable(),
            didAddResult: didAddResult.asObservable()
        )
    }
    
    func fetchSearchResult(from: Int, amount: Int) { //나중에 페이지네이션 생각해서 from amount 추가
        didFinishFetchResult.onNext(())
    }
}
