import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct UpdateProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var profileImageURL: String = ""
    @State private var email: String = ""
    @State private var image: UIImage?
    @State private var imageData: Data?
    @State private var isLoading = false
    @AppStorage("user_UID") var userUID: String = ""
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .padding()
                } else if !profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: profileImageURL))
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .padding()
                }

                Button(action: {
                    showImagePicker = true
                }) {
                    Text("Change Profile Picture")
                        .foregroundColor(.blue)
                }
                .padding()

                Form {
                    Section(header: Text("Profile Information")) {
                        TextField("Username", text: $username)
                        TextField("Bio", text: $bio)
                    }
                }

                if isLoading {
                    ProgressView()
                } else {
                    Button(action: updateProfile) {
                        Text("Update")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Update Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image, imageData: $imageData)
            }
        }
        .onAppear {
            fetchUserProfile()
        }
    }

    private func fetchUserProfile() {
        let db = Firestore.firestore()
        db.collection("ios_users").document(userUID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                username = data?["username"] as? String ?? ""
                bio = data?["bio"] as? String ?? ""
                profileImageURL = data?["profileImageURL"] as? String ?? ""
                email = data?["email"] as? String ?? ""
            }
        }
    }

    private func updateProfile() {
        guard let imageData else {
            saveProfile(profileImageURL: profileImageURL)
            return
        }
        isLoading = true

        Task {
            do {
                // Step 1: Upload image to Firebase Storage
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let storageRef = Storage.storage().reference().child("Profile_Images/\(timestamp).jpg")
                _ = try await storageRef.putDataAsync(imageData)
                let newImageURL = try await storageRef.downloadURL()

                // Step 2: Save profile with the new image URL
                saveProfile(profileImageURL: newImageURL.absoluteString)
            } catch {
                print("Error updating profile: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }

    private func saveProfile(profileImageURL: String) {
        let db = Firestore.firestore()
        db.collection("ios_users").document(userUID).updateData([
            "username": username,
            "bio": bio,
            "profileImageURL": profileImageURL,
            "email": email
        ]) { error in
            isLoading = false
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}