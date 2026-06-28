import SwiftUI

public final class FoodImageService {
    public static let shared = FoodImageService()

    private init() {}

    // Caches resolved URLs per query for the session. A stored nil means
    // "already searched, no photo found" so we don't re-hit the network.
    private var cache: [String: String?] = [:]

    public func resolveImageURL(for query: String) async -> String? {
        let key = query.lowercased()
        if let cached = cache[key] {
            return cached
        }
        let resolved = await fetchFromPexels(query: query)
        cache[key] = resolved
        return resolved
    }

    private func fetchFromPexels(query: String) async -> String? {
        guard
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://api.pexels.com/v1/search?query=\(encoded)&per_page=1&orientation=square")
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(Secrets.pexelsAPIKey, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }
            let decoded = try JSONDecoder().decode(PexelsResponse.self, from: data)
            return decoded.photos.first?.src.large
        } catch {
            return nil
        }
    }
}

private struct PexelsResponse: Decodable {
    let photos: [PexelsPhoto]
}

private struct PexelsPhoto: Decodable {
    let src: PexelsSource
}

private struct PexelsSource: Decodable {
    let large: String
}

struct FoodImageView: View {
    let directImageURL: String
    let searchQuery: String
    let systemImage: String
    let gradientColors: [Color]

    private enum LoadState: Equatable {
        case loading
        case loaded(URL)
        case unavailable
    }

    @State private var state: LoadState = .loading

    var body: some View {
        ZStack {
            switch state {
            case .loading:
                loadingPlaceholder
            case .loaded(let url):
                photo(url)
            case .unavailable:
                fallbackVisual
            }
        }
        .task(id: directImageURL + "|" + searchQuery) {
            await resolve()
        }
    }

    private func resolve() async {
        if let direct = validURL(directImageURL) {
            state = .loaded(direct)
            return
        }

        state = .loading
        if let resolved = await FoodImageService.shared.resolveImageURL(for: searchQuery),
           let url = validURL(resolved) {
            state = .loaded(url)
        } else {
            state = .unavailable
        }
    }

    private func validURL(_ string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }

    private func photo(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                loadingPlaceholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.scale.combined(with: .opacity))
            case .failure:
                fallbackVisual
            @unknown default:
                fallbackVisual
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
                    .tint(.pink)
            }
    }

    // Guaranteed last-resort visual built from the meal's own symbol and colors.
    private var fallbackVisual: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors.isEmpty ? [.pink, .orange] : gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: systemImage.isEmpty ? "fork.knife" : systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}
