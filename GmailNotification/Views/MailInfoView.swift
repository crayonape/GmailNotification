import SwiftUI
import GoogleSignIn

struct MailInfoView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var gmailViewModel: GmailViewModel
    
    var theme: Int
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        return Group {
            if let userProfile = user?.profile {
                HStack{
                    UserProfileImageView(theme: theme)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(spacing: 2){
                            Spacer()
                            
                            Text(userProfile.name)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .truncationMode(.tail)
                                .frame(height: 16)
                                .foregroundColor(theme == 1 ? .white : .black)
                            
                            Text(" \(gmailViewModel.unreadCount) ")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                                .frame(height: 16)
                                .background(gmailViewModel.receivedStatus == .ReceivedOk ? .green : .red)
                                .foregroundColor(.white)
                                .cornerRadius(3)
                        }
                        .frame(width: 150)
                        
                        Text(userProfile.email)
                            .font(.system(size: 12))
                            .fontWeight(.thin)
                            .foregroundColor(.gray)
                            .truncationMode(.tail)
                            .frame(height: 16)
                            .foregroundColor(theme == 1 ? .white : .black)
                    }
                }
                .frame(width: 200, height: 40)
            } else {
                Text("No User")
                    .foregroundColor(theme == 1 ? .white : .black)
                    .frame(width: 250, height: 40)
            }
        }
    }
}

