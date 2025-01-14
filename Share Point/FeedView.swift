import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

struct FeedView: View {
    @State private var posts: [Post] = []
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus: Bool = false // For managing login/logout
    @AppStorage("backgroundMode") var backgroundMode: String = "light" // For managing background color
    var backgroundColor: Color = .white  //.white
    var postBackgroundColor: Color = Color.white.opacity(0.2)
    var textColor: Color = .white  //.black
    
    @State private var selectedPost: Post? // For navigating to Profile or Sharing
    @State private var showProfileView = false
    @State private var showShareSheet = false
    @State private var showCreatePostView = false // For presenting CreatePostView

    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(post.title)
                                .font(.headline)

                            if let url = URL(string: post.imageURL) {
                                AsyncImage(url: url)
                                    .scaledToFill()
                                    .frame(width: 350, height: 200)
                                    .clipped()
                            }

                            HStack {
                                Button(action: { likePost(post) }) {
                                    Label("\(post.likes)", systemImage: "hand.thumbsup.fill")
                                      .foregroundColor(textColor) 
                                }

                                Button(action: { dislikePost(post) }) {
                                    Label("\(post.dislikes)", systemImage: "hand.thumbsdown.fill")
                                      .foregroundColor(textColor) 
                                }

                                // MARK: Share Post Button
                                Button(action: {
                                    selectedPost = post
                                    showShareSheet = true
                                }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                      .foregroundColor(textColor) 
                                }

                                Spacer()

                                // MARK: View Post Details Button
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    Label("Show", systemImage: "eye")
                                      .foregroundColor(textColor) 
                                }
                            }
                        }
                        .padding()
                        .background(postBackgroundColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(backgroundColor) 
            .navigationTitle("Knowledge Feed")
            .toolbar {
                // MARK: Add Post Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showCreatePostView = true
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                              .foregroundColor(textColor) 
                    }
                }
                // MARK: Profile Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:  ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
//                    Button(action: {
//                        showProfileView = true
//                    }) {
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                            .clipShape(Circle())
//                            .foregroundColor(.blue)
//                    }
                }
            }
            .onAppear {
                fetchPosts()
            }
            // MARK: Navigation to ProfileView
//            .sheet(isPresented: $showProfileView) {
//                ProfileView()
//            }
            // MARK: Share Sheet
            .sheet(isPresented: $showShareSheet) {
                if let selectedPost = selectedPost {
                    ShareSheet(activityItems: ["Check out this post: \(selectedPost.title)"])
                }
            }
            // MARK: CreatePostView Sheet
            .sheet(isPresented: $showCreatePostView) {
                CreatePostView()
            }
        }
    }

    private func fetchPosts() {
        let db = Firestore.firestore()
        db.collection("ios_Posts").addSnapshotListener { snapshot, error in
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

    private func likePost(_ post: Post) {
        FirebaseManager.shared.firestore.collection("ios_Posts")
            .document(post.id)
            .updateData(["likes": post.likes + 1])
    }

    private func dislikePost(_ post: Post) {
        FirebaseManager.shared.firestore.collection("ios_Posts")
            .document(post.id)
            .updateData(["dislikes": post.dislikes + 1])
    }

    
}
