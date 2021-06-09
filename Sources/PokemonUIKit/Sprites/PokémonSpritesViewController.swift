import UIKit
import Combine

import CommonKit
import PokemonFoundation

final class PokémonSpritesViewController: UIViewController {
    
    private lazy var tableView = lazyTableView()
    private lazy var activityIndicator = lazyActivityIndicator()
    
    private let pokémon: Pokémon
    private let service: PokémonService
    
    private var groups: [Pokémon.Sprites.DisplayGroup] = []
    private let decorator: PokémonSpritesCellDecorator
    
    private var subscription: AnyCancellable?
        
    init(pokémon: Pokémon, service: PokémonService) {
        self.pokémon = pokémon
        self.service = service
        decorator = PokémonSpritesCellDecorator()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PokémonSpritesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = LocalizedString.title.value
        view.backgroundColor = .systemBackground
                
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.constrain(to: view)
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.constrain(to: view)
        
        fetch(pokémon.sprites)
    }
}

extension PokémonSpritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokémonSpritesCellDecorator.Cell = tableView.dequeueReusableCell(for: indexPath)!
        let group = groups[indexPath.row]
        
        decorator.decorate(cell, for: tableView, using: group)

        return cell
    }
}

extension PokémonSpritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        let detailViewController = PokémonSpritesDetailViewController(group: group)

        tableView.deselectRow(at: indexPath, animated: true)
        show(detailViewController, sender: self)
    }
            
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //swiftlint:disable:next:force_cast
        decorator.tearDown(cell, for: tableView)
    }
}

extension PokémonSpritesViewController {
    
    private func fetch(_ sprites: Pokémon.Sprites?) {
        guard let sprites = sprites else {
            tableView.addEmptyListLabel(withText: LocalizedString.noSprites.value, reload: true)
            return
        }
        
        DispatchQueue.main.async { [weak self] in self?.activityIndicator.startAnimating() }
        
        subscription = service.publisher(for: sprites)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if self?.activityIndicator.isAnimating == true {
                    self?.activityIndicator.stopAnimating()
                }
                
                switch result {
                case .success(let groups):
                    let validGroups = groups.filter { !$0.images.isEmpty }
                    
                    let (primary, secondary): ([Pokémon.Sprites.DisplayGroup], [Pokémon.Sprites.DisplayGroup]) = validGroups
                        .reduce(into: ([], [])) { $1.isPrimary ? $0.0.append($1) : $0.1.append($1) }
                    
                    self?.groups = primary + secondary.sorted { $0.id.lowercased() < $1.id.lowercased() }

                    self?.tableView.removeEmptyListLabel(reload: true)
                    
                case .failure(let error):
                    self?.tableView.addEmptyListLabel(withText: error.localizedDescription, reload: true)
                }
            }
    }
}

extension PokémonSpritesViewController {
    
    private func lazyTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        decorator.configure(tableView)
        
        return tableView
    }
    
    private func lazyActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }
}

extension PokémonSpritesViewController {
    
    private enum LocalizedString: String {
        case title = "pokemon-sprites-viewcontroller.title.text"
        case noSprites = "pokemon-sprites-action.none-available.text"
        
        var value: String { Bundle.module.localizedString(forKey: rawValue, comment: nil)}
    }
}
