//
//  ArticleDetailView.swift
//  Share Point
//
//  Created by Dibyo sarkar on 14/1/25.
//
import SwiftUI

struct ArticleDetailView: View {
    let article: Article
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                }

                Text(article.title)
                    .font(.title)
                    .padding(.top)

                Text("By \(article.author ?? "Unknown Author")")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(article.description ?? "No description available.")
                    .padding(.top)

                if let url = URL(string: article.url) {
                    Link("Read more", destination: url)
                        .padding(.top)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle(article.source.name)
   
        
    }
}
