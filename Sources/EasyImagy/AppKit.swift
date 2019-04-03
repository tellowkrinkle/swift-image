#if canImport(AppKit) && canImport(CoreGraphics)
import Foundation
import AppKit
extension Image where Pixel: _CGPixel {
    public init(nsImage: NSImage) {
        if let cgImage: CGImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            self.init(cgImage: cgImage)
        } else {
            precondition(nsImage.size == .zero, "The `size` of the given `NSImage` instance (\(nsImage)) must be equal to `.zero` when the `cgImage` of the instance is `nil`.")
            self.init(width: 0, height: 0, pixels: [])
        }
    }
    
    private init?(nsImageOrNil: NSImage?) {
        guard let nsImage: NSImage = nsImageOrNil else { return nil }
        self.init(nsImage: nsImage)
    }
    
    public init?(named name: NSImage.Name) {
        self.init(nsImageOrNil: NSImage(named: name))
    }
    
    public init?(contentsOfFile path: String) {
        self.init(nsImageOrNil: NSImage(contentsOfFile: path))
    }
    
    public init?(data: Data) {
        self.init(nsImageOrNil: NSImage(data: data))
    }
    
    public var nsImage: NSImage {
        return NSImage(cgImage: cgImage, size: .zero)
    }

    public func pngData() -> Data? {
        guard width > 0 && height > 0 else { return nil }

        return autoreleasepool {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            imageRep.size = CGSize(width: CGFloat(width), height: CGFloat(height))
            return imageRep.representation(using: .png, properties: [:])
        }
    }

    public func jpegData(compressionQuality: Double) -> Data? {
        guard width > 0 && height > 0 else { return nil }

        return autoreleasepool {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            imageRep.size = CGSize(width: CGFloat(width), height: CGFloat(height))
            return imageRep.representation(using: .jpeg, properties: [.compressionFactor: NSNumber(value: compressionQuality)])
        }
    }

    public func data(using format: Image.Format) -> Data? {
        switch format {
        case .png:
            return pngData()
        case .jpeg(let compressionQuality):
            return jpegData(compressionQuality: compressionQuality)
        }
    }

    public func write(to url: URL, atomically: Bool, format: Image.Format) throws {
        guard let data = data(using: format) else {
            throw Image.Format.FormattingError<Image<Pixel>>(image: self, format: format)
        }
        try data.write(to: url, options: atomically ? .atomic : .init(rawValue: 0))
    }

    public func write<S : StringProtocol>(toFile path: S, atomically: Bool, format: Image.Format) throws {
        try write(to: URL(fileURLWithPath: String(path)), atomically: atomically, format: format)
    }
}
#endif
