import SwiftUI
import GoogleSignIn
import Combine

struct DashBoardView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileImage: UserProfileImageLoader
    @EnvironmentObject var gmailViewModel: GmailViewModel

    @State var theme: Int
    
    init(){
        theme = UserDefaults.standard.object(forKey: "Theme") as? Int ?? 0
    }
    
    private func reactiveText() ->Text{
        var color: Color
        switch authViewModel.state {
        case .signedIn:
            color = .green
        case .restoredError:
            color = .yellow
        default:
            color = .red
        }
        
        return Text("G")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(color)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0){
                reactiveText()
                
                Text("mail Notification")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme == 1 ? .white : .black)
                
                Button{
                    theme = 1 - theme
                    UserDefaults.standard.set(theme, forKey: "Theme")
                } label: {
                    Image(systemName: "moon.circle" )
                        .resizable()
                        .background(theme == 1 ? .gray : .white)
                        .clipShape(Circle())
                        .frame(width: 15,height: 15)
                    
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.leading, 5)
                
                Spacer()
                
                Button{
                    let url = URL(string: Constants.gmailUrl)!
                    NSWorkspace.shared.open(url)
                } label: {
                    Image(systemName: "envelope.circle")
                        .resizable()
                        .background(theme == 1 ? .gray : .white)
                        .clipShape(Circle())
                        .frame(width: 20,height: 20)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            Divider()
                .overlay(.gray)
            
            MailInfoView(theme: theme)
            
            Divider()
                .overlay(.gray)
            
            HStack{
                Button{
                    gmailViewModel.unreadCount = 0
                    UserDefaults.standard.set(0, forKey: "UnreadCount")
                    authViewModel.signOut()
                    authViewModel.connectState = .isConnecting
                    authViewModel.signIn(completion: { userProfile in
                        userProfileImage.userFetchAvatar(userProfile: userProfile)
                    })
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .background(theme == 1 ? .gray : .white)
                        .clipShape(Circle())
                        .frame(width: 15,height: 15)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                if (authViewModel.connectState == .isConnecting){
                    ConnecAnimationView(theme: theme)
                } else {
                    Button{
                        let url = URL(string: Constants.githubUrl)!
                        NSWorkspace.shared.open(url)
                    } label: {
                        Image(systemName: "ant.circle")
                            .resizable()
                            .background(theme == 1 ? .gray : .white)
                            .clipShape(Circle())
                            .frame(width: 15,height: 15)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                Spacer()
                
                Button{
                    exit(0)
                } label: {
                    Image(systemName: "arrow.backward.circle")
                        .resizable()
                        .background(theme == 1 ? .gray : .white)
                        .clipShape(Circle())
                        .frame(width: 15,height: 15)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .frame(height: 15)
        }
        .frame(width: 200)
        .padding(10)
        .background(theme == 0 ? .white : .black)
    }
}
