//
//  SearchViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import Foundation
import RxSwift

struct SearchViewModelActions {
    var showSearchResultPage: ((String) -> Void)?
    var showGroupIntroducePage: ((Int) -> Void)?
    var showGroupCreatePage: (() -> Void)?
}

class SearchViewModel {
    
    var bag = DisposeBag()
    
    var actions: SearchViewModelActions?
    
    var result: [GroupSearchResultViewModel] = [
        GroupSearchResultViewModel(id: 1, title: "네카라쿠베가보자",imageName: "groupTest1", tag: "#취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발", memCount: "1/2121212121212", captin: "이상민1ddfdfdfdfdfdfdf"),
        GroupSearchResultViewModel(id: 2, title: "당토직야도가야지",imageName: "groupTest2", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민2"),
        GroupSearchResultViewModel(id: 3, title: "우끼끼",imageName: "groupTest3", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "1/2", captin: "이상민3"),
        GroupSearchResultViewModel(id: 4, title: "에헤헤",imageName: "groupTest4", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민4"),
        GroupSearchResultViewModel(id: 5, title: "이히히",imageName: "groupTest1", tag: "#취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발", memCount: "1/2121212121212", captin: "이상민5"),
        GroupSearchResultViewModel(id: 6, title: "우히히",imageName: "groupTest2", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민6"),
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
        var createBtnTapped: Observable<Void>
    }
    
    struct Output {
        var fetchResultProcessing: Observable<Void?>
        var didFinishFetchResult: Observable<Void?>
        var didAddResult: Observable<Int> //amount를 전달해서 insert
    }
    
    func setActions(actions: SearchViewModelActions) {
        self.actions = actions
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
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let groupId = vm.result[index].id
                vm.actions?.showGroupIntroducePage?(groupId)
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
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let keyword = try? vm.keyword.value() else { return }
                vm.actions?.showSearchResultPage?(keyword)
            })
            .disposed(by: bag)
        
        input.createBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions?.showGroupCreatePage?()
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
