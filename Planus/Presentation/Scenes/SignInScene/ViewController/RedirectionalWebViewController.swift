//
//  RedirectionalWebViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit
import RxSwift
import WebKit

final class RedirectionalWebViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var didSent = false
    
    var nowForeground = BehaviorSubject<Bool>(value: true)
    var code = BehaviorSubject<String?>(value: nil)
    var didFetchedCode = PublishSubject<String>()
    
    var viewModel: RedirectionalWebViewModel?
    
    var webView: WKWebView?
    
    convenience init(viewModel: RedirectionalWebViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        startWebView()
        
        bindAppStateObservable()
    }
}

// MARK: View Generator
private extension RedirectionalWebViewController {
    func bindAppStateObservable() {
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .asDriver(onErrorRecover: { _ in .never() })
            .drive(onNext: { [weak self] _ in
                self?.nowForeground.onNext(true)
            })
            .disposed(by: bag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .asDriver(onErrorRecover: { _ in .never() })
            .drive(onNext: { [weak self] _ in
                self?.nowForeground.onNext(false)
            })
            .disposed(by: bag)
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
                vc.dismiss(animated: true, completion: {
                    vc.terminateWebView()
                })
            })
            .disposed(by: bag)
        
        Observable
            .combineLatest(nowForeground.asObservable(), code.compactMap { $0 })
            .withUnretained(self)
            .subscribe(onNext: { vc, args in
                let (nowForeground, code) = args
                if nowForeground {
                    vc.didFetchedCode.onNext(code)
                }
            })
            .disposed(by: bag)
    }
}

// MARK: Actions
private extension RedirectionalWebViewController {
    func startWebView() {
        let webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.customUserAgent = WebViewCustomUserAgent.userAgent
        self.view.addSubview(webView)
        self.webView = webView
        
        guard let viewModel else { return }
        
        if let url = URL(string: viewModel.type.requestURL) {
            let request = URLRequest(url: url)
            DispatchQueue.main.async {
                webView.load(request)
            }
        }
    }
    
    func terminateWebView() {
        webView?.removeFromSuperview()
        webView = nil
    }
}

extension RedirectionalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let viewModel,
              let redirectURL = URL(string: viewModel.type.redirectionURI) else { return }

        if let url = navigationAction.request.url,
           let scheme = url.scheme,
           viewModel.type.URLSchemes.contains(scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let appId = viewModel.type.storeAppId {
                    UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/" + appId)!, options: [:], completionHandler: nil)
                }
            }
            
            
            decisionHandler(.cancel)
            
            return
        }

        else if let url = navigationAction.request.url,
                url.host == redirectURL.host,
                url.port == redirectURL.port,
                url.path == redirectURL.path {
            
            guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
            if let code = url.queryItems?.filter({ $0.name == "code" }).first?.value {
                self.code.onNext(code)
            }
            decisionHandler(.cancel)
            
            return
        }
        
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {}
}
