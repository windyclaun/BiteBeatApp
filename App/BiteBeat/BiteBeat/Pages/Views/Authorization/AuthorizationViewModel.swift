//
//  AuthorizationViewModel.swift
//  BiteBeat
//

import SwiftUI
import Observation
import BiteBeatMusic

@Observable
@MainActor
public final class AuthorizationViewModel {
    public var isRequesting = false
    public var showPermissionDialog = false

    public init() {}

    public func handleOnAppear(using musicSession: MusicSessionManager) {
        musicSession.refreshAuthorizationStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                self.showPermissionDialog = true
            }
        }
    }

    public func getStatusBannerMessage(for status: BiteMusicAuthorizationStatus) -> String {
        switch status {
        case .denied:
            return "Access denied. Please check your iOS Settings → Privacy → Media & Apple Music."
        case .restricted:
            return "Apple Music access is restricted on this device."
        default:
            return ""
        }
    }

    public func requestAccess(using musicSession: MusicSessionManager) {
        if musicSession.authorizationStatus == .denied {
            openSystemSettings()
            return
        }
        
        isRequesting = true
        Task {
            await musicSession.requestAuthorization()
            isRequesting = false
        }
    }

    public func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
