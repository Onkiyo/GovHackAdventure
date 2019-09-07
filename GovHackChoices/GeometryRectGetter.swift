//
//  GeometryRectGetter.swift
//  GovHackChoices
//
//  Created by Dayn Goodbrand on 7/9/19.
//  Copyright © 2019 Dayn Goodbrand. All rights reserved.
//

import SwiftUI

struct GeometryRectGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.rect = geometry.frame(in: .global) }
        return Rectangle().fill(Color.clear)
    }
}
