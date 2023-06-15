//
//  TrailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 14/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import SwiftUICharts


struct TrailView: View {
    
    @ObservedObject var trail: Trail
    @Binding var selectedLayer: Layer
    @State var showNameAlert: Bool = false
    @State var thickness: Thickness = .normal
    
    enum Thickness: String, CaseIterable {
        case extraThin, thin, normal, thick, extraThick
        var lineWidth: CGFloat {
            switch self {
            case .extraThin: return 2
            case .thin: return 4
            case .normal: return defaultLineWidth
            case .thick: return 8
            case .extraThick: return 10
            }
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink(destination: OldMapView(trail: trail, selectedLayer: $selectedLayer)) {
                OldMapView(trail: trail, selectedLayer: $selectedLayer)
                    .frame(height: 200).disabled(true)
            }
            
            List {
                
                Section(header: Text(trail.department ?? "")) {
                    
                    HStack {
                        Label("Difficulty", systemImage: "figure.hiking")
                        Spacer()
                        DifficultyView(difficulty: trail.difficulty)
                    }
                    HStack {
                        Label("Distance", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        Spacer()
                        Text(trail.distance.toString)
                    }
                    DisclosureGroup {
                        HStack {
                            Label("Elevation", systemImage: "arrow.up.forward")
                            Spacer()
                            Text(trail.hasElevationData ? trail.elevationGain.toStringMeters : "-")
                        }
                        HStack {
                            Label("EstimatedDuration", systemImage: "clock")
                            Spacer()
                            Text(trail.estimatedTime)
                        }
                        HStack {
                            Label("Altitude", systemImage: "arrow.up.and.line.horizontal.and.arrow.down")
                            Spacer()
                            Text(trail.hasElevationData ? "\(trail.minAlt.toStringMeters) → \(trail.maxAlt.toStringMeters)" : "-")
                        }
                        if trail.isLoop {
                            Label("loop", systemImage: "arrow.triangle.capsulepath")
                        } else {
                            Label("oneWay", systemImage: "arrow.right")
                        }
                    } label: {
                        Label("MoreInfos", systemImage: "info.circle")
                    }
                    
                    DisclosureGroup {
                        VStack {
                            Text(trail.description).font(.system(size: 14))
                            /*  Button {
                                //
                            } label: {
                                Text("Edit").foregroundColor(.primary)
                                    .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.secondary)*/
                        }
                        
                    } label: {
                        Label("Description", systemImage: "text.justify.leading")
                        
                    }
                    
                    Button {
                        showNameAlert = true
                    } label: {
                        Label("Rename", systemImage: "pencil.line")
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
                            Label("Thickness", systemImage: "pencil.tip").lineLimit(1)
                            Spacer()
                            Slider(
                                value: $trail.lineWidth,
                                in: 3...10,
                                onEditingChanged: { editing in
                                    Feedback.selected()
                                    TrailManager.shared.save(trail: trail)
                                }
                            ).frame(width: 100)
                        }
                        //Stepper option
                        //  HStack(alignment: .center, spacing: 8) {
                        //                            Label("Thickness", systemImage: "eyedropper").lineLimit(1)
                        //                            Spacer()
                        //                            Stepper(value: $trail.lineWidth, in: 3...10, step: 1) {
                        //                                EmptyView()
                        //                            } onEditingChanged: { _ in
                        //                                Feedback.selected()
                        //                                TrailManager.shared.save(trail: trail)
                        //                            }
                        //                            .labelsHidden()
                        //                        }
                        
                        
                        HStack(alignment: .center, spacing: 8) {
                            Label("Color", systemImage: "paintpalette").lineLimit(1)
                            Spacer()
                            ColorPicker(selection: $trail.color, label: {
                                EmptyView()
                            })
                            .labelsHidden()
                        }
                    } label: {
                        Label("CustomPath", systemImage: "paintbrush")
                        
                    }
                    //                  ShareLink("Share", item: trail.gpx, preview: SharePreview(trail.name))
                }
                
                Section(header: Text("Map")) {
                    MapSettingsRow(selectedLayer: $selectedLayer)
                        .disabled(TileManager.shared.state.isDownloading() || trail.downloadState == .downloading)
                    TilesRow(selectedLayer: $selectedLayer, state: $trail.downloadState, trail: trail)
                }
                
                Section(header: Text("Actions")) {
                    ItineraryRow(location: trail.firstLocation)
                    TourRow(trail: trail)
                    DeleteRow(trail: trail)
                }
                
                if trail.hasElevationData {
                    Section(header: Text("Profile")) {
                        LineView(data: trail.simplifiedElevations, legend: "altitude (m)", style: Styles.customStyle, valueSpecifier: "%.0f")
                            .frame(height: 340)
                    }
                }
                
            }
            .listStyle(.insetGrouped)
        }
        .tint(Color.primary)
        .onAppear {
            TileManager.shared.load(for: trail, selectedLayer: selectedLayer)
            TrailManager.shared.addMissingDepartment(trail: self.trail)
        }
        .onChange(of: trail.color, perform: { newValue in
            TrailManager.shared.save(trail: trail)
        })
        .alert("Rename", isPresented: $showNameAlert) {
            TextField("Enter your name", text: $trail.name)
            Button("OK", action: submit)
        } message: {
            Text("RenameDescription")
        }
        .navigationBarTitle(Text(trail.name), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            // LIKE
            Button {
                Feedback.selected()
                self.trail.isFav.toggle()
                TrailManager.shared.save(trail: self.trail)
            } label: {
                Image(systemName: trail.isFav ? "heart.fill" : "heart")
                    .accentColor(trail.isFav ? .red : .primary)
            }
            /* SHARING
             ShareLink("Share", item: trail.gpx, preview: SharePreview(trail.name))
             Button {
             Feedback.selected()
             // Todo
             } label: {
             Image(systemName: "square.and.arrow.up")
             }*/
        })
    }
    
    func submit() {
        TrailManager.shared.save(trail: trail)
    }
    
}

struct TrailView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    @State static var trail: Trail = Trail(gpx: Gpx(name: "Le Crabère", locations: [mockLoc1,mockLoc2], department: "Ariège"))
    static var previews: some View {
        TrailView(trail: trail, selectedLayer: $selectedLayer)
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
