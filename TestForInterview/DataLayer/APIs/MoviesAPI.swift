//
//  MoviesAPI.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

enum MoviesAPI {
    case topRated(language: String, page: Int32, region: String)
    case movieDetails(movieId: Int32, language: String)
}

extension MoviesAPI: APIRequest {
    var requiresAuthentication: Bool {
        return true
    }
    
    var path: String {
        switch self {
        case .topRated:
            return "api.themoviedb.org/3/movie/top_rated"
        case .movieDetails(movieId: let movieId, _):
            return "api.themoviedb.org/3/movie/\(movieId)"
        }
    }
    
    var parametrs: Parameters? {
        switch self {
        case .topRated(let language, let page, let region):
            return [
                "language": language,
                "page": page,
                "region": region
            ]
        case .movieDetails(_, let language):
            return ["language": language]
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
