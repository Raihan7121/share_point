import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_UID") var userUID: String = ""

    var body: some View {
        if logStatus {
            FeedView()
        } else {
            AuthView()
        }
    }
}

#Preview {
    ContentView()
}
