import SwiftUI
import GoogleSignIn

@main
struct GmailNotificationApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @State private var isAsked = false;
    
    private func fetchGmailDetail(){
        let previousUnreadCount = UserDefaults.standard.object(forKey: "UnreadCount") as? Int ?? 0
        let previousGmailId = UserDefaults.standard.object(forKey: "LastGmailId") as? String ?? ""
        let currentUnreadCount = appDelegate.gmailViewModel.unreadCount
        if (previousUnreadCount != currentUnreadCount){
            UserDefaults.standard.set(currentUnreadCount, forKey: "UnreadCount")
            if (currentUnreadCount > previousUnreadCount && appDelegate.gmailViewModel.id != "" && appDelegate.gmailViewModel.id != previousGmailId ){
                appDelegate.gmailViewModel.fetchNewestMail(id: appDelegate.gmailViewModel.id)
                UserDefaults.standard.set(appDelegate.gmailViewModel.id, forKey: "LastGmailId")
            }
        }
    }
    
    private func checkGmail(){
        Timer.scheduledTimer(withTimeInterval: Constants.getGmailInterval, repeats: true) { timer in
            if let _ = GIDSignIn.sharedInstance.currentUser {
                if !appDelegate.authViewModel.hasGmailReadScope {
                    if (!isAsked){
                        self.isAsked = true
                        appDelegate.authViewModel.addGmailReadScope {
                            appDelegate.gmailViewModel.fetchUnreadMails()
                            fetchGmailDetail()
                        }
                    }
                } else {
                    appDelegate.gmailViewModel.fetchUnreadMails()
                    fetchGmailDetail()
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.authViewModel)
                .environmentObject(appDelegate.userProfileImage)
                .environmentObject(appDelegate.gmailViewModel)
                .onAppear {
                    appDelegate.authViewModel.connectState = .isConnecting
                    
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let user = user {
                            appDelegate.authViewModel.state = .signedIn(user)
                            if let profile = user.profile {
                                appDelegate.userProfileImage.userFetchAvatar(userProfile: profile)
                            }
                            print("Is Signed In------------>", user)
                        } else if let error = error {
                            appDelegate.authViewModel.state = .restoredError
                            print("There was an error restoring the previous sign-in: \(error)")
                        } else {
                            appDelegate.authViewModel.state = .signedOut
                        }
                        
                        appDelegate.authViewModel.connectState = .idle
                    }
                    
                    checkGmail()
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    @State private var showingPopover = false
    
    // New StateObject must be added here !
    let authViewModel = AuthenticationViewModel()
    let userProfileImage = UserProfileImageLoader()
    let gmailViewModel = GmailViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        //NSApplication.shared.keyWindow?.close()
        NSApp.windows.first?.close()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "g.circle.fill", accessibilityDescription: "Gmail Notification")
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 210, height: 300)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(authViewModel).environmentObject(userProfileImage).environmentObject(gmailViewModel))
    }
    
    @objc func togglePopover(){
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}
