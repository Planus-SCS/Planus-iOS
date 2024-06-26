//
//  SceneDelegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let injector: Injector = DependencyInjector(container: Container())
    var appCoordinator: AppCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        guard let window = window else { return }

        configureInjector()
        self.appCoordinator = AppCoordinator(dependency: AppCoordinator.Dependency(window: window, injector: injector))
        checkUniversalLinkOpen(options: connectionOptions)
        
        self.appCoordinator?.start()
                
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        appCoordinator?.parseUniversalLink(url: url)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
       // Get URL components from the incoming user activity.
       guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
             let incomingURL = userActivity.webpageURL else {
           return
       }

        appCoordinator?.parseUniversalLink(url: incomingURL)
   }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
    // MARK: - 유니버셜 링크로 앱 연지 확인
    func checkUniversalLinkOpen(options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            appCoordinator?.appendActionAfterAutoSignIn { [weak self] in
                self?.appCoordinator?.parseUniversalLink(url: url)
            }
        }
    }
    
    func configureInjector() {
        injector.assemble([
            InfraAssembly(),
            DataAssembly(),
            DomainAssembly(),
            PresentationAssembly()
        ])
    }
}
