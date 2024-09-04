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
                            Text("Distance".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.distance.toString)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            Text("EstimatedDuration".localized)
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
                            Text("AltMin".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.hasElevationData ? trail.minAlt.toStringMeters : "-")
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            Text("AltMax".localized)
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
                            
                            Text("ElevationGain".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Color("grgray"))
                            Text(trail.hasElevationData ? trail.elevationGain.toStringMeters : "-").fontWeight(.bold)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                            Text("ElevationLoss".localized)
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
                        Label("Difficulty", systemImage: "figure.hiking")
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
                        Label("Description", systemImage: "text.justify.leading")
                    }.isHidden(trail.description.isEmpty, remove: true)
                    
                }
                
                Section(header: Text("map")) {
                    MapSettingsRow()
                        .disabled(TileManager.shared.state.isDownloading() || trail.downloadState == .downloading)
                    if #available(iOS 17.0, *) {
                        TilesRow(state: $trail.downloadState, trail: trail)
                            .popoverTip(DownloadTip(), arrowEdge: .bottom)
                    } else {
                        // Fallback on earlier versions
                        TilesRow(state: $trail.downloadState, trail: trail)
                    }
                }
                
                Section(header: Text("Path")) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        Label("DisplayOnMap", systemImage: "mappin.and.ellipse").lineLimit(1)
                        Spacer()
                        Toggle("", isOn: $trail.isDisplayed).labelsHidden()
                    }
                    
                    DisclosureGroup {
                        
                        HStack(alignment: .center, spacing: 8) {
                            Label("Color", systemImage: "paintpalette").lineLimit(1)
                            Spacer()
                            ColorPicker(selection: $trail.color, label: {
                                EmptyView()
                            })
                            .labelsHidden()
                        }
                        
                        HStack(alignment: .center, spacing: 8) {
                            Label("Thickness", systemImage: "pencil.tip").lineLimit(1)
                            Spacer()
                            Slider(
                                value: $trail.lineWidth,
                                in: 3...10,
                                onEditingChanged: { editing in
                                    Feedback.selected()
                                    TrailManager.shared.save(trail: trail)
                                }
                            ).frame(width: 150)
                        }
                        
                    } label: {
                        Label("CustomPath", systemImage: "paintbrush")
                        
                    }
                    //                  ShareLink("Share", item: trail.gpx, preview: SharePreview(trail.name))
                }
                
                Section(header: Text("Actions")) {
                    ItineraryRow(location: trail.firstLocation)
                    TourRow(trail: trail)
                    DeleteRow(trail: trail)
                }
                
                if trail.hasElevationData {
                    Section(header: Text("Profile")) {
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
            TrailManager.shared.save(trail: trail)
        }) {
            trail.isFav ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        })
        .tint(Color.primary)
        .onAppear {
            TileManager.shared.load(for: trail, selectedLayer: appManager.selectedLayer)
            TrailManager.shared.addMissingDepartment(trail: self.trail)
            isPlayingTour = false
        }
        .onChange(of: trail.color, perform: { _ in
            TrailManager.shared.save(trail: trail)
        })
        .onChange(of: trail.isDisplayed, perform: { _ in
            TrailManager.shared.save(trail: trail)
        })
        .onChange(of: trail.description, perform: { _ in
            TrailManager.shared.save(trail: trail)
        })
        .sheet(isPresented: $showEditTrailSheet) {
            EditTrailView(trail: trail, showEditTrailSheet: $showEditTrailSheet)
        }
        
    }
    
}

@available(iOS 17.0, *)
struct FavoriteTip: Tip {

    var title: Text {
        Text("TipFavTitle")
    }
    
    var message: Text? {
        Text("TipFavDescription")
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
        Text("TipDownloadTitle")
    }
    
    var message: Text? {
        Text("TipDownloadDescription")
    }
    
    var image: Image? {
        Image(systemName: "icloud.and.arrow.down.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct TrailDetailView_Previews: PreviewProvider {
    @State static var trail: Trail = Trail(gpx: Gpx(name: "Le Crabère", locations: [mockLoc1,mockLoc2], department: "Ariège"))
    static var previews: some View {
        TrailDetailView(trail: trail).environmentObject(AppManager.shared)
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