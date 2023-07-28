//
//  CredentialsScanner.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 27.04.23.
//

import SwiftUI
import ComposableArchitecture
import CodeScanner

struct QrCode: Decodable, Equatable {
    let host: String
    let token: String
}

struct CredentialsScanner: Reducer {

    struct State: Equatable {
        var path = StackState<Path.State>()
        var qrCode: QrCode?
    }

    enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
        case qrCodeRead(qrCodeText: String)
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .qrCodeRead(qrCodeText):
                if let qrCodeData = qrCodeText.data(using: .utf8),
                   let qrCode = try? JSONDecoder().decode(QrCode.self, from: qrCodeData) {
                    state.qrCode = qrCode
                }

                return .none
            case .path(_):
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }

    struct Path: Reducer {
        enum State: Equatable {
          case browse(DepotBrowser.State)
        }

        enum Action: Equatable {
          case browse(DepotBrowser.Action)
        }

        var body: some ReducerOf<Self> {
          Scope(state: /State.browse, action: /Action.browse) {
              DepotBrowser()
          }
        }
      }
}

struct CredentialsScannerView: View {

    let simulatedData = """
        {
            "host":"https://depot.medizin.unibas.ch",
            "token":"token"
        }
        """

        let store: StoreOf<CredentialsScanner>

        var body: some View {
            NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
                WithViewStore(self.store, observe: { $0 }) { viewStore in
                    CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: simulatedData) { response in
                        if case let .success(result) = response {
                            let scannedCode = result.string
                            viewStore.send(.qrCodeRead(qrCodeText: scannedCode))
                        }
                    }
                }
            } destination: { _ in

            }

        }
}

struct CredentialsScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsScannerView(
            store: Store(initialState: CredentialsScanner.State()) {
                CredentialsScanner()
            }
        )
    }
}
