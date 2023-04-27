//
//  DepotBrowser.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 26.04.23.
//

import SwiftUI
import ComposableArchitecture

struct DepotBrowser: Reducer {

    @Dependency(\.depot) var depot

    struct State: Equatable {
        var path = [String]()
        var files = [FileDto]()
    }

    enum Action: Equatable {
        case initState
        case backButtonTapped
        case folderTapped(String)
        case fileTapped(String)
        case depotListResponse(TaskResult<[FileDto]>)
        case depotGetResponse(TaskResult<Data>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .initState:
            return .task { [path = state.path] in
                await .depotListResponse(TaskResult { try await self.depot.list(path) })
            }
        case .backButtonTapped:
            state.path.removeLast()
            return .task { [path = state.path] in
                await .depotListResponse(TaskResult { try await self.depot.list(path) })
            }
        case let .folderTapped(folder):
            state.path.append(folder)
            return .task { [path = state.path] in
                await .depotListResponse(TaskResult { try await self.depot.list(path) })
            }
        case let .fileTapped(file):
            var fullPath = state.path
            fullPath.append(file)
            return .task { [fullPath = fullPath] in
                await .depotGetResponse(TaskResult { try await self.depot.get(fullPath) })
            }
        case let .depotListResponse(.success(response)):
            state.files = response
            return .none
        case .depotListResponse(.failure(_)):
            return .none
        case let .depotGetResponse(.success(response)):
            print(response.count)
            return .none
        case .depotGetResponse(.failure(_)):
            return .none
        }
    }

}

struct DepotBrowserView: View {
    let store: StoreOf<DepotBrowser>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                List {
                    HStack {
                        Text(viewStore.path.last ?? "/").font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            viewStore.send(.backButtonTapped)
                        } label: {
                            Image(systemName: "arrowshape.turn.up.backward")
                        }
                        .frame(maxWidth: 10, alignment: .trailing)
                        .disabled(viewStore.path.isEmpty)
                    }

                    ForEach(viewStore.files) { file in
                        if file.type == .FOLDER {
                            Button() {
                                viewStore.send(.folderTapped(file.name))
                            } label: {
                                HStack {
                                    Image(systemName: "folder").foregroundColor(.gray)
                                    Text(file.name).foregroundColor(.gray)
                                }
                            }
                        }
                        else {
                            Button() {
                                viewStore.send(.fileTapped(file.name))
                            } label: {
                                HStack {
                                    Image(systemName: "doc")
                                    Text(file.name)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.initState)
            }
        }
    }
}

struct DepotBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        DepotBrowserView(
            store: Store(initialState: DepotBrowser.State(), reducer: DepotBrowser())
        )
    }
}
