import Combine
import Foundation
import UIKit

final class FoodListViewModel {
    
    enum State {
        case done([Food])
        case emptyResult
        case failedLoading(Error)
        case loading
        case notStarted
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var items = [Food]()
    var searchText = CurrentValueSubject<String, Never>("")
    var state = CurrentValueSubject<State, Never>(.notStarted)
    
    init() {
        setUpSearch()
    }

    func setUpSearch() {
        self.searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .filter { $0.count > 2 }
            .map { [weak self] text -> AnyPublisher<[Food], Error> in
                self?.state.send(.loading)
                return FoodService.getFoodItems(for: text)
            }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { publisher in
                publisher.sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case let .failure(error):
                        self.state.send(.failedLoading(error))
                    case .finished:
                        self.state.send(.done(self.items))
                    }
                } receiveValue: { [weak self] items in
                    guard let self = self else { return }
                    self.items = items
                    if items.count == 0 {
                        self.state.send(.emptyResult)
                    }
                }.store(in: &self.cancellables)
            }).store(in: &cancellables)
            
    }
    
    func clearSearchResult() {
        self.items = []
        self.state.send(.done(items))
    }
 
    func numberOfSections() -> Int {
        return items.count > 0 ? 1 : 0
    }
    
    func numberOfRows(in section: Int) -> Int {
        return items.count
    }
    
    func item(at indexPath: IndexPath) -> Food {
        return items[indexPath.row]
    }
}

extension FoodListViewModel {
    internal enum ValidationMessage: String {
        case error
        case intro
        case noResult
        case searching
        case tooShort
    }
}

extension FoodListViewModel.ValidationMessage {
    func localizedString() -> String {
        switch self {
        case .error:
            return NSLocalizedString("Something went wrong, try again!", comment: "")
        case .intro:
            return NSLocalizedString("Search For Your Fav Food Here...", comment: "")
        case .noResult:
            return NSLocalizedString("No results found for your search query", comment: "")
        case .searching:
            return NSLocalizedString("Searching...", comment: "")
        case .tooShort:
            return NSLocalizedString("Search query must be 3 characters long", comment: "")
        }
    }
}
