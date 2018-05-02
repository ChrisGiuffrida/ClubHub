//
//  ViewController.swift
//  graphtest
//
//  Created by Alex Ayala on 4/29/18.
//  Copyright © 2018 Alex Ayala. All rights reserved.
//

import UIKit
import Charts
import Firebase

class AnalyticsViewController: UIViewController {
    /* modified from https://stackoverflow.com/questions/41197122/pie-chart-using-charts-library-with-swift-3?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa */
    @IBOutlet weak var chart: PieChartView!
    @IBOutlet weak var chart2: PieChartView!
    @IBOutlet weak var chart3: PieChartView!
    @IBOutlet weak var chart4: PieChartView!
    @IBOutlet weak var chart5: PieChartView!
    
    var ref:DatabaseReference!
    
    var dorms = [String: Int]()
    var majors = [String: Int]()
    var genders = [String: Int]()
    var colleges = [String: Int]()
    var gradYears = [String: Int]()
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        
        self.ref = Database.database().reference()
        self.ref.child("clubs").child(self.ClubKey).child("members").observe(DataEventType.value, with: { (snapshot) in
            
            
            //.queryOrderedByKey().queryEqual(toValue: "-LBGqlDoi1vZEbffM5WH").observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let users = value?.allKeys
            let dispatchGroup = DispatchGroup()
            for user in users! {
                dispatchGroup.enter()
                self.ref.child("users").child(user as! String).observeSingleEvent(of: .value, with: { (snapshot2) in
                    let value2 = snapshot2.value as! NSDictionary
                    let college = value2["college"] as! String
                    let dorm = value2["dorm"] as! String
                    let major = value2["major"] as! String
                    let gender = value2["gender"] as! String
                    let gradYear = value2["grad_year"] as! String
                    if (self.dorms[dorm] != nil) {
                        self.dorms[dorm] = self.dorms[dorm]! + 1
                    } else {
                        self.dorms[dorm] = 1
                    }
                    
                    if (self.colleges[college] != nil) {
                        self.colleges[college] = self.colleges[college]! + 1
                    } else {
                        self.colleges[college] = 1
                    }
                    
                    if (self.majors[major] != nil) {
                        self.majors[major] = self.majors[major]! + 1
                    } else {
                        self.majors[major] = 1
                    }
                    
                    if (self.genders[gender] != nil) {
                        self.genders[gender] = self.genders[gender]! + 1
                    } else {
                        self.genders[gender] = 1
                    }
                    
                    if (self.gradYears[gradYear] != nil) {
                        self.gradYears[gradYear] = self.gradYears[gradYear]! + 1
                    } else {
                        self.gradYears[gradYear] = 1
                    }
                    dispatchGroup.leave()
                }
                )}
            dispatchGroup.notify(queue: .main) {
                self.createCharts()
            }
            
        }
            // ...
        ) { (error) in
            print(error.localizedDescription)
        }
        
        // 2. generate chart data entries
        
        // self.view.addSubview(chart2)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCharts() {
        print(self.colleges)
        // Use ints instead of doubles (default) for chart data
        let num_formatter = NumberFormatter()
        num_formatter.minimumFractionDigits = 0
        
        // Create entries for charts
        var entries1 = [PieChartDataEntry]()
        for (index, value) in self.dorms {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = index
            entries1.append(entry)
        }
        
        var entries2 = [PieChartDataEntry]()
        for (index, value) in self.majors {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = index
            entries2.append(entry)
        }
        
        var entries3 = [PieChartDataEntry]()
        for (index, value) in self.genders {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = index
            entries3.append(entry)
        }
        
        var entries4 = [PieChartDataEntry]()
        for (index, value) in self.colleges {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = index
            entries4.append(entry)
        }
        
        var entries5 = [PieChartDataEntry]()
        for (index, value) in self.gradYears {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = index
            entries5.append(entry)
        }
        
        // Create data sets based on data entries
        let set1 = PieChartDataSet(values: entries1, label: "")
        let set2 = PieChartDataSet(values: entries2, label: "")
        let set3 = PieChartDataSet(values: entries3, label: "")
        let set4 = PieChartDataSet(values: entries4, label: "")
        let set5 = PieChartDataSet(values: entries5, label: "")
        
