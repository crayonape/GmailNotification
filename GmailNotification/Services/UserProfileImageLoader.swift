import Combine
import GoogleSignIn

final class UserProfileImageLoader: ObservableObject {
    private var userProfile: GIDProfileData?
    private let imageLoaderQueue = DispatchQueue(label: "com.crayonape.gmail-notification")
    
    @Published var image = NSImage(systemSymbolName: "person.circle", accessibilityDescription: nil)!
    
    init() {
        self.userProfile = nil
    }
    
    private func fetchAvatar(){
        guard let _ =  userProfile?.hasImage else {
            return
        }
        
        imageLoaderQueue.async {
            guard let url = self.userProfile?.imageURL(withDimension: UInt(120)),
                  let data = try? Data(contentsOf: url),
                  let image = NSImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    public func userFetchAvatar(userProfile: GIDProfileData){
        self.userProfile = userProfile
        fetchAvatar()
    }
}
