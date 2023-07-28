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
        var files = [DepotEntry]()
    }

    enum Action: Equatable {
        case initState
        case backButtonTapped
        case folderTapped(String)
        case fileTapped(String)
        case depotListResponse(TaskResult<[DepotEntry]>)
        case depotGetResponse(TaskResult<Data>)
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .initState:
                return .run { [path = state.path] send in
                    await send(
                        .depotListResponse(
                            TaskResult { try await self.depot.list(path: path) }
                        )
                    )
                }
            case .backButtonTapped:
                state.path.removeLast()
                return .run { [path = state.path] send in
                    await send(
                        .depotListResponse(
                            TaskResult { try await self.depot.list(path: path) }
                        )
                    )
                }
            case let .folderTapped(folder):
                state.path.append(folder)
                return .run { [path = state.path] send in
                    await send(
                        .depotListResponse(
                            TaskResult { try await self.depot.list(path: path) }
                        )
                    )
                }
            case let .fileTapped(file):
                var fullPath = state.path
                fullPath.append(file)
                return .run { [path = state.path] send in
                    await send(
                        .depotListResponse(
                            TaskResult { try await self.depot.list(path: path) }
                        )
                    )
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
            store: Store(initialState: DepotBrowser.State()) {
                DepotBrowser()
            }
        )
    }
}
