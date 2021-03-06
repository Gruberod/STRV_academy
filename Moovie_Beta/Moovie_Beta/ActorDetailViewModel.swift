//
//  ActorListViewModel.swift
//  Moovie_Beta
//
//  Created by Gruberova, Daniela on 25/08/2017.
//  Copyright © 2017 Gruberova, Daniela. All rights reserved.
//

import Foundation

protocol ActorDetailItem {
    var name: String { get }
    var bio: String { get }
    var birthday: String { get }
    var picture: URL? { get }
    var placeOfBirth: String { get }
    var acting: [APIActorActing] { get }
    var knownFor: [APIActorKnownFor] { get }
}

struct ActorFull {
    var name: String
    var bio: String
    var birthday: String
    var picture: URL?
    var placeOfBirth: String
    var acting: [APIActorActing]
    var knownFor: [APIActorKnownFor]
    var movieStub: [MovieStub]
}

protocol ActorDetailViewModelDelegate: class {
    func viewModelItemsUpdated()
    func viewModelChangedState(state: ActorDetailViewModel.State)
}

class ActorDetailViewModel {
    enum State {
        case empty
        case loading
        case ready
        case error
    }
    
    let actorSource: ActorSource
    var actor: ActorFull?
    
    var state: State = .empty {
        didSet {
            if state != oldValue {
                delegate?.viewModelChangedState(state: state)
            }
        }
    }
    
    var error: Error?
    
    weak var delegate: ActorDetailViewModelDelegate?
    
    init(actorSource: ActorSource = AlamofireActorSource()) {
        self.actorSource = actorSource
    }
    
    func getActorDetail(id: Int) {
        
        self.actorSource.fetchActorDetail(id: id) { [weak self] result in
            
            guard let `self` = self else {
                return
            }
            
            if let value = result.value {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .none
                dateFormatter.dateStyle = .medium
                
                self.actor = ActorFull(
                    name: value.name,
                    bio: value.bio,
                    birthday: dateFormatter.string(from: value.birthday),
                    picture: value.url(size: .w500),
                    placeOfBirth: value.placeOfBirth,
                    acting: value.acting,
                    knownFor: value.knownFor,
                    movieStub: value.knownFor.map { value.makeMovieStub(data: $0) }
                )
                
                self.state = .ready
                self.delegate?.viewModelItemsUpdated()
                
            } else {
                self.error = result.error
                self.state = .error
            }
        }
    }
}
