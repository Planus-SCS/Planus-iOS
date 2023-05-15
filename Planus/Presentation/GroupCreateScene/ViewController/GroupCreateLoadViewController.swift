//
//  GroupCreateLoadViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import UIKit
import RxSwift

class GroupCreateLoadViewController: UIViewController {
    var bag = DisposeBag()
    var viewModel: GroupCreateLoadViewModel?
    
    var idx = 0
    var messageList: [String] = [
        "그룹을 생성 중이에요",
        "조금만 기다려 주세요"
    ]
    
    var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyResultLogo"))
        return imageView
    }()
    
    var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹을 생성 중이에요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
        label.textAlignment = .center
        return label
    }()
    
    var spinner = UIActivityIndicatorView(style: .gray)
    
    var timer: Timer?
    
    convenience init(viewModel: GroupCreateLoadViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureLayout()
        
        start()
        bind()
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let output = viewModel.transform(input: GroupCreateLoadViewModel.Input(viewDidLoad: Observable.just(())))
        
        output
            .didCreateGroup
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, groupId in
                vc.stop()
                guard let navi = vc.navigationController else { return }

                let api = NetworkManager()
                let keyChain = KeyChainManager()
                let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
                let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
                let imageRepo = DefaultImageRepository(apiProvider: api)
                let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
                let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
                let fetchMyGroupDetailUseCase = DefaultFetchMyGroupDetailUseCase(myGroupRepository: myGroupRepo)
                let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
                let setOnlineStateUseCase = DefaultSetOnlineUseCase.shared
                let myGroupDetailVM = JoinedGroupDetailViewModel(
                    getTokenUseCase: getTokenUseCase,
                    refreshTokenUseCase: refreshTokenUseCase,
                    fetchMyGroupDetailUseCase: fetchMyGroupDetailUseCase,
                    fetchImageUseCase: fetchImageUseCase,
                    setOnlineUseCase: setOnlineStateUseCase,
                    updateNoticeUseCase: DefaultUpdateNoticeUseCase.shared
                )
                myGroupDetailVM.setGroupId(id: groupId)
                myGroupDetailVM.setActions(actions: JoinedGroupDetailViewModelActions(pop: {
                    navi.popViewController(animated: true)
                }))
                let myGroupDetailVC = JoinedGroupDetailViewController(viewModel: myGroupDetailVM)
                
                var children = navi.viewControllers
                children.removeAll(where: { childVC in
                    switch childVC {
                    case is GroupCreateViewController:
                        return true
                    case is GroupCreateLoadViewController:
                        return true
                    default:
                        return false
                    }
                })
                children.append(myGroupDetailVC)
                
                navi.setViewControllers(children, animated: true)

            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(logoImageView)
        self.view.addSubview(spinner)
        self.view.addSubview(messageLabel)

    }
    
    func configureLayout() {
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        spinner.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(spinner.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview().inset(50)
        }
    }
    
    func start() {
        spinner.startAnimating()
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(refreshLabel), userInfo: nil, repeats: true)
    }
    
    func stop() {
        spinner.stopAnimating()
        self.timer?.invalidate()
    }
    
    @objc func refreshLabel() {
        idx = (idx+1)%messageList.count
        messageLabel.text = messageList[idx]
        messageLabel.sizeToFit()
    }
}
