import Firebase
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if #available(iOS 14.0, *) {
            // AppCheck のデバッグプロバイダを使用（開発環境のみ）
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        
        return true
    }
}
