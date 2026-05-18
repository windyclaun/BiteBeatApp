//
//  PlaylistRow.swift
//  BiteBeat
//

import MusicKit
import SwiftUI

struct PlaylistRow: View {
    let playlist: Playlist

    var body: some View {
        HStack(spacing: 14) {
            ArtworkImage(artwork: playlist.artwork)
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                if let curatorName = playlist.curatorName {
                    Text(curatorName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
