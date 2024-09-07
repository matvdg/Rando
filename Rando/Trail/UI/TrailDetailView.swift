//
//  TrailDetailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 14/06/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import SwiftUICharts
import TipKit


struct TrailDetailView: View {
    
    @ObservedObject var trail: Trail
    @ObservedObject var trailManager = TrailManager.shared
    @ObservedObject var tileManager = TileManager.shared
    @State var showEditTrailSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appManager: AppManager
    @State private var indexOfGraph: Int?
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink(destination: TrailMapView(trail: trail)) {
                MapView(trail: trail, indexOfGraph: $indexOfGraph)
                    .edgesIgnoringSafeArea(.vertical)
                    .frame(height: 250)
                    .disabled(true)
            }
            
            List {
                
                Section(header:
                            Text(trail.name)
                    .foregroundColor(.primary)
                    .font(.system(size: 20, weight: .bold))
                    .onTapGesture {
                        Feedback.selected()
                        showEditTrailSheet = true
                    }
                ) {
                    
                    HStack(alignment: .top, spacing:  8) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("distance".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.distance.toString)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            Text("estimatedDuration".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.estimatedTime)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                        }
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("altMin".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.hasElevationData ? trail.minAlt.toStringMeters : "-")
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            Text("altMax".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.hasElevationData ? trail.maxAlt.toStringMeters : "-")
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                        }
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text("elevationGain".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.hasElevationData ? trail.elevationGain.toStringMeters : "-").fontWeight(.bold)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            Text("elevationLoss".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.hasElevationData ? trail.elevationLoss.toStringMeters : "-").fontWeight(.bold)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            
                        }
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity)
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .frame(maxHeight: 100)
                    
                    HStack {
                        Label("difficulty", systemImage: "figure.hiking")
                        Spacer()
                        DifficultyColorView(difficulty: trail.difficulty)
                    }
                    
                    if let department = trail.department {
                        Label(department, systemImage: "mappin.and.ellipse")
                    }
                    
                    if trail.isLoop {
                        Label("loop", systemImage: "arrow.triangle.capsulepath")
                    } else {
                        Label("oneWay", systemImage: "arrow.right")
                    }
                    
                    DisclosureGroup {
                        Text(trail.description).font(.system(size: 14))
                            .onTapGesture {
                                Feedback.selected()
                                showEditTrailSheet = true
                            }
                    } label: {
                        Label("description", systemImage: "text.justify.leading")
                    }.isHidden(trail.description.isEmpty, remove: true)
                    
                }
                
                Section(header: Text("map")) {
                    MapSettingsRow()
                        .disabled(tileManager.state.isDownloading() || trail.downloadState == .downloading)
                    if #available(iOS 17.0, *) {
                        TilesRow(state: $trail.downloadState, trail: trail)
                            .popoverTip(DownloadTip(), arrowEdge: .bottom)
                    } else {
                        // Fallback on earlier versions
                        TilesRow(state: $trail.downloadState, trail: trail)
                    }
                }
                
                Section(header: Text("path")) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        Label("displayOnMap", systemImage: "mappin.and.ellipse").lineLimit(1)
                        Spacer()
                        Toggle("", isOn: $trail.isDisplayed).labelsHidden()
                    }
                    
                    DisclosureGroup {
                        
                        HStack(alignment: .center, spacing: 8) {
                            Label("color", systemImage: "paintpalette").lineLimit(1)
                            Spacer()
                            ColorPicker(selection: $trail.color, label: {
                                EmptyView()
                            })
                            .labelsHidden()
                        }
                        
                        HStack(alignment: .center, spacing: 8) {
                            Label("thickness", systemImage: "pencil.tip").lineLimit(1)
                            Spacer()
                            Slider(
                                value: $trail.lineWidth,
                                in: 3...10,
                                onEditingChanged: { editing in
                                    Feedback.selected()
                                    trailManager.save(trail: trail)
                                }
                            ).frame(width: 150)
                        }
                        
                    } label: {
                        Label("customPath", systemImage: "paintbrush")
                        
                    }
                    //                  ShareLink("share", item: trail.gpx, preview: SharePreview(trail.name))
                }
                
                Section(header: Text("actions")) {
                    ItineraryRow(location: trail.firstLocation)
                    TourRow(trail: trail)
                    DeleteRow(trail: trail)
                }
                
                if trail.hasElevationData {
                    Section(header: Text("profile")) {
//                        LineChart(trail: trail)
                        LineView(data: trail.elevations, legend: "altitude (m)", style: Styles.customStyle, valueSpecifier: "%.0f", onIndexChange: { newValue in
                            indexOfGraph = newValue
                        })
                        .frame(height: 340)
                    }
                }
                
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(trail.name)
        .navigationBarItems(trailing: Button(action: {
            Feedback.selected()
            trail.isFav.toggle()
            trailManager.save(trail: trail)
        }) {
            trail.isFav ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        })
        .tint(Color.primary)
        .onAppear {
            tileManager.load(for: trail, selectedLayer: appManager.selectedLayer)
            trailManager.addMissingDepartment(trail: self.trail)
            isPlayingTour = false
        }
        .onChange(of: trail.color, perform: { _ in
            trailManager.save(trail: trail)
        })
        .onChange(of: trail.isDisplayed, perform: { _ in
            trailManager.save(trail: trail)
        })
        .onChange(of: trail.description, perform: { _ in
            trailManager.save(trail: trail)
        })
        .sheet(isPresented: $showEditTrailSheet) {
            EditTrailView(trail: trail, showEditTrailSheet: $showEditTrailSheet)
        }
        
    }
    
}

@available(iOS 17.0, *)
struct FavoriteTip: Tip {

    var title: Text {
        Text("tipFavTitle")
    }
    
    var message: Text? {
        Text("tipFavDescription")
    }
    
    var image: Image? {
        Image(systemName: "heart.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct DownloadTip: Tip {

    var title: Text {
        Text("tipDownloadTitle")
    }
    
    var message: Text? {
        Text("tipDownloadDescription")
    }
    
    var image: Image? {
        Image(systemName: "icloud.and.arrow.down.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

#Preview {
    TrailDetailView(trail: Trail(gpx: Gpx(name: "Le Crabère", locations: [mockLoc1,mockLoc2], department: "Ariège"))).environmentObject(AppManager.shared)
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
