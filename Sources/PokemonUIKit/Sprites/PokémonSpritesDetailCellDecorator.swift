import UIKit

import CommonKit

/// A `CellDecorator` implementation for displaying `Sprites` content.
///
///  - Important: Assumes that `Cell`s are displayed in __portraitMode__.
///
/// - SeeAlso: `CellDecorator`.
final class PokémonSpritesDetailCellDecorator: CellDecorator {
    
    func configure(_ collectionView: UICollectionView) {
        collectionView.register(PokémonSpriteCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.itemSize = Constant.itemSize
        layout.sectionInset = .zero

        collectionView.collectionViewLayout = layout
        layout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func decorate(_ cell: PokémonSpriteCollectionViewCell, for collectionView: UICollectionView, using image: UIImage) {
        cell.image = image
    }
    
    func tearDown(_ cell: PokémonSpriteCollectionViewCell, for collectionView: UICollectionView) {
        cell.image = nil
    }
}

extension PokémonSpritesDetailCellDecorator {
    
    private enum Constant {
        
        static var itemSize: CGSize {
            let value = UIScreen.main.bounds.width * 0.6
            
            return CGSize(width: value, height: value)
        }
    }
}
