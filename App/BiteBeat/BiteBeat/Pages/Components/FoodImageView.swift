import SwiftUI
import OSLog

public final class FoodImageService {
    public static let shared = FoodImageService()

    private let logger = Logger(subsystem: "com.pucakgunung.BiteBeat", category: "FoodImageService")

    private init() {}

    public func fetchImage(for query: String) async -> String? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://id.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=\(encodedQuery)&gsrlimit=1&prop=pageimages&format=json&pithumbsize=600"

        guard let url = URL(string: urlString) else { return nil }

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
        } catch is CancellationError {
            return nil
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                return nil
            }
            logger.error("Failed to fetch Wikipedia image: \(error.localizedDescription)")
        }

        return nil
    }
}

struct FoodImageView: View {
    let mealTitle: String
    let wikipediaQuery: String
    let fallbackUrl: String
    
    @State private var activeImageUrl: String? = nil

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
            if let liveUrl = await FoodImageService.shared.fetchImage(for: wikipediaQuery) {
                activeImageUrl = liveUrl
            } else {
                activeImageUrl = fallbackUrl
            }
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
                    .tint(Color.accentColor)
            }
    }
    
    private var fallbackPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(.quaternary.opacity(0.4))
            
            Image(systemName: "fork.knife.circle.fill")
                .biteBeatFont(.largeTitle)
                .foregroundStyle(Color.accentColor)
        }
    }
}
