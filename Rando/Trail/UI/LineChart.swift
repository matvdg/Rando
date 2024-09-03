import SwiftUI
import SwiftUICharts
import Charts

struct LineChart: View {
    var trail: Trail
    
    var body: some View {
        
        VStack(alignment : .leading) {
            Chart(trail.graphElevations) {
                AreaMark(x: .value("index", $0.index), yStart: .value("minAlt", trail.minAlt), yEnd: .value("elevation", $0.elevation))
                    .foregroundStyle(
                    .linearGradient(stops: [
                        Gradient.Stop(color: .blue, location: 0),
                        Gradient.Stop(color: Color.grblue, location: 0.5),
                        Gradient.Stop(color: Color.grgreen, location: 1)
                    ], startPoint: .bottom, endPoint: .top)
                    /*
                    .linearGradient(stops: [
                    Gradient.Stop(color: .green, location: 0),
                    Gradient.Stop(color: .green, location: 2/14),
                    Gradient.Stop(color: .yellow, location: 5/14),
                    Gradient.Stop(color: .orange, location: 8/14),
                    Gradient.Stop(color: .red, location: 10/14),
                    Gradient.Stop(color: .purple, location: 14/14),
                ], startPoint: .bottom, endPoint: .top)*/
                )
            }
            .chartYScale(domain: trail.minAlt...trail.maxAlt + 100)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 14)) { axisValue in
                    if axisValue.index % 2 == 0 {
                        AxisValueLabel()
                    }
                    AxisGridLine()
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}




// MARK: - Preview

struct LineChart_Previews: PreviewProvider {
    
    
    @State static var trail: Trail = Trail(gpx: Gpx(name: "Le Crabère", locations: mockLocations, department: "Ariège"))
    
    static var previews: some View {
        LineChart(trail: trail)
    }
}

let mockLocations = (1...10).map { _ in Location(latitude: 2.2, longitude: 0.1, altitude: Double.random(in: 1000...3000))  }
