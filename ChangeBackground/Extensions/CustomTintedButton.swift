import UIKit

@IBDesignable
class CustomTintedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tintColor = self.isSelected ? .white : .gray
     }
}
