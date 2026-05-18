//
//  AlbumRow.swift
//  BiteBeat
//

import MusicKit
import SwiftUI

struct AlbumRow: View {
    let album: Album

    var body: some View {
        HStack(spacing: 14) {
            ArtworkImage(artwork: album.artwork)
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(album.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
