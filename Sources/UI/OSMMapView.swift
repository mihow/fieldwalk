import SwiftUI
import MapKit

struct OSMMapView: UIViewRepresentable {
    var trackCoordinates: [CLLocationCoordinate2D]
    var annotations: [(coordinate: CLLocationCoordinate2D, title: String)]
    var region: MKCoordinateRegion?
    var showsUserLocation: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // Add OSM tile overlay to replace blank Apple tiles
        let overlay = MKTileOverlay(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        overlay.maximumZ = 19
        mapView.addOverlay(overlay, level: .aboveLabels)

        mapView.showsUserLocation = showsUserLocation

        // Apply initial content
        applyTrack(to: mapView, coordinator: context.coordinator)
        applyAnnotations(to: mapView, coordinator: context.coordinator)
        applyRegion(to: mapView)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.showsUserLocation = showsUserLocation
        applyTrack(to: mapView, coordinator: context.coordinator)
        applyAnnotations(to: mapView, coordinator: context.coordinator)
        applyRegion(to: mapView)
    }

    private func applyTrack(to mapView: MKMapView, coordinator: Coordinator) {
        // Remove old polyline
        if let existing = coordinator.currentPolyline {
            mapView.removeOverlay(existing)
            coordinator.currentPolyline = nil
        }
        // Add new polyline if we have points
        if trackCoordinates.count > 1 {
            let polyline = MKPolyline(coordinates: trackCoordinates, count: trackCoordinates.count)
            coordinator.currentPolyline = polyline
            mapView.addOverlay(polyline, level: .aboveLabels)
        }
    }

    private func applyAnnotations(to mapView: MKMapView, coordinator: Coordinator) {
        // Remove old annotations (keep user location)
        let existing = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existing)

        for item in annotations {
            let pin = MKPointAnnotation()
            pin.coordinate = item.coordinate
            pin.title = item.title
            mapView.addAnnotation(pin)
        }
    }

    private func applyRegion(to mapView: MKMapView) {
        if let region {
            mapView.setRegion(region, animated: false)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var currentPolyline: MKPolyline?

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            }
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let identifier = "ObsPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.markerTintColor = .systemOrange
            view.glyphImage = UIImage(systemName: "mappin")
            return view
        }
    }
}
