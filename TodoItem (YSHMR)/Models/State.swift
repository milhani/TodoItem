import Foundation


enum State {
    case ready
    case running(URLSessionTask)
    case canceling
}
