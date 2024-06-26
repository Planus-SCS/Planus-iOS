//
//  SearchResultViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import Foundation
import RxSwift

final class SearchResultViewModel: ViewModelable {
    
    struct UseCases {
        let recentQueryRepository: RecentQueryRepository
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let fetchSearchResultUseCase: FetchSearchResultUseCase
        let fetchImageUseCase: FetchImageUseCase
    }
    
    struct Actions {
        var pop: (() -> Void)?
        var showGroupIntroducePage: ((Int) -> Void)?
        var showGroupCreatePage: (() -> Void)?
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let useCases: UseCases
    let actions: Actions
    
    var bag = DisposeBag()
        
    var history: [String] = []
    var result: [GroupSummary] = []
    
    var keyword = BehaviorSubject<String?>(value: nil)
    
    var isLoading: Bool = false
    var isInitLoading: Bool = false
    
    var didStartFetching = PublishSubject<Void>()
    var didFetchInitialResult = PublishSubject<Void>()
    var didFetchAdditionalResult = PublishSubject<Range<Int>>()
    var resultEnded = PublishSubject<Void>()
    var nonKeyword = PublishSubject<Void>()
    
    var didFetchHistory = BehaviorSubject<Void?>(value: nil)
    
    var page: Int = 0
    var size: Int = 10
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var tappedItemAt: Observable<Int>
        var tappedHistoryAt: Observable<Int>
        var refreshRequired: Observable<Void>
        var keywordChanged: Observable<String?>
        var searchBtnTapped: Observable<Void>
        var createBtnTapped: Observable<Void>
        var needLoadNextData: Observable<Void>
        var needFetchHistory: Observable<Void>
        var removeAllHistory: Observable<Void>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didStartFetching: Observable<Void>
        var didFetchInitialResult: Observable<Void>
        var didFetchAdditionalResult: Observable<Range<Int>>
        var resultEnded: Observable<Void>
        var keywordChanged: Observable<String?>
        var didFetchHistory: Observable<Void?>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
    }

    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchRecentQueries()
            })
            .disposed(by: bag)
        
        input
            .tappedItemAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let groupId = vm.result[index].groupId
                vm.actions.showGroupIntroducePage?(groupId)
            })
            .disposed(by: bag)
        
        input
            .tappedHistoryAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let keyword = vm.history[index]
                vm.keyword.onNext(keyword)
                vm.fetchInitialresult(keyword: keyword)
                
            })
            .disposed(by: bag)
        
        input
            .refreshRequired
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let keyword = try? vm.keyword.value(),
                      !keyword.isEmpty else {
                    return
                }
                vm.fetchInitialresult(keyword: keyword)
                
            })
            .disposed(by: bag)
        
        input
            .keywordChanged
            .distinctUntilChanged()
            .bind(to: keyword)
            .disposed(by: bag)
        
        input.searchBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let keyword = try? vm.keyword.value(),
                      !keyword.isEmpty else {
                    return
                }
                vm.fetchInitialresult(keyword: keyword)
                
            })
            .disposed(by: bag)
        
        input.createBtnTapped
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.showGroupCreatePage?()
            })
            .disposed(by: bag)

        input.needLoadNextData
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let keyword = try? vm.keyword.value(),
                      !keyword.isEmpty else {
                    return
                }
                vm.fetchResult(keyword: keyword, isInitial: false)
            })
            .disposed(by: bag)
        
        input
            .needFetchHistory
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchRecentQueries()
            })
            .disposed(by: bag)
        
        input
            .removeAllHistory
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.removeAllQueries()
                vm.history.removeAll()
                vm.didFetchHistory.onNext(())
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        return Output(
            didStartFetching: didStartFetching.asObservable(),
            didFetchInitialResult: didFetchInitialResult.asObservable(),
            didFetchAdditionalResult: didFetchAdditionalResult.asObservable(),
            resultEnded: resultEnded.asObservable(),
            keywordChanged: keyword.asObservable(),
            didFetchHistory: didFetchHistory.asObservable()
        )
    }
}

// MARK: History Query
extension SearchResultViewModel {
    func removeHistoryAt(item: Int) {
        removeRecentQuery(keyword: history[item])
        history.remove(at: item)
        didFetchHistory.onNext(())
    }
    
    func fetchRecentQueries() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let queryList = try? self.useCases.recentQueryRepository
                .fetchRecentsQueries()
                .map { $0.keyword }
                .compactMap { $0 }
            guard let queryList else { return }
            self.history = queryList
            self.didFetchHistory.onNext(())
        }
    }
    
    func saveRecentQuery(keyword: String) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            try? self.useCases.recentQueryRepository.saveRecentsQuery(query: RecentSearchQuery(date: Date(), keyword: keyword))
        }
    }
    
    func removeRecentQuery(keyword: String) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            try? self.useCases.recentQueryRepository.removeQuery(keyword: keyword)
        }
    }
    
    func removeAllQueries() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            try? self.useCases.recentQueryRepository.removeAllQueries()
        }
    }
}

// MARK: Fetch
extension SearchResultViewModel {
    func fetchInitialresult(keyword: String) {
        saveRecentQuery(keyword: keyword)
        isInitLoading = true
        didStartFetching.onNext(())
        page = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.fetchResult(keyword: keyword, isInitial: true)
        })
    }
    
    func fetchResult(keyword: String, isInitial: Bool) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchSearchResultUseCase
                    .execute(
                        token: token,
                        keyWord: keyword,
                        page: self?.page ?? Int(),
                        size: self?.size ?? Int()
                    )
            }
            .subscribe(onSuccess: { [weak self] list in
                guard let self else { return }

                if isInitial {
                    self.result = list
                    self.isInitLoading = false
                    self.didFetchInitialResult.onNext(())
                } else {
                    self.result += list
                    self.didFetchAdditionalResult.onNext((self.page * self.size..<self.page * self.size+list.count))
                }
                if list.count != self.size {
                    self.resultEnded.onNext(())
                }
                self.page += 1
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
}
