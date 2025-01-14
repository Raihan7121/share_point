import SwiftUI
import FirebaseFirestore

struct PostsView: View {
    @AppStorage("user_UID") var userUID: String = ""
    @State private var posts: [Post] = []
    @State private var showEditPostView = false
    @State private var selectedPost: Post?
    @State private var showDeleteConfirmation = false
    @State private var postToDelete: Post?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(posts) { post in
                        postView(post: post)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("My Posts")
            .toolbar {
                // MARK: Back Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.backward")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                fetchUserPosts()
            }
//            .sheet(isPresented: $showEditPostView) {
//                if let selectedPost = selectedPost {
//                    EditPostView(post: selectedPost)
//                }
//            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Post"),
                    message: Text("Are you sure you want to delete this post?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let postToDelete = postToDelete {
                            deletePost(postToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    @ViewBuilder
    private func postView(post: Post) -> some View {
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
                // Button(action: {
                
                //     EditPostView(post: post)
                    
                // }) {
                //     Text("Edit")
                //         .padding()
                //         .background(Color.blue)
                //         .foregroundColor(.white)
                //         .cornerRadius(10)
                // }
                NavigationLink(destination: EditPostView(post: post)) {
                    Text("Edit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    postToDelete = post
                    showDeleteConfirmation = true
                }) {
                    Text("Delete")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
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

    private func deletePost(_ post: Post) {
        let db = Firestore.firestore()
        db.collection("ios_Posts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                fetchUserPosts()
            }
        }
    }
}
