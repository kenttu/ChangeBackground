import UIKit

@IBDesignable
class VerticalButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
        
        // Center the image horizontally
        imageView.center.x = self.bounds.midX
        titleLabel.center.x = self.bounds.midX
        
        // Adjust the image and label position vertically
        let totalHeight = imageView.frame.height + titleLabel.frame.height
        let contentHeight = imageView.frame.height + titleLabel.frame.height + contentEdgeInsets.top + contentEdgeInsets.bottom
        
        let topInset = (bounds.height - contentHeight) / 2
        let imageTopInset = topInset + contentEdgeInsets.top
        let titleTopInset = imageTopInset + imageView.frame.height
        
        imageView.frame.origin.y = imageTopInset
        titleLabel.frame.origin.y = titleTopInset
    }
}
