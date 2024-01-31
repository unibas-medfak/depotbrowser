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

@Reducer
struct CredentialsScanner {

    @ObservableState
    struct State: Equatable {
        var qrCode: QrCode?
    }

    enum Action: Equatable, Sendable {
        case qrCodeRead(qrCodeText: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
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

}

struct CredentialsScannerView: View {

    let simulatedData = """
        {
            "host":"https://depot.medizin.unibas.ch",
            "token":"token"
        }
        """

    @Bindable var store: StoreOf<CredentialsScanner>
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: simulatedData) { response in
            if case let .success(result) = response {
                let scannedCode = result.string
                store.send(.qrCodeRead(qrCodeText: scannedCode))
            }
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
