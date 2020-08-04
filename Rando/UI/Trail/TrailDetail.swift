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
        ScrollView {
            VStack {
                
                NavigationLink(destination: MapViewContainer(trail: trail)) {
                    
                    MapView(trail: trail)
                        .frame(height: 300)
                }
                
                VStack(alignment: .leading, spacing: 20.0) {
                    
                    TextField("Rename".localized, text: $trail.name) {
                        TrailManager.shared.save(trail: self.trail)
                        }
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
                    
                    DisplayRow(id: trail.id.uuidString)
                    
                    TilesRow(boundingBox: trail.polyline.boundingMapRect, name: trail.name)
                    
                    VStack {
                        LineView(data: trail.simplifiedElevations, title: "Profile".localized, legend: "altitude (m)", style: Styles.customStyle, valueSpecifier: "%.0f")
                    }
                    .frame(height: 340)
                    
                }
                .padding()
                
            }
            .navigationBarTitle(Text(trail.name))
        }
        .onAppear {
            TrailManager.shared.addMissingDepartment(trail: self.trail)
        }
    }
}

// MARK: Previews
struct TrailDetail_Previews: PreviewProvider {
        
    static var previews: some View {
        TrailDetail(trail: Trail(gpx: Gpx(name: "Rando", locations: [mockLoc1,mockLoc2])))
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .previewDisplayName("iPhone SE")
            .environment(\.colorScheme, .light)
    }
}

extension  Styles {
    public static var customStyle: ChartStyle {
        let style = lineChartStyleTwo
        style.darkModeStyle = lineViewDarkModeTwo
        return style
    }
    
    public static let lineChartStyleTwo = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Colors.GradientNeonBlue,
        secondGradientColor: Colors.GradientPurple,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
   
    
    public static let lineViewDarkModeTwo = ChartStyle(
        backgroundColor: Color.black,
        accentColor: Colors.GradientLowerBlue,
        secondGradientColor: Colors.GradientUpperBlue,
        textColor: Color.white,
        legendTextColor: Color.white,
        dropShadowColor: Color.gray)
}
