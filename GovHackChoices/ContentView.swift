//
//  ContentView.swift
//  GovHackChoices
//
//  Created by Dayn Goodbrand on 7/9/19.
//  Copyright © 2019 Dayn Goodbrand. All rights reserved.
//

import SwiftUI
import Combine

// 087D58
let treeGreen = Color("TreeGreen")

// C81E54
let govHackPink = Color("GovHackPink")

class ViewModel: ObservableObject {
    private (set) var objectWillChange = PassthroughSubject<Void, Never>()
    
    private let dataSource = DataSource.sharedInstance
    private (set) var cardChoices: [Int: CardChoice] = [:]
    private (set) var cardReviews: [Int: Review] = [:]
    
    var reviews: [Review] {
        return cardReviews.map { $0.value }
    }
    
    @Published private (set) var allCardsComplete: Bool = true { didSet { objectWillChange.send() }}
    
    private var currentCard: Card? = nil {
        didSet {
            self.currentCardId = String("ID: \(currentCard?.id ?? -1)")
            self.currentCardTitle = currentCard?.question ?? ""
            self.currentCardImage = currentCard?.image.replacingOccurrences(of: ".pdf", with: "") ?? "blank"
            self.currentCardLeftChoiceText = currentCard?.left.label ?? ""
            self.currentCardRightChoiceText = currentCard?.right.label ?? ""
            self.currentCardHasLeftChoice = (currentCard?.left.label ?? "") != ""
            self.currentCardHasRightChoice = (currentCard?.right.label ?? "") != ""
        }
    }
    
    private (set) var currentCardId: String = "" { didSet { objectWillChange.send() }}
    private (set) var currentCardTitle: String = "" { didSet { objectWillChange.send() }}
    private (set) var currentCardImage: String = "blank" { didSet { objectWillChange.send() }}
    private (set) var currentCardLeftChoiceText: String = "" { didSet { objectWillChange.send() }}
    private (set) var currentCardRightChoiceText: String = "" { didSet { objectWillChange.send() }}
    private (set) var currentCardHasLeftChoice: Bool = false { didSet { objectWillChange.send() }}
    private (set) var currentCardHasRightChoice: Bool = false { didSet { objectWillChange.send() }}
    
    init() {
        allCardsComplete = false
        
        DispatchQueue.main.async {
            self.allCardsComplete = true
        }
        
    }
    
    func cardChoiceSelected(cardChoice: CardChoice) {
        guard let card = currentCard else { return }
        cardChoices[card.id] = cardChoice
        currentCard = dataSource.nextCard(after: card, choice: cardChoice)
        if let review = cardChoice == .left ? card.left.review : card.right.review,
            let card = currentCard {
            cardReviews[card.id] = review
        }
        allCardsComplete = currentCard == nil
    }
    
