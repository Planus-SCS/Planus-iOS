//
//  JoinedGroupDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

struct JoinedGroupDetailViewModelActions {
    var pop: (() -> Void)?
}

class JoinedGroupDetailViewModel {
    var bag = DisposeBag()
    var actions: JoinedGroupDetailViewModelActions?
    
    var groupTitle: String? = "가보자네카라쿠베베"
    var tag: String? = "#태그개수수수수 #네개까지지지지 #제한하는거다다\n#어때아무글자텍스트테스트 #오개까지아무글자텍스"
    var memberCount: String? = "1/4"
    var captin: String? = "기정이짱짱"
    
    struct Input {
    }
    
    struct Output {
    }

    init(
    ) {
    }
    
    func setActions(actions: JoinedGroupDetailViewModelActions) {
        self.actions = actions
    }
    
}
