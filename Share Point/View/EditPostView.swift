import SwiftUI
import Firebase
import FirebaseStorage

struct EditPostView: View {
    @State private var title: String
    @State private var content: String
    @State private var imageURL: String
    @State private var likes: Int
    @State private var dislikes: Int
    @State private var image: UIImage?
    @State private var imageData: Data?
    @State private var isLoading = false
    @State private var isEditing = false
    @Environment(\.dismiss) var dismiss

    var post: Post

    init(post: Post) {
        self.post = post
        _title = State(initialValue: post.title)
        _content = State(initialValue: post.content)
        _imageURL = State(initialValue: post.imageURL)
        _likes = State(initialValue: post.likes)
        _dislikes = State(initialValue: post.dislikes)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    TextField("Post Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(maxWidth: 300)
                        .disabled(!isEditing)

                    TextEditor(text: $content)
                        .frame(height: 150)
                        .border(Color.gray, width: 1)
                        .cornerRadius(5)
                        .padding(.horizontal)
                        .frame(maxWidth: 300)
                        .disabled(!isEditing)

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else if !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL))
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    if isEditing {
                        Button(action: selectImage) {
                            Text("Change Image")
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }

                    Spacer()

                    if isLoading {
                        ProgressView()
                    }
                }
                .padding()
            }
           
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if isEditing {
                            isEditing = false
                            // Reset values
                            title = post.title
                            content = post.content
                            imageURL = post.imageURL
                        } else {
                            dismiss()
                        }
                    }) {
                        
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button(action: savePost) {
                            Text("Save")
                        }
                        .disabled(title.isEmpty || content.isEmpty)
                    } else {
                        Button(action: { isEditing = true }) {
                            Text("Edit")
                        }
                    }
                }
            }
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(image: $image, imageData: $imageData)
            })
        }
    }

    @State private var showImagePicker = false

    private func selectImage() {
        showImagePicker = true
    }

    private func savePost() {
        guard let imageData else {
            updatePost(imageURL: imageURL)
            return
        }
        isLoading = true

        Task {
            do {
                // Step 1: Upload image to Firebase Storage
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let storageRef = Storage.storage().reference().child("Post_Images/\(timestamp).jpg")
                _ = try await storageRef.putDataAsync(imageData)
                let newImageURL = try await storageRef.downloadURL()

                // Step 2: Update the post with the new image URL
                updatePost(imageURL: newImageURL.absoluteString)
            } catch {
                print("Error updating post: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }

    private func updatePost(imageURL: String) {
        let db = Firestore.firestore()
        db.collection("ios_Posts").document(post.id).updateData([
            "title": title,
            "content": content,
            "imageURL": imageURL,
            "likes": likes,
            "dislikes": dislikes
        ]) { error in
            isLoading = false
            if let error = error {
                print("Error updating post: \(error.localizedDescription)")
            } else {
                isEditing = false
                dismiss()
            }
        }
    }
}
