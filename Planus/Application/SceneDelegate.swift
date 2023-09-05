//
//  SceneDelegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        guard let window = window else { return }

        self.appCoordinator = AppCoordinator(window: window)
        // Custom Link
        if let url = connectionOptions.urlContexts.first?.url {
            appCoordinator?.appendActionAfterAutoSignIn { [weak self] in
                self?.parseUniversalLink(url: url)
            }
            return
        }
     
        // Universal Link를 통해 앱이 실행된 경우
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            appCoordinator?.appendActionAfterAutoSignIn { [weak self] in
                self?.parseUniversalLink(url: url)
            }
        }
        
        self.appCoordinator?.start()
                
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        parseUniversalLink(url: url)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
       // Get URL components from the incoming user activity.
       guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
             let incomingURL = userActivity.webpageURL else {
           return
       }
        //이거를 바로 실행? 아니면 애도 로그인 안되있으면 확인?
        parseUniversalLink(url: incomingURL)
   }
    
    func parseUniversalLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let paths = components.path.split(separator: "/")

        switch paths.first {
        case "groups":

            guard let groupIdString = components.queryItems?.first(where: { $0.name == "groupID"})?.value,
            let groupId = Int(groupIdString) else { return }
            
            let mainTabCoordinator = appCoordinator?.childCoordinators.first(where: { $0 is MainTabCoordinator }) as? MainTabCoordinator
            mainTabCoordinator?.setTabBarControllerPage(page: .search)
            let searchCoordinator = mainTabCoordinator?.childCoordinators.first(where: { $0 is SearchCoordinator }) as? SearchCoordinator
            searchCoordinator?.showGroupIntroducePage(groupId)
        default: break
        }
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

