//
//  ContentView.swift
//  Test
//
//  Created by 小林聖人 on 2023/06/05.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: StoreOf<A>

    var body: some View {
        NavigationView {
            AView(store: store)
        }
    }
}

struct A: ReducerProtocol {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }

    enum Action: Equatable {
        case d
        case destination(PresentationAction<Destination.Action>)
    }

    struct Destination: ReducerProtocol {
        enum State: Equatable {
            case b(B.State)
        }

        enum Action: Equatable {
            case b(B.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(state: /State.b, action: /Action.b) {
                B()
            }
        }
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .d:
                state.destination = .b(.init())
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

struct AView: View {
    private let store: StoreOf<A>
    
    @ObservedObject private var viewStore: ViewStoreOf<A>

    init(store: StoreOf<A>) {
        self.store = store
        self.viewStore = .init(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            Button {
                viewStore.send(.d)
            } label: {
                Text("to b")
            }

            NavigationLinkStore(
                store.scope(state: \.$destination, action: A.Action.destination),
                state: /A.Destination.State.b,
                action: A.Destination.Action.b,
                onTap: {},
                destination: BView.init,
                label: EmptyView.init
            )
        }
    }
}

struct B: ReducerProtocol {
    struct State: Equatable {

    }

    enum Action: Equatable {
        case d
    }

    @Dependency(\.dismiss) private var dismiss

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .d:
                return .fireAndForget {
                    await dismiss()
                }
            }
        }
    }
}

struct BView: View {
    private let store: StoreOf<B>

    @ObservedObject private var viewStore: ViewStoreOf<B>

    init(store: StoreOf<B>) {
        self.store = store
        self.viewStore = .init(store, observe: { $0 })
    }

    var body: some View {
        Button {
            viewStore.send(.d)
        } label: {
            Text("dismiss")
        }
    }
}
