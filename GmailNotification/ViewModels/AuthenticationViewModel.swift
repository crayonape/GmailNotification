import GoogleSignIn

final class AuthenticationViewModel: ObservableObject {
    @Published var state: State
    @Published var connectState: ConnectState
    
    private var authenticator: GoogleSignInAuthenticator {
        return GoogleSignInAuthenticator(authViewModel: self)
    }
    
    init() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            self.state = .signedIn(user)
        } else {
            self.state = .signedOut
        }
        self.connectState = .idle
    }
    
    var authorizedScopes: [String] {
        switch state {
        case .signedIn(let user):
            return user.grantedScopes ?? []
        //case .signedOut:
        default:
            return []
        }
    }
    
    func signIn(completion: @escaping (GIDProfileData) -> Void) {
        authenticator.signIn(completion: completion)
    }
    
    func signOut() {
        authenticator.signOut()
    }
    
    func disconnect() {
        authenticator.disconnect()
    }
    
    var hasGmailReadScope: Bool {
        return authorizedScopes.contains(GmailLoader.gmailReadScope)
    }
    
    func addGmailReadScope(completion: @escaping () -> Void) {
        authenticator.addGmailReadScope(completion: completion)
    }
}

extension AuthenticationViewModel {
    enum State {
        case signedIn(GIDGoogleUser)
        case signedOut
        case restoredError
    }
}

extension AuthenticationViewModel {
    enum ConnectState {
        case idle
        case isConnecting
    }
}
