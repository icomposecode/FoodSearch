import Anchorage
import Combine
import UIKit

class FoodListViewController: UIViewController {
    
    weak var coordinator: AppCoordinator?
    
    fileprivate var searchController: UISearchController = {
        let search = UISearchController()
        search.automaticallyShowsSearchResultsController = true
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = NSLocalizedString("Search here e.g. chicken", comment: "")
        return search
    }()
    
    fileprivate var subscription = Set<AnyCancellable>()
    private var viewModel = FoodListViewModel()
    
    fileprivate var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FoodItemCell.self, forCellReuseIdentifier: FoodItemCell.identifier)
        return tableView
    }()
    
    fileprivate var statusLabel: UILabel = {
        let label = UILabel()
        label.text = FoodListViewModel.ValidationMessage.intro.localizedString()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpSearchController()
        bindViewModel()
        bindSearchBarListners()
    }
}

extension FoodListViewController {
    
    fileprivate func setUpView() {
        view.addSubview(tableView)
        tableView.centerAnchors == view.centerAnchors
        tableView.widthAnchor == view.widthAnchor
        tableView.heightAnchor == view.heightAnchor
        tableView.dataSource = self
        tableView.delegate = self
        
        statusLabel.sizeAnchors == CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    fileprivate func setUpSearchController() {
        searchController.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = searchController
    }
    
    fileprivate func bindViewModel() {
        viewModel.state.sink {[weak self] state in
            guard let self = self else { return }
            switch state {
            case .notStarted:
                self.show(message: .intro)
            case .loading:
                self.show(message: .searching)
            case let .done(items):
                if items.count > 0 {
                    self.tableView.tableFooterView = nil
                }
                self.tableView.reloadData()
            case .failedLoading(_):
                self.show(message: .error)
            case .emptyResult:
                self.show(message: .noResult)
            }
        }.store(in: &subscription)
    }
    
    fileprivate func bindSearchBarListners() {
        let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: nil)
        publisher.compactMap { notification in
            (notification.object as? UISearchTextField)?.text
        }
        .sink(receiveValue: { [weak self] text in
            guard let self = self else { return }
            if text.count < 3 {
                self.viewModel.clearSearchResult()
                self.statusLabel.text = FoodListViewModel.ValidationMessage.tooShort.localizedString()
            }
            
            self.viewModel.searchText.send(text)
        })
        .store(in: &subscription)
    }
}

extension FoodListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodItemCell.identifier, for: indexPath)
        cell.textLabel?.text = viewModel.item(at: indexPath).name
        return cell
    }
}

extension FoodListViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.clearSearchResult()
        show(message: .intro)
    }
}

extension FoodListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFoodName(for: viewModel.item(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FoodListViewController {
    fileprivate func show(message: FoodListViewModel.ValidationMessage) {
        statusLabel.text = message.localizedString()
        tableView.tableFooterView = statusLabel
    }
    
    fileprivate func showFoodName(for item: Food) {
        let alert = UIAlertController(title: NSLocalizedString("You have selected", comment: ""), message: item.name, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "")
        let action = UIAlertAction(title: title, style: .cancel) {[weak self]action in
            self?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
