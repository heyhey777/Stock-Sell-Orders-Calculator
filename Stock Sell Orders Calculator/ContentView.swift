//
//  ContentView.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.purple.opacity(0.1))
            
            HStack {
                VStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                    Text("Average price").font(.subheadline)
                    TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                }
                
                VStack {
                    Image(systemName: "basket.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                    Text("Shares amount").font(.subheadline)
                    TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                }
            }
        }
        .foregroundColor(.black)
        

        
        VStack {
            Text("Profit taking").font(.title2)
            Text("60 shares 25$ for 15% of gains, 30% of the position size")
            Text("20 shares 45$ for 45% of gains, 10% of the position size")
        }
        .padding()
        
        
        VStack {
            Divider()
        }
        .padding()
        
        VStack {
            Text("Stop loss").font(.title2)
            Text("15$ for 5% of loss, 20% of the position size")
        }
        .padding()
        
        VStack {
            Divider()
        }
        .padding()
        
        VStack {
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
        }
        .padding()
        
    }
    
}

#Preview {
    ContentView()
}
