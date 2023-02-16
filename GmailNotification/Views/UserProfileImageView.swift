import SwiftUI
import GoogleSignIn

struct UserProfileImageView: View {
    @EnvironmentObject var userProfileImage: UserProfileImageLoader
    private var theme: Int
    
    init(theme: Int){
        self.theme = theme
    }
    
    var body: some View {
        Button{
            if let profile = GIDSignIn.sharedInstance.currentUser?.profile {
                userProfileImage.userFetchAvatar(userProfile: profile)
            }
        } label: {
            Image(nsImage: userProfileImage.image)
                .resizable()
                .background(theme == 1 ? .gray : .white)
                .frame(width: CGFloat(Constants.avatarSize), height: CGFloat(Constants.avatarSize), alignment: .center)
                .clipShape(Circle())
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
