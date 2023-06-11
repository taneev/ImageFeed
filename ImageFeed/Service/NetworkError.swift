//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

enum NetworkError: Error {
    case serverError(Int)
    case transportError(Error)
    case decodeError(Error)
    case sessionError
}
