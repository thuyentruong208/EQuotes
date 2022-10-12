//
//  APIClient.swift
//  EQuotes
//
//  Created by Thuyên Trương on 18/09/2022.
//

import Foundation
import Combine

protocol APIClient {
    func buildRequest<T: Encodable>(method: String?,
                       path: String,
                       headers: [String: String]?,
                       queryItems: [String: String]?,
                       formData: FormData?,
                                    body: T?) -> URLRequest

    func executeRequest(_ request: URLRequest,
                        retries: Int,
                        cacheTime: Int) -> AnyPublisher<Data, Error>
    func executeRequest<T: Decodable>(_ request: URLRequest,
                                      expectType _: T.Type,
                                      retries: Int,
                                      cacheTime: Int) -> AnyPublisher<T, Error>
    func executeRequest<T: Decodable>(_ request: URLRequest,
                                      expectType _: T.Type,
                                      decoder: JSONDecoder,
                                      retries: Int,
                                      cacheTime: Int) -> AnyPublisher<T, Error>

}

extension APIClient {
    func buildRequest<T: Encodable>(method: String? = "GET",
                      path: String,
                      headers: [String: String]? = nil,
                      queryItems: [String: String]? = nil,
                      formData: FormData? = nil,
                      body: T? = nil) -> URLRequest {

        return buildRequest(method: method,
                            path: path,
                            headers: headers,
                            queryItems: queryItems,
                            formData: formData,
                            body: body)
    }

