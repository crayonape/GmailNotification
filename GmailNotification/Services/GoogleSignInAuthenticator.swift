import GoogleSignIn

final class GoogleSignInAuthenticator: ObservableObject {
    private var authViewModel: AuthenticationViewModel
    
    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
    }
    
    func signIn(completion: @escaping (GIDProfileData) -> Void) {
        guard let presentingWindow = NSApplication.shared.windows.first else {
            print("There is no presenting window!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow) { signInResult, error in
            NSApplication.shared.keyWindow?.close()
            
            self.authViewModel.connectState = .idle
            guard let signInResult = signInResult else {
                return
            }

            self.authViewModel.state = .signedIn(signInResult.user)
            if let profile = signInResult.user.profile {
                completion(profile)
            }
            
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        authViewModel.state = .signedOut
    }
    
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Encountered error disconnecting scope: \(error).")
            }
            self.signOut()
        }
    }
    
    func addGmailReadScope(completion: @escaping () -> Void) {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            print("No user signed in!")
            return
        }
        
        guard let presentingWindow = NSApplication.shared.windows.first else {
            print("No presenting window!")
            return
        }
        
        currentUser.addScopes([GmailLoader.gmailReadScope],presenting: presentingWindow) { signInResult, error in
            if let error = error {
                print("Found error while adding gmail read scope: \(error).")
                return
            }
            
            guard let signInResult = signInResult else { return }
            self.authViewModel.state = .signedIn(signInResult.user)
            completion()
        }
    }
}
