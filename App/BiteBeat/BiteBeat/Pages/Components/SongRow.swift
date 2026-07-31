//
//  SongRow.swift
//  BiteBeat
//

import BiteBeatMusic
import SwiftUI

struct SongRow: View {
    let song: BiteMusicTrack

    var body: some View {
        HStack(spacing: 14) {
            ArtworkImage(artworkURL: song.artworkURL)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .biteBeatFont(.body, weight: .medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(song.artistName)
                    .biteBeatFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}
