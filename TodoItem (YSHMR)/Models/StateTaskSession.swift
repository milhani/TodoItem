import Foundation


enum StateTaskSession {
    case ready
    case running(URLSessionTask)
    case canceling
}
