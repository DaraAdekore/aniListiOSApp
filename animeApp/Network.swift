import Foundation
import Apollo
import UIKit

class Network {
    static let shared = Network()
    
    
    private(set) lazy var apollo = ApolloClient(url: URL(string: "https://graphql.anilist.co/")!)
    
}
