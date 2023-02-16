import Foundation
import Combine

final class GmailViewModel: ObservableObject {
    private var cancellable: AnyCancellable?
    private let gmailLoader = GmailLoader()
    
    @Published var unreadCount: Int
    @Published var receivedStatus = ReceivedStatus.ReceivedOk
    
    public var id = ""
    
    init(){
        unreadCount = UserDefaults.standard.object(forKey: "UnreadCount") as? Int ?? 0
    }
    
    func fetchNewestMail(id: String){
        func completion(publisher: AnyPublisher<Any, GmailLoader.Error>) -> Void {
            self.cancellable = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving mails: \(error)")
                    self.receivedStatus = ReceivedStatus.ReceivedError
                }
            } receiveValue: { item in
                if let item = item as? (String, String) {
                    let subject = item.0
                    let from = item.1
                    if (subject != "" && from != ""){
                        GmailNotification.pushNotification(title: from, body: subject, badge: self.unreadCount as NSNumber)
                    } else {
                        self.receivedStatus = ReceivedStatus.ReceivedError
                    }
                } else {
                    self.receivedStatus = ReceivedStatus.ReceivedError
                }
            }
        }
        
        gmailLoader.newestPublisher(id: id, completion: completion)
    }
    
    func fetchUnreadMails() {
        //gmailLoader.unreadGmailPublisher{ publisher in
        gmailLoader.unreadPublisher{ publisher in
            self.cancellable = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving mails: \(error)")
                    self.receivedStatus = ReceivedStatus.ReceivedError
                }
            } receiveValue: { item in
                if let item = item as? (Int, String?) {
                    let num = item.0
                    let id = item.1
                    if (num == -1 ) {
                        self.receivedStatus = ReceivedStatus.ReceivedError
                    } else {
                        self.receivedStatus = ReceivedStatus.ReceivedOk
                        self.unreadCount = num
                        self.id = id ?? ""
                        //UserDefaults.standard.set(num, forKey: "UnreadCount")
                    }
                } else {
                    self.receivedStatus = ReceivedStatus.ReceivedError
                }
            }
        }
    }
}

extension GmailViewModel{
    enum ReceivedStatus {
        case ReceivedOk
        case ReceivedError
    }
}
