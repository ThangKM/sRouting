//
//  BookieNavigationView.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct BookieNavigationModifier: ViewModifier {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SRNavigationPath.self) var navigation: SRNavigationPath?
    @State private var haveNavigation: Bool = false
    let title: String
    
    private var isBack: Bool {
        (navigation?.pathsCount ?? 0) > 0
    }
    
    func body(content: Content) -> some View {
        ZStack {
            NavigationDetector(haveNavigation: $haveNavigation)
            navigationStyledBody
            customHeaderForNoNavigation(content: content)
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundColor(Color.white)
                    .abeeFont(size: 19, style: .italic)
            }
            
            if isBack {
                ToolbarItem(placement: .topBarLeading) {
                    Image("ic.navi.back")
                        .frame(width: 24)
                        .opacity( isBack ? 1 : 0)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        })
        .navigationBarBackButtonHidden()
        .toolbarTitleDisplayMode(.inline)
        .background(Color("backgournd.EEECFF"))
    }
}

extension BookieNavigationModifier {
    
    var navigationStyledBody: some View {
        GeometryReader { geo in
            LinearGradient(colors: [Color("purple.F66EB4"), Color("orgrian.FEB665")], startPoint: .leading, endPoint: .trailing)
            .frame(height: 152)
            .clipShape(Ellipse().path(in: .init(x:-((787 - geo.size.width)/2), y: -210/2, width: 787, height: 239)))
        }
        .clipped()
        .edgesIgnoringSafeArea(.top)
    }
    
    func customHeaderForNoNavigation(content: Content) -> some View {
        VStack {
            if !haveNavigation {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .abeeFont(size: 19, style: .italic)
                    .frame(height: 44)
                    .overlay(
                        Image(systemName: "multiply.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.red, Color.white)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                dismiss()
                            },
                        alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }
            content
            Spacer()
        }
    }
}

extension View {
    func bookieNavigation(title: String) -> some View {
        modifier(BookieNavigationModifier(title: title))
    }
}

struct NavigationDetector: UIViewRepresentable {
    
    @Binding var haveNavigation: Bool
    
    func makeCoordinator() -> DetectorViewDelegate {
        DetectorViewDelegate(viewRepresentable: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let detector = DetectorView()
        detector.detectorDelegate = context.coordinator
        return detector
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

final class DetectorView: UIView {
    
    weak var detectorDelegate: DetectorViewDelegate?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else  { return }
        guard let viewController = getViewController() else { return }
        detectorDelegate?.updateHaveNavigation(viewController.navigationController != nil)
        guard let navigationController = viewController.navigationController else { return }
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}

@MainActor
final class DetectorViewDelegate: NSObject {
    let viewRepresentable: NavigationDetector
    
    init(viewRepresentable: NavigationDetector) {
        self.viewRepresentable = viewRepresentable
    }
    
    func updateHaveNavigation(_ haveNavigation: Bool) {
        viewRepresentable.haveNavigation = haveNavigation
    }
}

extension UIView {
    func getViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
}
