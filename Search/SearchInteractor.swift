//
//  SearchInteractor.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 13.03.22.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
  func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var networkManager = NetworkManager()

  var presenter: SearchPresentationLogic?
  var service: SearchService?
  
  func makeRequest(request: Search.Model.Request.RequestType) {
    if service == nil {
      service = SearchService()
    }
      switch request {
          
      case .some:
          print("interactor .some")
      case .getTracks(let searchText):
          print("interactor .getTracks")
          presenter?.presentData(response: Search.Model.Response.ResponseType.presentFooterView)
          networkManager.fetchTracks(searchText: searchText) { [weak self] responseResults in
              self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(responseResults: responseResults))
          }
      }
  }
}
