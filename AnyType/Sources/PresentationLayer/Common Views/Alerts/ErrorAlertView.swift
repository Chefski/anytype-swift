//
//  ErrorAlertView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 15.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ErrorAlertView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    var errorText: String
    
    let presenting: Presenting
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting.blur(radius: self.isShowing ? 1 : 0)
                
                VStack() {

                    Text(self.errorText)
                        .foregroundColor(Color.white)
                        .padding()
                        .layoutPriority(1)
                    
                    
                    VStack(spacing: 0) {
                        Divider().background(Color.white)
                        Button(action: {
                            self.isShowing.toggle()
                        }) {
                            Text("Ok")
                                .foregroundColor(Color("GrayText"))
                                .padding()
                        }
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.8, minHeight: 0)
                .background(Color("BrownMenu"))
                .cornerRadius(10)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

#if DEBUG
struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            Text("ParentView")
        }
        return ErrorAlertView(isShowing: .constant(true), errorText: "Some Error long very long long long error", presenting: view)
    }
}
#endif
