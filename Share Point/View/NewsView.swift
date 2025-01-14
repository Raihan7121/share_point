import SwiftUI


struct NewsView: View {
    @StateObject private var viewModel = ArticleViewModel() // Initialize ViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Articles...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.articles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRowView(article: article)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Tesla News")
            .onAppear {
                viewModel.fetchArticles()
            }
        }
    }
}

struct ArticleRowView: View {
    let article: Article

    var body: some View {
        HStack {
            if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(article.source.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

