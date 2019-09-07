//
//  ContentView.swift
//  GovHackChoices
//
//  Created by Dayn Goodbrand on 7/9/19.
//  Copyright © 2019 Dayn Goodbrand. All rights reserved.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    private (set) var objectWillChange = PassthroughSubject<Void, Never>()
    
    private let dataSource = DataSource.sharedInstance
    private var cardChoices: [Int: CardChoice] = [:]
    private var cardReviews: [Int: Review] = [:]
    
    @Published private (set) var allCardsComplete: Bool = false { didSet { objectWillChange.send() }}
    
    private var currentCard: Card? = nil {
        didSet {
            self.currentCardTitle = currentCard?.question ?? ""
            self.currentCardImage = currentCard?.image ?? "blank"
            self.currentCardLeftChoiceText = currentCard?.left.label ?? ""
            self.currentCardRightChoiceText = currentCard?.right.label ?? ""
        }
    }
    private (set) var currentCardTitle: String = "" { didSet { objectWillChange.send() }}
    private (set) var currentCardImage: String = "blank" { didSet { objectWillChange.send() }}
    private (set) var currentCardLeftChoiceText: String = "" { didSet { objectWillChange.send() }}
    private (set) var currentCardRightChoiceText: String = "" { didSet { objectWillChange.send() }}
    
    init() {
        replay()
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
        allCardsComplete = false
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    @State private var cardViewRect: CGRect = .zero
    @State private var choiceDisplay: CardChoice? = nil
    @State private var showCard: Bool = true
    @State private var showResults: Bool = false
    
    var body: some View {
        GeometryReader { viewGeometry in
            return ZStack(alignment: .top) {
                VStack {
                    Text(self.viewModel.currentCardTitle)
                        .font(Font.system(size: 36, weight: .regular))
                        .multilineTextAlignment(.center)
                        .frame(height: self.cardViewRect.origin.y * 0.75)
                        .opacity(self.showCard ? 1.0 : 0.0)
                        .animation(.easeIn(duration: self.showCard ? 0.3 : 0.2), value: self.showCard)
                }
                .padding([.horizontal, .top])
                
                VStack {
                    CardView(viewModel: self.viewModel, rect: self.$cardViewRect, choiceDisplay: self.$choiceDisplay, showCard: self.$showCard)
                        .padding(.horizontal, 20)
                        .background(GeometryRectGetter(rect: self.$cardViewRect))
                    
                    ZStack {
                        Rectangle().fill(Color.clear)
                            .frame(height: 80)
                        
                        HStack {
                            if self.choiceDisplay == .left {
                                Text(self.viewModel.currentCardLeftChoiceText.uppercased())
                                    .font(Font.system(size: 17, weight: .semibold))
                                Spacer()
                            } else if self.choiceDisplay == .right {
                                Spacer()
                                Text(self.viewModel.currentCardRightChoiceText.uppercased())
                                    .font(Font.system(size: 17, weight: .semibold))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(height: viewGeometry.frame(in: .global).size.height, alignment: .bottom)
                
                if self.viewModel.allCardsComplete {
                    VStack(alignment: .center, spacing: 32) {
                        Spacer()
                        Button(action: {
                            self.viewModel.replay()
                        }) {
                            Text("Replay Story")
                                .font(Font.system(size: 22, weight: .medium))
                        }

                        Button(action: {
                            self.showResults = true
                        }) {
                            Text("See Results")
                                .font(Font.system(size: 22, weight: .medium))
                        }
                        Spacer()
                    }
                }
            }
            .onReceive(self.viewModel.$allCardsComplete) { (allCardsComplete) in
                guard allCardsComplete else { return }
                self.showResults = true
            }
            .sheet(isPresented: self.$showResults) {
                ResultsView(viewModel: self.viewModel)
            }
        }
    }
}

struct ResultsView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text("Results Go Here!")
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
                    cardChoice = .left
                    
                } else if translationWidth >= translationWidthOffset {
                    print("RIGHT SELECTED")
                    cardChoice = .right
                    
                } else {
                    print("NONE SELECTED")
                    self.offset = .zero
                }
                
                if let cardChoice = cardChoice {
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
                
                self.rotation = 0
                self.choiceDisplay = nil
            }
        
        
        return VStack {
            Image(viewModel.currentCardImage)
                .resizable()
                .scaledToFill()
                .clipped()
                .aspectRatio(0.8, contentMode: .fit)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.7), radius: 10, x: 0.0, y: 3.0)
                .offset(x: offset.width, y: offset.height)
                .rotationEffect(Angle(degrees: rotation))
                .opacity(showCard ? 1.0 : 0.0)
                .gesture(dragGesture)
                .animation(.easeOut(duration: isCardDisplayed ? 0.3 : 0.0))
                .disabled(!showCard)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
