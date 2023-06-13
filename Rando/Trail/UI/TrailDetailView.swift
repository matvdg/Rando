//
//  TrailDetailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct TrailDetailView: View {
    
    @ObservedObject var trail: Trail
    @Binding var selectedLayer: Layer
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: OldMapView(trail: trail, selectedLayer: $selectedLayer)) {
                    OldMapView(trail: trail, selectedLayer: $selectedLayer)
                        .frame(height: 200)
                }
                
                VStack(alignment: .leading, spacing: 20.0) {
                    
                    TextField("Rename", text: $trail.name, onCommit:  {
                        TrailManager.shared.save(trail: self.trail)
                    })
                    .font(.system(size: 28, weight: .bold, design: Font.Design.default))
                    .lineLimit(3)
                    
                    Text(trail.department ?? "")
                        .font(.system(size: 20, weight: .light, design: Font.Design.default))
                        .isHidden(trail.department == nil || trail.department == "?", remove: true)
                    
                    HStack(alignment: .center, spacing: 20.0) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Distance")
                                    .foregroundColor(Color("grgray"))
                                Text(trail.distance.toString).fontWeight(.bold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DurationEstimated")
                                    .foregroundColor(Color("grgray"))
                                Text(trail.estimatedTime).fontWeight(.bold)
                            }
                            
                        }
                        
                        if trail.hasElevationData {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("AltMin")
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.minAlt.toStringMeters).fontWeight(.bold)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("AltMax")
                                        .foregroundColor(Color("grgray"))
                                    Text(trail.maxAlt.toStringMeters).fontWeight(.bold)
                                }
                                
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("PositiveElevation")
                                            .foregroundColor(Color("grgray"))
                                        Text(trail.elevationGain.toStringMeters).fontWeight(.bold)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("NegativeElevation")
                                            .foregroundColor(Color("grgray"))
                                        Text(trail.elevationLoss.toStringMeters).fontWeight(.bold)
                                    }
                                }
                                
                            }
                        }
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .frame(maxHeight: 100)
                    Group {
                        DisplayRow(trail: trail)
                        
                        CustomPathRow(trail: trail)
                        
                        ItineraryRow(location: trail.firstLocation)
                        
                        TourRow(trail: trail)
                        
                        MapSettingsRow(selectedLayer: $selectedLayer).disabled(trail.downloadState == .downloading || TileManager.shared.state.isDownloading())
                        
                        TilesRow(selectedLayer: $selectedLayer, state: $trail.downloadState, trail: trail)
                        
                        ShareLink("Share", item: trail.gpx, preview: SharePreview(trail.name))
                            .font(.headline)
                                                
                        DeleteRow(trail: trail)
                        
                        if trail.hasElevationData {
                            LineView(data: trail.simplifiedElevations, title: "Profile", legend: "altitude (m)", style: Styles.customStyle, valueSpecifier: "%.0f")
                                .frame(height: 340)
                        }
                    }
                    
                }
                .padding()
                .accentColor(.tintColorTabBar)
                
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
            })
        }
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear {
            TileManager.shared.load(for: trail, selectedLayer: selectedLayer)
            TrailManager.shared.addMissingDepartment(trail: self.trail)
        }
    }
    
}

// MARK: Previews
struct TrailDetail_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        TrailDetailView(trail: Trail(gpx: Gpx(name: "Rando", locations: [mockLoc1,mockLoc2])), selectedLayer: $selectedLayer)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}

extension Styles {
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
