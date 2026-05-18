//
//  ArtworkImage.swift
//  test_music_kit
//

import MusicKit
import SwiftUI

struct ArtworkImage: View {
    let artwork: Artwork?
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let artwork, let url = artwork.url(width: Int(size * 2), height: Int(size * 2)) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    default:
                        placeholder.overlay { ProgressView() }
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size > 80 ? 12 : 8))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: size > 80 ? 12 : 8)
            .fill(.quaternary)
            .overlay {
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            }
    }
}
