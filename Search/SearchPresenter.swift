//
//  SearchPresenter.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 13.03.22.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
  func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
  weak var viewController: SearchDisplayLogic?
  
  func presentData(response: Search.Model.Response.ResponseType) {
      switch response {
      case .some:
          print("presenter .some")
      case .presentTracks(let responseResults):
          let cells = responseResults?.results.map({ (track) in
              cellViewModel(from: track)
          }) ?? []
          let searchViewModel = SearchViewModel(cells: cells)
          print("presenter .presentTracks")
          viewController?.displayData(viewModel: Search.Model.ViewModel.ViewModelData.displayTracks(searchViewModel: searchViewModel))
          
      case .presentFooterView:
          viewController?.displayData(viewModel: Search.Model.ViewModel.ViewModelData.displayFooterView)
      }
  
  }
    
    private func cellViewModel(from track: Track) -> SearchViewModel.Cell {
        
        return SearchViewModel.Cell.init(iconUrlString: track.artworkUrl100 ?? "",
                                         trackName: track.trackName,
                                         collectionName: track.collectionName ?? "",
                                         artistName: track.artistName,
                                         previewUrl: track.previewUrl)
    }
  
}
