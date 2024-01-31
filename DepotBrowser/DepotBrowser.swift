//
//  DepotBrowser.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 26.04.23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct DepotBrowser {

    @Dependency(\.depot) var depot

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State? = nil
        var path = [String]()
        var files = [FileDto]()
    }

    enum Action {
        case scanButtonTapped
        case dismissScanButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case initState
        case backButtonTapped
        case folderTapped(String)
        case fileTapped(String)
        case depotListResponse([FileDto])
        case depotGetResponse(Data)
    }
    
    @Reducer
      struct Destination {
        @ObservableState
        enum State: Equatable {
            case scan(CredentialsScanner.State)
        }

        enum Action {
            case scan(CredentialsScanner.Action)
        }

        var body: some Reducer<State, Action> {
          Scope(state: \.scan, action: \.scan) {
            CredentialsScanner()
          }
        }
      }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .scanButtonTapped:
                state.destination = .scan(CredentialsScanner.State())
                return .none
            case .dismissScanButtonTapped:
                state.destination = nil
                return .none
            case .destination:
                    return .none
            case .initState:
                return .run { [path = state.path] send in
                    try await send(.depotListResponse(self.depot.list(path)))
                }
            case .backButtonTapped:
                state.path.removeLast()
                return .run { [path = state.path] send in
                    try await send(.depotListResponse(self.depot.list(path)))
                }
            case let .folderTapped(folder):
                state.path.append(folder)
                return .run { [path = state.path] send in
                    try await send(.depotListResponse(self.depot.list(path)))
                }
            case let .fileTapped(file):
                var fullPath = state.path
                fullPath.append(file)
                return .run { [fullPath = fullPath] send in
                    try await send(.depotGetResponse(self.depot.get(fullPath)))
                }
            case let .depotListResponse(response):
                state.files = response
                return .none
            case let .depotGetResponse(data):
                print(data.count)
                return .none
            }
        }
    }

}

struct DepotBrowserView: View {
    @Bindable var store: StoreOf<DepotBrowser>

    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text(store.path.last ?? "/").font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        store.send(.backButtonTapped)
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    }
                    .frame(maxWidth: 10, alignment: .trailing)
                    .disabled(store.path.isEmpty)
                }
                
                ForEach(store.files) { file in
                    if file.type == .FOLDER {
                        Button() {
                            store.send(.folderTapped(file.name))
                        } label: {
                            HStack {
                                Image(systemName: "folder").foregroundColor(.gray)
                                Text(file.name).foregroundColor(.gray)
                            }
                        }
                    }
                    else {
                        Button() {
                            store.send(.fileTapped(file.name))
                        } label: {
                            HStack {
                                Image(systemName: "doc")
                                Text(file.name)
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button {
                    store.send(.scanButtonTapped)
                } label: {
                    Image(systemName: "qrcode")
                }
            }
        }
        .sheet(item: $store.scope(state: \.destination?.scan, action: \.destination.scan)) { store in
            NavigationStack {
                CredentialsScannerView(store: store)
                    .navigationTitle("Scan Depot QR-Code")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                self.store.send(.dismissScanButtonTapped)
                            } label: {
                                Image(systemName: "arrowshape.turn.up.backward")
                            }
                            
                        }
                    }
            }
        }
        .onAppear {
            store.send(.initState)
        }
    }
}

struct DepotBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        DepotBrowserView(
            store: Store(initialState: DepotBrowser.State()) {
                DepotBrowser()
            }
        )
    }
}
