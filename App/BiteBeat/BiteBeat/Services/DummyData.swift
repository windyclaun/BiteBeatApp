//
//  DummyData.swift
//  BiteBeat
//
//  Created by Windy Claudia Napitupulu on 19/05/26.
//

//
//  DummyData.swift
//  BiteBeat
//
//  Created by Windy Claudia Napitupulu on 19/05/26.
//

import SwiftUI

public struct DummySong: Identifiable {
    public let id = UUID()
    public let title: String
    public let artist: String
    public let imageName: String
    public let color: Color 
    
    // Inisialisasi agar bisa dibaca dari folder/file mana saja di proyek BiteBeat
    public init(title: String, artist: String, imageName: String, color: Color) {
        self.title = title
        self.artist = artist
        self.imageName = imageName
        self.color = color
    }
}

public struct DummyData {
    public static let songs = [
        DummySong(title: "I Lay My Love On You", artist: "Westlife", imageName: "music.note.list", color: .blue),
        DummySong(title: "Story of My Life", artist: "One Direction", imageName: "guitars", color: .purple),
        DummySong(title: "You Raise Me Up", artist: "Josh Groban", imageName: "waveform.and.mic", color: .orange)
    ]
}
