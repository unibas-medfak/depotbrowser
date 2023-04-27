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
        var qrCode: QrCode?
    }

    enum Action: Equatable, Sendable {
        case qrCodeRead(qrCodeText: String)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .qrCodeRead(qrCodeText):
            if let qrCodeData = qrCodeText.data(using: .utf8),
               let qrCode = try? JSONDecoder().decode(QrCode.self, from: qrCodeData) {
                state.qrCode = qrCode
            }

            return .none
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
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: simulatedData) { response in
                    if case let .success(result) = response {
                        let scannedCode = result.string
                        viewStore.send(.qrCodeRead(qrCodeText: scannedCode))
                    }
                }
            }
        }
}

struct CredentialsScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsScannerView(
            store: Store(initialState: CredentialsScanner.State(), reducer: CredentialsScanner())
        )
    }
}