    func replay() {
        let currentCard = dataSource.allCards.first
        self.currentCard = currentCard
        cardChoices.removeAll()
        cardReviews.removeAll()
        allCardsComplete = false
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    @State private var cardViewRect: CGRect = .zero
    @State private var choiceDisplay: CardChoice? = nil
    @State private var showCard: Bool = true
    @State private var showReview: Bool = false
    
    @State private var leftTextRect: CGRect = .zero
    @State private var rightTextRect: CGRect = .zero
    
    private var transitionCardForCardChoicePublisher = PassthroughSubject<CardChoice, Never>()
    
    var body: some View {
        GeometryReader { viewGeometry in
            return ZStack(alignment: .top) {
                VStack {
                    Text(self.viewModel.currentCardTitle)
                        .font(Font.system(size: 36, weight: .regular))
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)
                        .frame(height: self.cardViewRect.origin.y * 0.75)
                        .opacity(self.showCard ? 1.0 : 0.0)
                        .animation(.easeIn(duration: self.showCard ? 0.3 : 0.2), value: self.showCard)
                }
                .padding([.horizontal, .top])
                
                // Rect Getter Text
                ZStack {
                    Text(self.viewModel.currentCardLeftChoiceText.uppercased())
                        .font(Font.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(width: viewGeometry.frame(in: .global).size.width - 40, alignment: .leading)
                        .background(GeometryRectGetter(rect: self.$leftTextRect))
                        .opacity(0.0)
                    
                    Text(self.viewModel.currentCardRightChoiceText.uppercased())
                        .font(Font.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(width: viewGeometry.frame(in: .global).size.width - 40, alignment: .trailing)
                        .background(GeometryRectGetter(rect: self.$rightTextRect))
                        .opacity(0.0)
                }
                
                VStack(spacing: 0) {
//                    Text(self.viewModel.currentCardId)
//                        .font(Font.system(size: 10, weight: .bold))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, 40)
                    
                    CardView(viewModel: self.viewModel, rect: self.$cardViewRect, choiceDisplay: self.$choiceDisplay, showCard: self.$showCard, transitionCardForCardChoicePublisher: self.transitionCardForCardChoicePublisher)
                        .frame(width: viewGeometry.frame(in: .global).size.width)
                        .background(GeometryRectGetter(rect: self.$cardViewRect))
                    
                    ZStack {
                        Rectangle().fill(Color.clear)
                            .frame(height: 100)
                        
                        VStack(spacing: 10) {
                            HStack(alignment: .center, spacing: 8) {
                                
                                Button(action: {
                                    self.transitionCardForCardChoicePublisher.send(.left)
                                }) {
                                    Image(systemName: "arrowshape.turn.up.left.fill")
                                        .foregroundColor(Color.primary)
                                }
                                .disabled(!self.viewModel.currentCardHasLeftChoice)
                                .opacity(self.viewModel.currentCardHasLeftChoice ? 1.0 : 0.0)
                                
                                Text(self.viewModel.currentCardLeftChoiceText.uppercased())
                                    .font(Font.system(size: 15, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(width: self.leftTextRect.size.width,
                                   height: self.leftTextRect.size.height,
                                   alignment: .leading)
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(self.viewModel.currentCardRightChoiceText.uppercased())
                                    .font(Font.system(size: 15, weight: .semibold))
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(2)
                                
                                Button(action: {
                                    self.transitionCardForCardChoicePublisher.send(.right)
                                }) {
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                        .foregroundColor(Color.primary)
                                }
                                .disabled(!self.viewModel.currentCardHasRightChoice)
                                .opacity(self.viewModel.currentCardHasRightChoice ? 1.0 : 0.0)
                            }
                            .frame(width: self.rightTextRect.size.width,
                                   height: self.rightTextRect.size.height,
                                   alignment: .trailing)
                        }
                        .opacity(0.8)
                        .padding(.horizontal)
                    }
                }
                .frame(width: viewGeometry.frame(in: .global).size.width, height: viewGeometry.frame(in: .global).size.height, alignment: .bottom)
                                
                if self.viewModel.allCardsComplete {
                    ZStack {
                        VStack(spacing: 0) {
                            Image("Green Forest")
                                .resizable()
                                .scaledToFill()
//                                .frame(maxWidth: .infinity)
                            
                            Image("HomeScreen")
//                                .resizable()
                                .scaledToFill()
//                                .frame(maxWidth: .infinity)
                            
                        }
                        .frame(width: UIScreen.main.bounds.size.width,
                               height: UIScreen.main.bounds.size.height,
                               alignment: .top)
                        .background(treeGreen)
                        .edgesIgnoringSafeArea(.vertical)
                        
                        
                        
                        VStack(alignment: .center, spacing: 24) {
                            Spacer()
                            
                            Button(action: {
                                self.viewModel.replay()
                            }) {
                                Text("Start The Story")
                                    .font(Font.system(size: 15, weight: .regular))
                                    .foregroundColor(treeGreen)
                            }
                            .frame(width: viewGeometry.frame(in: .global).size.width - 40, height: 35, alignment: .center)
                            .background(Color.white)
                            .cornerRadius(8)
                            
                            
                            
                            if !self.viewModel.reviews.isEmpty {
                                Button(action: {
                                    self.showReview = true
                                }) {
                                    Text("See Review")
                                        .font(Font.system(size: 15, weight: .regular))
                                        .foregroundColor(treeGreen)
                                }
                                .frame(width: viewGeometry.frame(in: .global).size.width - 40, height: 35, alignment: .center)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            
                            Rectangle()
                                .fill(treeGreen)
                                .frame(height: 50)
                        }
                    }
                }
            }
            .onReceive(self.viewModel.$allCardsComplete) { (allCardsComplete) in
                guard allCardsComplete && !self.viewModel.reviews.isEmpty else { return }
                DispatchQueue.main.async {
                    self.showReview = true
                }
            }
            .sheet(isPresented: self.$showReview) {
                ReviewView(viewModel: self.viewModel)
            }
        }
    }
}

struct CardView: View {
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var isCardDisplayed: Bool = true
    
    @ObservedObject var viewModel: ViewModel
    @Binding var rect: CGRect
    @Binding var choiceDisplay: CardChoice?
    @Binding var showCard: Bool
    
    var transitionCardForCardChoicePublisher: PassthroughSubject<CardChoice, Never>
    
    var body: some View {
        
        let translationWidthOffset: CGFloat = 40.0
        
        let dragGesture = DragGesture()
            .onChanged {
                let translationWidth = $0.translation.width
                let minmaxOffset = min(translationWidthOffset, max(-translationWidthOffset, translationWidth))
                let rotation: Double = 3.0 * Double(minmaxOffset / translationWidthOffset) //Double(minmaxOffset) * 0.1
                
                self.offset = CGSize(width: minmaxOffset, height: 0)
                self.rotation = rotation
                
                //print("translationWidth : \(translationWidth)")
                if translationWidth <= -translationWidthOffset {
                    self.choiceDisplay = .left
                } else if translationWidth >= translationWidthOffset {
                    self.choiceDisplay = .right
                } else {
                    self.choiceDisplay = nil
                }
            }
            .onEnded {
                let translationWidth = $0.translation.width
                var cardChoice: CardChoice?
                
                if translationWidth <= -translationWidthOffset {
                    print("LEFT SELECTED")
                    if self.viewModel.currentCardHasLeftChoice {
                        cardChoice = .left
                    }
                    
                } else if translationWidth >= translationWidthOffset {
                    print("RIGHT SELECTED")
                    if self.viewModel.currentCardHasRightChoice {
                        cardChoice = .right
                    }
                    
                } else {
                    print("NONE SELECTED")
                }
                
                if let cardChoice = cardChoice {
                    self.transitionCard(for: cardChoice)
                } else {
                    self.offset = .zero
                }
                
                self.rotation = 0
                self.choiceDisplay = nil
            }
        
        return VStack {
            
            Image(viewModel.currentCardImage)
                //.shadow(color: Color.black.opacity(0.7), radius: 10, x: 0.0, y: 3.0)
                .offset(x: offset.width, y: offset.height)
                .rotationEffect(Angle(degrees: rotation))
                .opacity(showCard ? 1.0 : 0.0)
                .gesture(dragGesture)
                .animation(.easeOut(duration: isCardDisplayed ? 0.3 : 0.0))
                .disabled(!showCard)
                .onReceive(transitionCardForCardChoicePublisher) { cardChoice in
                    self.transitionCard(for: cardChoice)
                }
        }
    }
    
    private func transitionCard(for cardChoice: CardChoice) {
        self.showCard = false
        self.offset = CGSize(width: cardChoice == .left ? -500 : 500, height: -20)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.cardChoiceSelected(cardChoice: cardChoice)
            self.isCardDisplayed = false
            self.offset = .zero
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.isCardDisplayed = true
                self.showCard = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
