import Foundation


actor SessionTask {
    var state: State = .ready

    func set(for urlRequest: URLRequest, on session: URLSession,
               completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) {
        switch state {
        case .running(_), .ready:
            let task = session.dataTask(with: urlRequest, completionHandler: completionHandler)
            state = .running(task)
            task.resume()
        case .canceling:
            state = .canceling
            completionHandler(nil, nil, CancellationError())
            return
        }
    }

    func cancel() {
        if case .running(let task) = state {
            task.cancel()
        }
        state = .canceling
    }
}

extension URLSession {

    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let task = SessionTask()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await task.set(for: urlRequest, on: self) { data, response, error in
                        guard let data = data, let response = response
                        else {
                            continuation.resume(throwing: error ?? URLError(.networkConnectionLost))
                            return
                        }
                        continuation.resume(returning: (data, response))
                    }
                }
            }
        } onCancel: {
            Task { await task.cancel() }
        }
    }
}