        // Create data sets with configured layout settings and random colors for each pie slice.
        var colors1: [UIColor] = []
        for _ in 0..<self.dorms.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors1.append(color)
        }
        set1.colors = colors1
        set1.yValuePosition = PieChartDataSet.ValuePosition.outsideSlice
        set1.selectionShift = 30
        set1.valueLinePart1Length = 0.5
        set1.valueLinePart2Length = 0.5
        set1.valueTextColor = UIColor.black
        
        var colors2: [UIColor] = []
        for _ in 0..<self.majors.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors2.append(color)
        }
        set2.colors = colors2
        set2.yValuePosition = PieChartDataSet.ValuePosition.outsideSlice
        set2.selectionShift = 30
        set2.valueLinePart1Length = 0.5
        set2.valueLinePart2Length = 0.5
        set2.valueTextColor = UIColor.black
        
        var colors3: [UIColor] = []
        for _ in 0..<self.genders.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors3.append(color)
        }
        set3.colors = colors3
        set3.yValuePosition = PieChartDataSet.ValuePosition.outsideSlice
        set3.selectionShift = 30
        set3.valueLinePart1Length = 0.5
        set3.valueLinePart2Length = 0.5
        set3.valueTextColor = UIColor.black
        
        var colors4: [UIColor] = []
        for _ in 0..<self.colleges.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors4.append(color)
        }
        set4.colors = colors4
        set4.yValuePosition = PieChartDataSet.ValuePosition.outsideSlice
        set4.selectionShift = 30
        set4.valueLinePart1Length = 0.5
        set4.valueLinePart2Length = 0.5
        set4.valueTextColor = UIColor.black
        
        var colors5: [UIColor] = []
        for _ in 0..<self.gradYears.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors5.append(color)
        }
        set5.colors = colors5
        set5.yValuePosition = PieChartDataSet.ValuePosition.outsideSlice
        set5.selectionShift = 30
        set5.valueLinePart1Length = 0.5
        set5.valueLinePart2Length = 0.5
        set5.valueTextColor = UIColor.black
        
        // Set data of chart to data set and decription, format to be Ints instead of Doubles, disable interaction, and remove labels from charts
        let data1 = PieChartData(dataSet: set1)
        data1.setValueFormatter(DefaultValueFormatter(formatter: num_formatter))
        chart.data = data1
        chart.noDataText = "No dorm data available"
        chart.isUserInteractionEnabled = false
        chart.centerText = "Club Dorm\nBreakdown"
        
        let d = Description()
        d.text = ""
        chart.chartDescription = d
        chart.transparentCircleColor = UIColor.clear
        chart.drawEntryLabelsEnabled = false
        
        let data2 = PieChartData(dataSet: set2)
        data2.setValueFormatter(DefaultValueFormatter(formatter: num_formatter))
        data2.setValueTextColor(UIColor.black)
        chart2.data = data2
        chart2.noDataText = "No majors data available"
        chart2.isUserInteractionEnabled = false
        chart2.centerText = "Club Majors\nBreakdown"
        
        
        let d2 = Description()
        d2.text = ""
        chart2.chartDescription = d2
        chart2.transparentCircleColor = UIColor.clear
        chart2.drawEntryLabelsEnabled = false
        
        let data3 = PieChartData(dataSet: set3)
        data3.setValueFormatter(DefaultValueFormatter(formatter: num_formatter))
        data3.setValueTextColor(UIColor.black)
        chart3.data = data3
        chart3.noDataText = "No gender data available"
        chart3.isUserInteractionEnabled = false
        chart3.centerText = "Club Gender\nBreakdown"
        
        let d3 = Description()
        d3.text = ""
        chart3.chartDescription = d3
        chart3.transparentCircleColor = UIColor.clear
        chart3.drawEntryLabelsEnabled = false
        
        let data4 = PieChartData(dataSet: set4)
        data4.setValueFormatter(DefaultValueFormatter(formatter: num_formatter))
        data4.setValueTextColor(UIColor.black)
        chart4.data = data4
        chart4.noDataText = "No colleges data available"
        chart4.isUserInteractionEnabled = false
        chart4.centerText = "Club College\nBreakdown"
        
        let d4 = Description()
        d4.text = ""
        chart4.chartDescription = d4
        chart4.transparentCircleColor = UIColor.clear
        chart4.drawEntryLabelsEnabled = false
        
        let data5 = PieChartData(dataSet: set5)
        data5.setValueFormatter(DefaultValueFormatter(formatter: num_formatter))
        data5.setValueTextColor(UIColor.black)
        chart5.data = data5
        chart5.noDataText = "No graduation year data available"
        chart5.isUserInteractionEnabled = false
        chart5.centerText = "Club Graduation\nYear Breakdown"
        
        
        let d5 = Description()
        d5.text = ""
        chart5.chartDescription = d5
        chart5.transparentCircleColor = UIColor.clear
        chart5.drawEntryLabelsEnabled = false
    }
    
    
}
