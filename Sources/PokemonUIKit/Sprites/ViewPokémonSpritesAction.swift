import UIKit

import PokemonFoundation

final class ViewPokémonSpritesAction: PokédexMenuItemAction {
    
    private let service: PokémonService
    
    let title: String = LocalizedString.title.value
    
    var image: UIImage? { UIImage(systemName: "photo") }
    
    init(service: PokémonService) {
        self.service = service
    }
}

extension ViewPokémonSpritesAction {
    
    func viewController(for pokémon: Pokémon) -> UIViewController {
        
        return PokémonSpritesViewController(pokémon: pokémon, service: service)
    }
}

extension ViewPokémonSpritesAction {
    
    private enum LocalizedString: String {
        case title = "pokemon-sprites-action.title.text"
                
        var value: String { Bundle.module.localizedString(forKey: rawValue, comment: nil)}
    }
}
