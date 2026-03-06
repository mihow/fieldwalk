import SwiftUI
import WebKit
import MapKit

/// Debug view for A/B testing map rendering approaches.
/// Leaflet/WKWebView works in QEMU VM; MKMapView does not (Metal/GPU limitation).
struct DebugMapTestView: View {
    @State private var showLeaflet = true

    var body: some View {
        VStack(spacing: 0) {
            Picker("Map Type", selection: $showLeaflet) {
                Text("Leaflet/OSM").tag(true)
                Text("MKTileOverlay").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(8)

            if showLeaflet {
                LeafletMapView(
                    trackCoordinates: FixtureData.transectCoords.map { ($0.lat, $0.lon) },
                    annotations: FixtureData.observationPoints.map { obs in
                        (coordinate: (obs.lat, obs.lon), title: obs.category)
                    },
                    showDirectionArrows: true
                )
            } else {
                MKTileOverlayTestView()
            }
        }
    }
}

/// MKTileOverlay test (doesn't render in QEMU - kept for reference)
struct MKTileOverlayTestView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let overlay = MKTileOverlay(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        overlay.maximumZ = 19
        mapView.addOverlay(overlay, level: .aboveLabels)

        let coords = FixtureData.transectCoords.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
        }
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline, level: .aboveLabels)

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7138, longitude: -74.0035),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        mapView.setRegion(region, animated: false)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {}

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tile = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tile)
            }
            if let polyline = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: polyline)
                r.strokeColor = .systemBlue
                r.lineWidth = 4
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
