import SwiftUI
import Firebase
import FirebaseStorage


struct CreatePostView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var image: UIImage?
    @State private var imageData: Data?
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss

    @AppStorage("user_UID") var userUID: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
               
                TextField("Post Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextEditor(text: $content)
                    .frame(height: 150)
                    .border(Color.gray, width: 1)
                    .cornerRadius(5)
                    .padding()

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()
                } else {
                    Button(action: selectImage) {
                        Text("Add an Image")
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                if isLoading {
                    ProgressView()
                } else {
                    Button(action: createPost) {
                        Text("Create Post")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(title.isEmpty || content.isEmpty || imageData == nil)
                    .padding()
                }
            }
            .navigationTitle("Create Post")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
    
    

    private func createPost() {
        guard let imageData else { return }
        isLoading = true

        Task {
            do {
                // Step 1: Upload image to Firebase Storage
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let storageRef = Storage.storage().reference().child("Post_Images/\(timestamp).jpg")
                _ = try await storageRef.putDataAsync(imageData)
                let imageURL = try await storageRef.downloadURL()

                // Step 2: Create a dictionary for the post
                let postID = "\(timestamp)"
                let post: [String: Any] = [
                    "id": postID,
                    "title": title,
                    "content": content,
                    "imageURL": imageURL.absoluteString,
                    "likes": 0,
                    "dislikes": 0,
                    "authorUID": userUID,
                    "createdAt": Timestamp()
                ]

                // Step 3: Save the dictionary to Firestore
                let db = Firestore.firestore()
                try await db.collection("ios_Posts").document(postID).setData(post)

                // Step 4: Dismiss and reset UI
                isLoading = false
                dismiss()
            } catch {
                print("Error creating post: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}
