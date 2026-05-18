import SwiftUI

public final class FoodImageService {
    public static let shared = FoodImageService()
    
    private init() {}
    
    // Query Wikipedia Search API + Page Image API to guarantee finding an authentic image
    public func fetchImage(for query: String) async -> String? {
        // Step 1: Search Wikipedia for the best matching article
        guard let encodedSearch = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        let searchUrlString = "https://id.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(encodedSearch)&format=json&srlimit=1"
        
        guard let searchUrl = URL(string: searchUrlString) else { return nil }
        
        var resolvedTitle = query
        do {
            let (searchData, _) = try await URLSession.shared.data(from: searchUrl)
            struct WikiSearchResult: Decodable {
                struct QueryResult: Decodable {
                    struct SearchItem: Decodable {
                        let title: String
                    }
                    let search: [SearchItem]
                }
                let query: QueryResult
            }
            
            let response = try JSONDecoder().decode(WikiSearchResult.self, from: searchData)
            if let bestTitle = response.query.search.first?.title {
                resolvedTitle = bestTitle
            }
        } catch {
            print("Gagal mencari artikel di Wikipedia: \(error)")
        }
        
        // Step 2: Fetch the page image for the resolved article title
        guard let encodedQuery = resolvedTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        let imageUrlString = "https://id.wikipedia.org/w/api.php?action=query&titles=\(encodedQuery)&prop=pageimages&format=json&pithumbsize=600"
        
        guard let url = URL(string: imageUrlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let queryDict = json["query"] as? [String: Any],
               let pages = queryDict["pages"] as? [String: Any] {
                
                if let firstPageKey = pages.keys.first,
                   let pageData = pages[firstPageKey] as? [String: Any],
                   let thumbnail = pageData["thumbnail"] as? [String: Any],
                   let sourceUrl = thumbnail["source"] as? String {
                    return sourceUrl
                }
            }
        } catch {
            print("Gagal fetch gambar Wikipedia: \(error)")
        }
        
        return nil
    }
}

struct FoodImageView: View {
    let mealTitle: String
    let wikipediaQuery: String
    let fallbackUrl: String
    
    @State private var activeImageUrl: String? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let imageUrlString = activeImageUrl, let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        loadingPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.scale.combined(with: .opacity))
                    case .failure:
                        fallbackPlaceholder
                    @unknown default:
                        loadingPlaceholder
                    }
                }
            } else {
                loadingPlaceholder
            }
        }
        .task {
            // Coba fetch gambar dari API Publik Wikipedia
            if let liveUrl = await FoodImageService.shared.fetchImage(for: wikipediaQuery) {
                activeImageUrl = liveUrl
            } else {
                // Gunakan Unsplash fallback jika gagal
                activeImageUrl = fallbackUrl
            }
            isLoading = false
        }
    }
    
    private var loadingPlaceholder: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(LinearGradient(
                colors: [.gray.opacity(0.1), .gray.opacity(0.2), .gray.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay {
                ProgressView()
                    .tint(.pink)
            }
    }
    
    private var fallbackPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(.quaternary.opacity(0.4))
            
            Image(systemName: "fork.knife.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.pink)
        }
    }
}
