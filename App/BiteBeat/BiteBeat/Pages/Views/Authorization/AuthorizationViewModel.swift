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

    /// Triggered when the view appears. Triggers the permission dialog with a spring animation after a short delay.
    public func handleOnAppear(using musicSession: MusicSessionManager) {
        musicSession.refreshAuthorizationStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                self.showPermissionDialog = true
            }
        }
    }

    /// Provides localized error descriptions for the authorization banner.
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

    /// Requests Apple Music authorization using the MusicSessionManager and executes a completion handler.
    public func requestAccess(using musicSession: MusicSessionManager, completion: @escaping @MainActor () -> Void) {
        if musicSession.authorizationStatus == .denied {
            openSystemSettings()
            return
        }
        
        isRequesting = true
        Task {
            await musicSession.requestAuthorization()
            isRequesting = false
            completion()
        }
    }

    /// Redirects the user to the iOS System Settings app.
    public func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

