import UIKit
import Combine

import PokemonFoundation

/// A `RefreshController` implementation for refreshing `Pokédex` content.
final class PokédexRefreshController: RefreshController {
    
    private let service: PokémonService
    private var cancellables = Set<AnyCancellable>()
    
    private(set) lazy var refreshControl = UIRefreshControl(
        frame: .zero,
        primaryAction: UIAction { [weak self] _ in self?.refresh(animated: true) }
    )
    
    let entriesSubject = PassthroughSubject<[Pokédex.Entry], Never>()
    
    init(service: PokémonService) {
        self.service = service
    }
}

extension PokédexRefreshController {
    
    func refresh(animated: Bool) {
        if animated {
            DispatchQueue.main.async { [weak self] in
                guard self?.refreshControl.isRefreshing == false else {
                    return
                }
                
                self?.refreshControl.beginRefreshing()
            }
        }
        
        service.pokédexPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let entries = (try? $0.get())?.entries ?? []
                self?.entriesSubject.send(entries)
                
                if animated, self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
}
