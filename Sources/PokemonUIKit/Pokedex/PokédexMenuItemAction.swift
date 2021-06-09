import UIKit

import PokemonFoundation

/// A `protocol` describing the minimum requirements of
/// displaying `Pokémon`-related content when a `UIMenuElement` is tapped.
///
/// - Important: Subclasses of this `protocol` will be a foundational requirement
/// of __ALL__ course projects.
public protocol PokédexMenuItemAction: AnyObject {
        
    var title: String { get }
    
    var image: UIImage? { get }
    
    func viewController(for pokémon: Pokémon) -> UIViewController
}
