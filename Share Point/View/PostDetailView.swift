import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(post.title)
                    .font(.largeTitle)
                    .bold()

                if let url = URL(string: post.imageURL) {
                    AsyncImage(url: url)
                        .scaledToFill()
                        .scaledToFit()
                        .frame(width: 350, height: 200)
                        .clipped()
                }

                Text("Description:")
                    .font(.headline)
                Text(post.content)
                    .font(.body)

                Text("Likes: \(post.likes)")
                    .font(.subheadline)
                    .foregroundColor(.green)

                Text("Dislikes: \(post.dislikes)")
                    .font(.subheadline)
                    .foregroundColor(.red)

                Text("Author UID: \(post.authorUID)")
                    .font(.subheadline)

                Text("Created At: \(post.createdAt, formatter: dateFormatter)")
                    .font(.subheadline)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Preview for SwiftUI canvas
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: Post(
            id: "1",
            title: "Sample Post",
            content: "This is a sample post description.",
            imageURL: "https://example.com/image.jpg",
            likes: 10,
            dislikes: 2,
            authorUID: "user123",
            createdAt: Date()
        ))
    }
}
