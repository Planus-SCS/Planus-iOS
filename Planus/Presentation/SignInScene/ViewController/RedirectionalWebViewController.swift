//
//  RedirectionalWebViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit
import RxSwift
import WebKit

class RedirectionalWebViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var viewModel: RedirectionalWebViewModel?
    
    var didFetchedCode = PublishSubject<String>()
    
    var webView = WKWebView()
    
    convenience init(viewModel: RedirectionalWebViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        startWebView()
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = RedirectionalWebViewModel.Input(
            didFetchedCode: didFetchedCode.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .needDismiss
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
    
    func startWebView() {
        self.webView.navigationDelegate = self
        guard let viewModel else { return }
        
        if let url = URL(string: viewModel.type.requestURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension RedirectionalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let viewModel,
              let redirectURL = URL(string: viewModel.type.redirectionURI) else { return }
        
        if let url = navigationAction.request.url,
           url.host == redirectURL.host,
           url.port == redirectURL.port,
           url.path == redirectURL.path {

            guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let code = url.queryItems?.filter({ $0.name == "code" }).first?.value else { return }
            
            self.didFetchedCode.onNext(code)
            decisionHandler(.cancel)
            self.dismiss(animated: true)
        } else {
            decisionHandler(.allow)
        }
    }
}
