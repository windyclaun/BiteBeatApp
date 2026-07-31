import BiteBeatMusic
import MapKit
import SwiftUI

struct AppleMapsPeekView: View {
    @Environment(\.dismiss) private var dismiss

    let meal: Meal

    @State private var cameraPosition: MapCameraPosition

    init(meal: Meal) {
        self.meal = meal

        if let lat = meal.latitude, let lon = meal.longitude {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
            )
            _cameraPosition = State(initialValue: .region(region))
        } else {
            _cameraPosition = State(initialValue: .automatic)
        }
    }

    private var hasCoordinates: Bool {
        meal.latitude != nil && meal.longitude != nil
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                swipeHint
                Spacer()
                card
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var backgroundLayer: some View {
        ZStack {
            EndingGradientBackground()
                .ignoresSafeArea()

            heroContent
        }
    }

    private var heroContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            EndingHeroImage(meal: meal)
                .frame(height: 220)
            EndingMealCopy(meal: meal)
                .padding(.top, 24)
            Spacer(minLength: 0)
        }
        .opacity(0.55)
        .blur(radius: 1.5)
    }

    private var swipeHint: some View {
        Text("swipe up to get there")
            .biteBeatFont(.footnote)
            .foregroundStyle(Color.onAccent.opacity(0.85))
            .padding(.top, 8)
    }

    private var card: some View {
        VStack(spacing: 0) {
            grabber
                .padding(.top, 10)
                .padding(.bottom, 6)

            mapHeader

            mapContainer
                .padding(.horizontal, 16)
                .padding(.top, 4)

            doneButton
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var mapHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.restaurantName)
                    .biteBeatFont(.headline, weight: .bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let distance = meal.formattedDistance {
                    Text(distance)
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .biteBeatFont(.subheadline, weight: .bold)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.quaternary, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private var mapContainer: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                mapContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                directionsHint
                    .padding(.top, 12)
            }
        }
        .frame(minHeight: 220, idealHeight: 300)
    }

    private var mapContent: some View {
        ZStack {
            if hasCoordinates {
                Map(position: $cameraPosition, interactionModes: []) {
                    if let lat = meal.latitude, let lon = meal.longitude {
                        Annotation(meal.restaurantName, coordinate: .init(latitude: lat, longitude: lon)) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 22, height: 22)
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                                    .frame(width: 22, height: 22)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.restaurant])))
            } else {
                mapPlaceholder
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            openDirections()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Open Apple Maps for directions")
    }

    private var mapPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemGray5), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 8) {
                Image(systemName: "mappin.slash.circle.fill")
                    .biteBeatFont(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Location unavailable")
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var directionsHint: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                .biteBeatFont(.caption, weight: .bold)
            Text("tap to get directions")
                .biteBeatFont(.footnote, weight: .semibold)
        }
        .foregroundStyle(Color.accentColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.background, in: .capsule)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }

    private var grabber: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.35))
            .frame(width: 36, height: 4)
    }

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .biteBeatFont(.headline, weight: .bold)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(.glassProminent)
        .tint(Color.accentColor)
    }

    private func openDirections() {
        Task {
            await MapsHelper.openInMaps(for: meal)
            dismiss()
        }
    }
}
