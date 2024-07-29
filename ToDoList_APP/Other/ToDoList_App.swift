import SwiftUI
import Firebase

@main
struct ToDoList_App: App {
    // AppDelegateのプロトコルに準拠したクラスを追加
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
