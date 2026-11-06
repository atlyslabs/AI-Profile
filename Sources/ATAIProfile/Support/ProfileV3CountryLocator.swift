import Foundation

struct ProfileV3CountryLocator: Sendable {
    static let coastalReachDegrees = 0.25

    static let bundled: ProfileV3CountryLocator? = {
        guard let url = Bundle.module.url(forResource: "ProfileV3CountryShapes", withExtension: "geojson"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? ProfileV3CountryLocator(geoJSON: data)
    }()

    private struct Box: Sendable {
        var minX = Double.infinity
        var minY = Double.infinity
        var maxX = -Double.infinity
        var maxY = -Double.infinity

        mutating func include(x: Double, y: Double) {
            minX = min(minX, x)
            minY = min(minY, y)
            maxX = max(maxX, x)
            maxY = max(maxY, y)
        }

        func contains(x: Double, y: Double) -> Bool {
            x >= minX && x <= maxX && y >= minY && y <= maxY
        }
    }

    private struct Ring: Sendable {
        let xs: [Double]
        let ys: [Double]

        func contains(x: Double, y: Double) -> Bool {
            var inside = false
            var j = xs.count - 1
            for i in xs.indices {
                let (xi, yi, xj, yj) = (xs[i], ys[i], xs[j], ys[j])
                if (yi > y) != (yj > y), x < (xj - xi) * (y - yi) / (yj - yi) + xi {
                    inside.toggle()
                }
                j = i
            }
            return inside
        }

        func squaredDistance(x: Double, y: Double, xScale: Double) -> Double {
            var best = Double.infinity
            var j = xs.count - 1
            for i in xs.indices {
                let ax = xs[j] * xScale, ay = ys[j]
                let bx = xs[i] * xScale, by = ys[i]
                let px = x * xScale
                let dx = bx - ax, dy = by - ay
                let lengthSquared = dx * dx + dy * dy
                let t = lengthSquared == 0 ? 0 : max(0, min(1, ((px - ax) * dx + (y - ay) * dy) / lengthSquared))
                let ex = px - (ax + t * dx), ey = y - (ay + t * dy)
                best = min(best, ex * ex + ey * ey)
                j = i
            }
            return best
        }
    }

    private struct Polygon: Sendable {
        let code: String
        let box: Box
        let outer: Ring
        let holes: [Ring]

        func contains(x: Double, y: Double) -> Bool {
            box.contains(x: x, y: y) && outer.contains(x: x, y: y) && !holes.contains { $0.contains(x: x, y: y) }
        }
    }

    private let polygons: [Polygon]

    init(geoJSON data: Data) throws {
        let collection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        var polygons: [Polygon] = []
        for feature in collection.features {
            let code = feature.properties.iso.uppercased()
            for rings in feature.geometry.coordinates {
                guard let outer = rings.first, outer.count >= 3 else { continue }
                var box = Box()
                for point in outer where point.count >= 2 {
                    box.include(x: point[0], y: point[1])
                }
                polygons.append(Polygon(
                    code: code,
                    box: box,
                    outer: Self.ring(outer),
                    holes: rings.dropFirst().map(Self.ring)
                ))
            }
        }
        self.polygons = polygons
    }

    var countryCount: Int { Set(polygons.map(\.code)).count }

    func countryCode(latitude: Double, longitude: Double) -> String? {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else { return nil }
        if let hit = polygons.first(where: { $0.contains(x: longitude, y: latitude) }) {
            return hit.code
        }
        return nearestCode(latitude: latitude, longitude: longitude)
    }

    private func nearestCode(latitude: Double, longitude: Double) -> String? {
        let reach = Self.coastalReachDegrees
        let xScale = max(cos(latitude * .pi / 180), 0.01)
        let lonReach = reach / xScale
        var best: (code: String, distance: Double)?
        for polygon in polygons {
            let box = polygon.box
            guard longitude >= box.minX - lonReach, longitude <= box.maxX + lonReach,
                  latitude >= box.minY - reach, latitude <= box.maxY + reach else { continue }
            let distance = polygon.outer.squaredDistance(x: longitude, y: latitude, xScale: xScale)
            if distance <= reach * reach, distance < (best?.distance ?? .infinity) {
                best = (polygon.code, distance)
            }
        }
        return best?.code
    }

    private static func ring(_ points: [[Double]]) -> Ring {
        let valid = points.filter { $0.count >= 2 }
        return Ring(xs: valid.map { $0[0] }, ys: valid.map { $0[1] })
    }
}

private struct FeatureCollection: Decodable {
    struct Feature: Decodable {
        struct Properties: Decodable {
            let iso: String
        }

        struct Geometry: Decodable {
            let coordinates: [[[[Double]]]]
        }

        let properties: Properties
        let geometry: Geometry
    }

    let features: [Feature]
}