    func executeRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        executeRequest(request, retries: 0, cacheTime: 0)
            .eraseToAnyPublisher()
    }

    func executeRequest<T>(_ request: URLRequest,
                           expectType _: T.Type,
                           retries: Int = 1,
                           cacheTime: Int = 0) -> AnyPublisher<T, Error> where T: Decodable {
        executeRequest(request, retries: retries, cacheTime: cacheTime)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func executeRequest<T>(_ request: URLRequest,
                           expectType _: T.Type,
                           decoder: JSONDecoder,
                           retries: Int = 1,
                           cacheTime: Int = 0) -> AnyPublisher<T, Error> where T: Decodable {
        executeRequest(request, retries: retries, cacheTime: cacheTime)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

class RealAPIClient: APIClient {



    // MARK: - Properties
    fileprivate let baseURL: URL
    fileprivate let session: URLSession

    fileprivate static let logFilterRegex = #""[^"]*(key|id|jwt|address|descriptor|signature|password|email|phone|shard|secret|receipt_data)[^"]*"\s*:\s*("[^"]*"|\d+(.\d+)|\[[^\]]*\]|\{[^\{]*\}),*"#

    init(baseURLString: String, session: URLSession = APIClientProvider.session) {
        guard let baseURL = URL(string: baseURLString) else {
            fatalError("invalid endpoint")
        }

        self.baseURL = baseURL
        self.session = session
    }

    func buildRequest<T: Encodable>(method: String?,
                      path: String,
                      headers: [String : String]?,
                      queryItems: [String : String]?,
                      formData: FormData?,
                    body: T?) -> URLRequest {

        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("invalid base url")
        }

        urlComponents.path += path
        if let queryItems = queryItems {
            var items = [URLQueryItem]()
            for (key, value) in queryItems {
                items.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = items
        }

        guard let url = urlComponents.url else {
            fatalError("invalid url")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = headers {
            for (k, v) in headers {
                urlRequest.addValue(v, forHTTPHeaderField: k)
            }
        }

        if let body = body {
            // if there is the body, attach -H "Content-Type: application/json"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .withoutEscapingSlashes
            urlRequest.httpBody = try? jsonEncoder.encode(
                body
            )
        } else if let formData = formData {
            let boundary = UUID().uuidString
            urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            var body = [UInt8]()
            body.append(contentsOf: "--\(boundary)\r\n".utf8)
            body.append(contentsOf: "Content-Disposition:form-data; name=\"\(formData.name)\"; filename=\"\(formData.name)\"\r\n".utf8)
            body.append(contentsOf: "Content-Type: \(formData.contentType)\r\n\r\n".utf8)
            body.append(contentsOf: formData.data)
            body.append(contentsOf: "\r\n".utf8)
            body.append(contentsOf: "--\(boundary)--\r\n".utf8)
            urlRequest.httpBody = Data(body)
        }

        return urlRequest
    }

    func executeRequest(_ request: URLRequest,
                        retries: Int = 1,
                        cacheTime: Int = 0) -> AnyPublisher<Data, Error> {
        Deferred { Just(()) }
            .setFailureType(to: Error.self)
            .flatMap { [unowned self] _ -> AnyPublisher<(Data, URLResponse), Error> in
                // fetch from Cache if available
                if let cachedResponse = session.configuration.urlCache?.cachedResponse(for: request),
                   let httpResponse = cachedResponse.response as? HTTPURLResponse,
                   let date = httpResponse.value(forHTTPHeaderField: "Date")?.formatDate(),
                   date.advanced(by: TimeInterval(cacheTime)) > Date() {

                    return Just((cachedResponse.data, httpResponse))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                // make the remote request
                return session
                    .dataTaskPublisher(for: request)
                    .mapError { $0 as Error }
                    .map { data, response in
                        (data, response)
                    }
                    .eraseToAnyPublisher()
            }
            .retry(retries)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponseFormat
                }

                DispatchQueue.global().async {
                    logger.debug("------------REQUEST FROM SERVER------------")
                    logger.info("\(request.curlString)")
                    logger.debug("------------RESPONSE FROM SERVER------------")
                    if 400 ..< 600 ~= httpResponse.statusCode {
                        logger.error("HTTP Status code: \(httpResponse.statusCode) | \(String(data: data, encoding: .utf8) ?? "")")
                        logger.debug("------------END RESPONSE FROM SERVER------------")
                    } else {
#if DEBUG
                        logger.info("HTTP Status code: \(httpResponse.statusCode) | \(String(data: data, encoding: .utf8) ?? "")")
#else
                        do {
                            if !Self.logIgnoreEndpoints.contains(where: { request.url?.absoluteString.contains($0) ?? false }),
                               let responseStr = String(data: data, encoding: .utf8) {
                                let regex = try NSRegularExpression(pattern: APIClient.logFilterRegex, options: .caseInsensitive)
                                let logStr = regex.stringByReplacingMatches(in: responseStr,
                                                                            range: NSRange(location: 0, length: responseStr.count),
                                                                            withTemplate: "")
                                logger.info("HTTP Status code: \(httpResponse.statusCode) | \(logStr)")
                            } else {
                                logger.info("HTTP Status code: \(httpResponse.statusCode) ... ")
                            }
                        } catch {
                            logger.error("Error parsing response for logging")
                        }
#endif
                        logger.debug("------------END RESPONSE FROM SERVER------------")
                    }
                }

                if 400 ..< 600 ~= httpResponse.statusCode {
                    if httpResponse.statusCode == 404 {
                        throw APIError.notFound
                    } else {
                        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                        throw APIError.apiError(code: errorResponse.error.code,
                                                reason: errorResponse.error.message)
                    }
                }

                return data
            }
            .eraseToAnyPublisher()
    }
}

extension URLRequest {
    var curlString: String {

        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: RealAPIClient.logFilterRegex, options: .caseInsensitive)
        } catch {
            logger.error("Error parsing response for logging")
        }

        var result = ""

        result += "curl -k "

        if let method = httpMethod {
            result += "-X \(method) \\\n"
        }

#if DEBUG
        if let headers = allHTTPHeaderFields {
            for (header, value) in headers {
                result += "-H \"\(header): \(value)\" \\\n"
            }
        }

        if let body = httpBody, !body.isEmpty, let string = String(data: body, encoding: .utf8), !string.isEmpty {
            result += "-d '\(string)' \\\n"
        }
#else
        if let regex = regex {
            if let headers = allHTTPHeaderFields {
                for (header, value) in headers {
                    let headerLog = regex.stringByReplacingMatches(in: value,
                                                                   range: NSRange(location: 0, length: value.count),
                                                                   withTemplate: "")
                    result += "-H \"\(header): \(headerLog)\" \\\n"
                }
            }

            if let body = httpBody, !body.isEmpty, let string = String(data: body, encoding: .utf8), !string.isEmpty {
                let bodyLog = regex.stringByReplacingMatches(in: string,
                                                             range: NSRange(location: 0, length: string.count),
                                                             withTemplate: "")
                result += "-d '\(bodyLog)' \\\n"
            }
        }
#endif

        if let url = url {
            result += url.absoluteString
        }

        return result
    }
}
