//
//  MoviesAPI.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

enum MoviesAPI {
    case topRated(lanuguage: String, page: Int, region: String)
}

extension MoviesAPI: APIRequest {
    var requiresAuthentication: Bool {
        return true
    }
    
    var path: String {
        return "api.themoviedb.org/3/movie/top_rated"
    }
    
    var method: HTTPMethod {
        return .get
    }
}
