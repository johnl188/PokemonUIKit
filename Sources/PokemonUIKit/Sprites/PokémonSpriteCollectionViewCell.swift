import UIKit

final class PokémonSpriteCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView = lazyImageView()
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
               
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.constrain(to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PokémonSpriteCollectionViewCell {
    
    private func lazyImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }
}
