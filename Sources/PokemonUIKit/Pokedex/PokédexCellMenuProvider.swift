import UIKit
import Combine

import PokemonFoundation

final class PokédexCellMenuProvider {
    
    private let menuItemActions: [PokédexMenuItemAction]
    
    let presentSubject = PassthroughSubject<(itemAction: PokédexMenuItemAction, indexPath: IndexPath), Never>()
    
    init(menuItemActions: [PokédexMenuItemAction]) {
        self.menuItemActions = menuItemActions
    }
}

extension PokédexCellMenuProvider {
    
    func menu(for cell: UITableViewCell, in tableView: UITableView) -> UIMenu? {
        guard menuItemActions.count > 0 else {
            return nil
        }
        
        let children: [UIMenuElement] = menuItemActions.enumerated().map {
            let index = $0.offset
            
            return UIAction(
                title: $0.element.title,
                image: $0.element.image,
                handler: { [weak self, weak cell, weak tableView] _ in
                    guard
                        let itemAction = self?.menuItemActions[index],
                        let indexPath = cell.flatMap({ tableView?.indexPath(for: $0) })
                    else {
                        return
                    }

                    self?.presentSubject.send((itemAction, indexPath))
                }
            )
        }
        
        return UIMenu(children: children)
    }
}
