import UIKit

import PokemonFoundation

final class PokémonSpritesDetailViewController: UICollectionViewController {
    
    private let sprites: [UIImage]
    private let decorator: PokémonSpritesDetailCellDecorator
    
    init(group: Pokémon.Sprites.DisplayGroup) {
        sprites = group.images
        decorator = PokémonSpritesDetailCellDecorator()
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PokémonSpritesDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        decorator.configure(collectionView)
    }
}

extension PokémonSpritesDetailViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return sprites.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let sprite = sprites[indexPath.row]
        let cell: PokémonSpriteCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)!
        
        decorator.decorate(cell, for: collectionView, using: sprite)

        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        //swiftlint:disable:next force_cast
        let cell = cell as! PokémonSpriteCollectionViewCell
        decorator.tearDown(cell, for: collectionView)
    }
}
