import Firebase
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        #if DEBUG
        // 開発中はAppCheckを無効化
        print("DEBUG: AppCheck is disabled for development")
        #else
        if #available(iOS 14.0, *) {
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        #endif
        
        return true
    }
}
