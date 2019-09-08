//
//  ReviewView.swift
//  GovHackChoices
//
//  Created by Dayn Goodbrand on 7/9/19.
//  Copyright © 2019 Dayn Goodbrand. All rights reserved.
//

import SwiftUI

struct ReviewView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .top) {
                    Image("Review_1")
                        .resizable()
                        .scaledToFill()

                    HStack {
                        Spacer()
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 32, height: 32, alignment: .center)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
//    var body: some View {
//        VStack(spacing: 0) {
//            ZStack(alignment: .top) {
//                Image("Green Forest")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(maxWidth: .infinity)
//
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        self.presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(Color.white)
//                            .frame(width: 32, height: 32, alignment: .center)
//                    }
//                }
//                .padding()
//            }
//
//            VStack(spacing: 15) {
//                Text("Congratulations!")
//                    .foregroundColor(Color.white)
//                    .font(Font.system(size: 20, weight: .semibold))
//
//                Text("The choices you made preserved a lot of water so you ended up with a beautiful green forest!")
//                    .foregroundColor(Color.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//
//            }
//            .padding()
//            .frame(height: 150)
//            .background(treeGreen)
//            .padding(.horizontal, -4)
//
//            ForEach(viewModel.reviews) { review in
//                ReviewListItem(title: review.title,
//                               label: review.label,
//                               image: review.image,
//                               infoUrl: review.infoUrl)
//            }
//        }
//    }
}

private struct ReviewListItem: View {
    let title: String
    let label: String
    let image: String
    let infoUrl: String
    
    private let exploreText: String = "Explore open data on water usage in Australia"
    
    @State var labelRect: CGRect = .zero
    @State var exploreRect: CGRect = .zero
    
    var body: some View {
        ZStack {

            Text(label)
                .font(Font.system(size: 17, weight: .regular))
                .background(GeometryRectGetter(rect: $labelRect))
                .hidden()

            Text(exploreText)
                .font(Font.system(size: 15, weight: .semibold))
                .background(GeometryRectGetter(rect: $exploreRect))
                .hidden()

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image("Shower")
                        .foregroundColor(Color.white)
                        .scaledToFit()
                        .frame(width: 38, height: 38, alignment: .bottom)
                        .background(treeGreen)
                        .cornerRadius(8)

                    Text(title)
                        .font(Font.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(label)
                    .font(Font.system(size: 17, weight: .regular))
                    .frame(width: labelRect.size.width, height: labelRect.size.height, alignment: .leading)
                    .padding(.bottom, 16)


                Text(exploreText)
                    .font(Font.system(size: 15, weight: .semibold))
                    .frame(width: exploreRect.size.width, height: exploreRect.size.height, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//
//                    }
//
                    Button(action: {
                        //infoUrl
                    }) {
                        HStack {
                            Text("Explore open rainfall data")
                                .font(Font.system(size: 15, weight: .regular))
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        //.frame(alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(govHackPink)
                    .cornerRadius(8)
                }
            }
        }
        .padding() //.horizontal
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var viewModel: ViewModel {
        let viewModel = ViewModel()
        viewModel.cardChoiceSelected(cardChoice: .left)
        viewModel.cardChoiceSelected(cardChoice: .right)
        viewModel.cardChoiceSelected(cardChoice: .right)
        viewModel.cardChoiceSelected(cardChoice: .right)
        return viewModel
    }
    static var previews: some View {
        ReviewView(viewModel: viewModel)
    }
}
