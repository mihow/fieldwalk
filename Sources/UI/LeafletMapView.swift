import SwiftUI
import WebKit

/// Reusable Leaflet.js map view using WKWebView for reliable tile rendering.
/// MKMapView fails in QEMU VMs (Metal/GPU limitation), so we use Leaflet + OSM tiles instead.
struct LeafletMapView: UIViewRepresentable {
    var trackCoordinates: [(Double, Double)]
    var annotations: [(coordinate: (Double, Double), title: String)]
    var showDirectionArrows: Bool = false
    var followUser: Bool = false
    var currentLocation: (Double, Double)? = nil

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        context.coordinator.webView = webView
        loadMap(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if data changed
        let newHash = dataHash
        if newHash != context.coordinator.lastHash {
            context.coordinator.lastHash = newHash
            loadMap(webView)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        weak var webView: WKWebView?
        var lastHash: Int = 0
    }

    private var dataHash: Int {
        var hasher = Hasher()
        hasher.combine(trackCoordinates.count)
        hasher.combine(annotations.count)
        if let loc = currentLocation {
            hasher.combine(loc.0)
            hasher.combine(loc.1)
        }
        // Include first/last coords for change detection
        if let first = trackCoordinates.first {
            hasher.combine(first.0)
            hasher.combine(first.1)
        }
        if let last = trackCoordinates.last {
            hasher.combine(last.0)
            hasher.combine(last.1)
        }
        return hasher.finalize()
    }

    private func loadMap(_ webView: WKWebView) {
        let points = trackCoordinates.map { "[\($0.0), \($0.1)]" }.joined(separator: ",")
        let markers = annotations.map { ann in
            let escaped = ann.title.replacingOccurrences(of: "'", with: "\\'")
            return "L.marker([\(ann.coordinate.0), \(ann.coordinate.1)]).addTo(map).bindPopup('\(escaped)');"
        }.joined(separator: "\n")

        // Default center: NYC area or first track point
        let defaultLat = trackCoordinates.first?.0 ?? currentLocation?.0 ?? 40.7128
        let defaultLon = trackCoordinates.first?.1 ?? currentLocation?.1 ?? -74.0060
        let defaultZoom = trackCoordinates.isEmpty ? 15 : 16

        let currentLocJS: String
        if let loc = currentLocation {
            currentLocJS = """
            var userMarker = L.circleMarker([\(loc.0), \(loc.1)], {
                radius: 8, fillColor: '#007AFF', color: '#fff',
                weight: 2, fillOpacity: 1
            }).addTo(map).bindPopup('Current Location');
            """
        } else {
            currentLocJS = ""
        }

        let arrowJS: String
        if showDirectionArrows && trackCoordinates.count > 1 {
            // Add arrow decorations along the polyline using CSS triangles
            arrowJS = """
            // Draw direction arrows every N points
            var arrowInterval = Math.max(1, Math.floor(coords.length / 10));
            for (var i = 0; i < coords.length - 1; i += arrowInterval) {
                var from = coords[i];
                var to = coords[Math.min(i + arrowInterval, coords.length - 1)];
                var midLat = (from[0] + to[0]) / 2;
                var midLng = (from[1] + to[1]) / 2;
                var angle = Math.atan2(to[1] - from[1], to[0] - from[0]) * 180 / Math.PI;
                var arrowIcon = L.divIcon({
                    html: '<div style="transform: rotate(' + (-angle + 90) + 'deg); font-size: 18px; color: #0066CC; text-shadow: 0 0 2px white;">&#9650;</div>',
                    className: 'arrow-icon',
                    iconSize: [20, 20],
                    iconAnchor: [10, 10]
                });
                L.marker([midLat, midLng], {icon: arrowIcon, interactive: false}).addTo(map);
            }
            """
        } else {
            arrowJS = ""
        }

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <style>
        html, body, #map { height: 100%; margin: 0; padding: 0; }
        .arrow-icon { background: none !important; border: none !important; }
        </style>
        </head>
        <body>
        <div id="map"></div>
        <script>
        var map = L.map('map', {zoomControl: false}).setView([\(defaultLat), \(defaultLon)], \(defaultZoom));
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OSM'
        }).addTo(map);

        var coords = [\(points)];
        if (coords.length > 1) {
            var polyline = L.polyline(coords, {color: '#0066CC', weight: 4, opacity: 0.8}).addTo(map);
            map.fitBounds(polyline.getBounds().pad(0.15));
            \(arrowJS)
        }

        \(markers)
        \(currentLocJS)
        </script>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }
}
