import Combine
import Foundation

class FoodService {
    
    static var jsonDecoder: JSONDecoder {
        get {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }
    }
    
    struct APIResources {
        
        static var searchEndpoint = "https://uih0b7slze.execute-api.us-east-1.amazonaws.com/dev/search"
        static var searchQueryParam = "kv"
        
        enum APIError: Error, CustomStringConvertible {
            var description: String {
                return ""
            }
            
            case badResponse(statusCode: Int)
            case unknown(Error)
            case url(URLError?)
            case missingURL
            
            static func covert(error: Error) -> APIError {
                switch error {
                case is URLError:
                    return .url(error as? URLError)
                default:
                    return .unknown(error)
                }
            }
        }
    }
    
    static func getFoodItems(for searchText: String) -> AnyPublisher<[Food], Error> {
        
        var components = URLComponents(string: APIResources.searchEndpoint)
        components?.queryItems = [URLQueryItem(name: APIResources.searchQueryParam, value: searchText)]
        guard let url = components?.url else {
            return Fail(error: APIResources.APIError.missingURL).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw APIResources.APIError.badResponse(statusCode: response.statusCode)
                }
                else {
                    return data
                }
            }
            .mapError({ error in
                APIResources.APIError.covert(error: error)
            })
            .receive(on: RunLoop.main)
            .decode(type: [Food].self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
}
