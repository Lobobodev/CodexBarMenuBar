import AppKit

enum ProviderIcons {
    private struct CacheKey: Hashable {
        let providerID: String
        let size: CGFloat
    }

    private static var cache: [CacheKey: NSImage] = [:]

    static func icon(for providerID: String, size: CGFloat = 16) -> NSImage? {
        let key = CacheKey(providerID: providerID, size: size)
        if let cached = cache[key] { return cached }

        guard let url = Bundle.main.url(forResource: "ProviderIcon-\(providerID)", withExtension: "svg"),
              let data = try? Data(contentsOf: url),
              let source = NSImage(data: data) else { return nil }

        let resized = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            source.draw(in: rect)
            return true
        }
        cache[key] = resized
        return resized
    }
}
