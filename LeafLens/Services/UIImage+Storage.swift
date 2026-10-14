import UIKit

extension UIImage {
    /// Downscales the image and compresses it to JPEG before saving,
    /// which keeps the database small and the garden list fast.
    func jpegDataForStorage(maxDimension: CGFloat = 1024, quality: CGFloat = 0.8) -> Data? {
        let largest = max(size.width, size.height)
        guard largest > maxDimension else { return jpegData(compressionQuality: quality) }

        let scale = maxDimension / largest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let resized = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
