import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
//    var userUID: String
    @State private var user: User?
    @State private var posts: [Post] = []
    @State private var showUpdateProfileView = false
    @State private var showPostsView = false
    @State private var showNewsPaperView = false
    @State private var showSettingsView = false
    @AppStorage("backgroundMode") var backgroundMode: String = "light"
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus: Bool = false // For managing login/logout
   
    @State private var backgroundColor: Color = .white
    @State private var textColor: Color = .black
    var body: some View {
        VStack(spacing: 20) {
            if let user = user {
                VStack(spacing: 10) {
                    AsyncImage(url: URL(string: user.profileImageURL))
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())

                    Text(user.username)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(user.bio)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            showUpdateProfileView = true
                        }) {
                            Text("Edit Profile")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showUpdateProfileView) {
                            UpdateProfileView()
                        }

                        Button(action: {
                            showPostsView = true
                        }) {
                            Text("See Posts")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showPostsView) {
                            PostsView(userUID: userUID)
                        }
                        NavigationLink(destination: NewsView()) {
                            Text("Read Newspaper")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                       
//                        .sheet(isPresented: $showNewsPaperView) {
//                            NewsView()
//                        }
                    }
                }
                .padding()

                Spacer()
                
            } else {
                ProgressView("Loading Profile...")
            }
        }
        .onAppear {
            fetchProfile()
            fetchUserPosts()
            updateColors()
        }
        .navigationTitle("Profile")
        .toolbar {
         
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: AuthView().onAppear(perform: logout)) {
                                Image(systemName: "power")
                                    .foregroundColor(.red)
                                    }
                                }
                            }

    
    }

    private func fetchProfile() {
        FirebaseManager.shared.firestore.collection("ios_users")
            .document(userUID)
            .getDocument { document, error in
                if let document = document, document.exists {
                    user = try? document.data(as: User.self)
                }
            }
    }

    private func fetchUserPosts() {
        let db = Firestore.firestore()
        db.collection("ios_Posts")
            .whereField("authorUID", isEqualTo: userUID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                } else {
                    posts = snapshot?.documents.compactMap { doc -> Post? in
                        let data = doc.data()
                        return Post(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? "",
                            likes: data["likes"] as? Int ?? 0,
                            dislikes: data["dislikes"] as? Int ?? 0,
                            authorUID: data["authorUID"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                        )
                    } ?? []
                }
            }
    }
    private func updateColors() {
        if backgroundMode == "dark" {
            backgroundColor = .black
            textColor = .white
        } else {
            backgroundColor = .white
            textColor = .black
        }
    }

    func didChangeMode(to mode: String) {
        backgroundMode = mode
        updateColors()
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            logStatus = false
            userUID = ""
        
            
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

