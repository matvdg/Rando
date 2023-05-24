//
//  TrailDetail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct TrailDetail: View {
    
    @ObservedObject var trail: Trail
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: OldMapView(trail: trail)) {
                    OldMapView(trail: trail)
                        .frame(height: 200)
                }
                
                VStack(alignment: .leading, spacing: 20.0) {
                    
                    TextField("Rename".localized, text: $trail.name, onCommit:  {
                        TrailManager.shared.save(trail: self.trail)
                    })
                    .font(.system(size: 28, weight: .bold, design: Font.Design.default))
                    
                    Text(trail.department ?? "")
                        .font(.system(size: 20, weight: .light, design: Font.Design.default))
                        .isHidden(trail.department == nil || trail.department == "?", remove: true)
                    
                    HStack(alignment: .center, spacing: 20.0) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Distance".localized)
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.distance.toString).fontWeight(.bold)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DurationEstimated".localized)
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.estimatedTime).fontWeight(.bold)
                                }
                            }
                            
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AltMin".localized)
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.minAlt.toStringMeters).fontWeight(.bold)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AltMax".localized)
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.maxAlt.toStringMeters).fontWeight(.bold)
                                }
                            }
                            
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PositiveElevation".localized)
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.positiveElevation.toStringMeters).fontWeight(.bold)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("NegativeElevation".localized)
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.negativeElevation.toStringMeters).fontWeight(.bold)
                                }
                            }
                            
                        }
                        
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .frame(maxHeight: 100)
                    
                    ItineraryRow(location: trail.firstLocation)
                    
                    TourRow(trail: trail)
                    
                    DisplayRow(trail: trail)
                    
                    ColorRow(trail: trail)
                    
                    TilesRow(trail: trail)
                    
                    DeleteRow(trail: trail)
                    
                    VStack {
                        LineView(data: trail.simplifiedElevations, title: "Profile".localized, legend: "altitude (m)", style: Styles.customStyle, valueSpecifier: "%.0f")
                    }
                    .frame(height: 340)
                    
                }
                .padding()
                
            }
            .navigationBarTitle(Text(trail.name))
            .navigationBarItems(trailing:
                Button(action: {
                    Feedback.selected()
                    self.trail.isFav.toggle()
                    TrailManager.shared.save(trail: self.trail)
                }) {
                    Image(systemName: trail.isFav ? "heart.fill" : "heart")
                        .accentColor(.red)
                }
            )
        }
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear {
            TrailManager.shared.addMissingDepartment(trail: self.trail)
        }
    }
}

// MARK: Previews
struct TrailDetail_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TrailDetail(trail: Trail(gpx: Gpx(name: "Rando", locations: [mockLoc1,mockLoc2])))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
            TrailDetail(trail: Trail(gpx: Gpx(name: "Rando", locations: [mockLoc1,mockLoc2])))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
            TrailDetail(trail: Trail(gpx: Gpx(name: "Rando", locations: [mockLoc1,mockLoc2])))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
            TrailDetail(trail: Trail(gpx: Gpx(name: "Rando", locations: [mockLoc1,mockLoc2])))
                .preferredColorScheme(.dark)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
    }
}

extension  Styles {
    public static var customStyle: ChartStyle {
        let style = lineChartStyle
        style.darkModeStyle = darkModeStyle
        return style
    }
    
    public static let lineChartStyle = ChartStyle(
        backgroundColor: Color.clear,
        accentColor: Colors.GradientNeonBlue,
        secondGradientColor: Colors.GradientPurple,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    
    public static let darkModeStyle = ChartStyle(
        backgroundColor: Color.clear,
        accentColor: Colors.GradientLowerBlue,
        secondGradientColor: Colors.GradientUpperBlue,
        textColor: Color.white,
        legendTextColor: Color.white,
        dropShadowColor: Color.gray)
}
