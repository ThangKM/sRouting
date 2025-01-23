//
//  OnDialogOfRouter.swift
//  sRouting
//
//  Created by Thang Kieu on 24/1/25.
//

import SwiftUI

struct DialogRouterModifier<Route>: ViewModifier where Route: SRRoute {
    
    private let dialogRoute: Route.ConfirmationDialogRoute
    private let router: SRRouter<Route>
    @Environment(\.scenePhase) private var scenePhase
    
    /// Active state of action sheet
    @State private(set) var isActiveDialog: Bool = false
  
    @MainActor
    private var dialogTitleKey: LocalizedStringKey {
        router.transition.confirmationDialog?.titleKey ?? ""
    }
    
    @MainActor
    private var dialogTitleVisibility: Visibility {
        router.transition.confirmationDialog?.titleVisibility ?? .hidden
    }
    
    @MainActor
    private var dialogActions: some View {
        router.transition.confirmationDialog?.actions
    }
    
    @MainActor
    private var dialogMessage: some View {
        router.transition.confirmationDialog?.message
    }
    
    init(router: SRRouter<Route>, dialog: Route.ConfirmationDialogRoute) {
        self.router = router
        self.dialogRoute = dialog
    }
    
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
            .confirmationDialog(dialogTitleKey,
                                isPresented: $isActiveDialog,
                                titleVisibility: dialogTitleVisibility,
                                actions: {
                dialogActions
            }, message: {
                dialogMessage
            })
            .onChange(of: router.transition, { oldValue, newValue in
                guard newValue.type == .confirmationDialog
                        && UIDevice.current.userInterfaceIdiom == .pad
                        && newValue.confirmationDialog?.stringMessage == dialogRoute.stringMessage else { return }
                isActiveDialog = true
            })
            .onChange(of: isActiveDialog, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
        } else {
            content
        }
    }
}
 
extension DialogRouterModifier {
    @MainActor
    private func resetRouterTransiton() {
        guard scenePhase != .background else { return }
        router.resetTransition()
    }
}

extension View {
    
    /// Show confirmation dialog on iPad at the anchor view.
    /// - Parameters:
    ///   - router: ``SRRouter``
    ///   - dialog: ``ConfirmationDialogEmptyRoute``
    /// - Returns: `some View`
    public func onDialogRouting<Route: SRRoute>(of router: SRRouter<Route>, for dialog: Route.ConfirmationDialogRoute) -> some View {
        self.modifier(DialogRouterModifier(router: router, dialog: dialog))
    }
}
