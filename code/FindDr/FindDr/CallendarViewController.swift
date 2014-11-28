//
//  ViewController.swift
//  calendario3
//
//  Created by eduardo milpas diaz on 11/10/14.
//  Copyright (c) 2014 globant. All rights reserved.
//

import UIKit

class CallendarViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    //MARK: - constants
    let CALENDAR_HEADER = 8
    let CALENDAR_HOURS = 25
    let WIDTH_REDUCTION_PERCENTAGE = 0.97
    let HEIGHT_REDUCTION_PERCENTAGE = 0.93

    //MARK: - calendar constants
    let MONDAY    = 0
    let TUESDAY   = 1
    let WEDNESDAY = 2
    let THURSDAY  = 3
    let FRIDAY    = 4
    let SATURDAY  = 5
    let SUNDAY    = 6

    //MARK: - Instance properties
    var actualCell : CalendarCell?
    var actualDoctor : Doctor?
    var actualClinic : Clinic?

    //MARK: - View Properties
    @IBOutlet var calendarColView: UICollectionView!

    //MARK: - Overriden properties
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting gesture, delegate and cells for uicollectionView
        calendarColView.registerClass(CalendarCell.self, forCellWithReuseIdentifier: "hourCell")
        var swipe = UIPanGestureRecognizer(target: self, action: "hasSwipped:")
        calendarColView.addGestureRecognizer(swipe)
        swipe.delegate = self;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //changing size of the uicollectionView
        let width = view.frame.width
        let height = view.frame.height
        calendarColView.frame = CGRectMake(0, 0, width, height * 0.99)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fillCalendarFromClinic()
    }


    //MARK: - Delegate Swipe Methods

    func hasSwipped(gesture: UIPanGestureRecognizer) {
        var location = gesture.locationInView(calendarColView)
        let indexPath = calendarColView.indexPathForItemAtPoint(location)
        var selectedCell : CalendarCell?



        if indexPath != nil {
            if indexPath?.section != 0 && indexPath?.row != 0 {
                selectedCell = (calendarColView?.cellForItemAtIndexPath(indexPath!) as CalendarCell)
            }
            //limitating call method many times
            switch gesture.state {
            case UIGestureRecognizerState.Changed:
                if actualCell != selectedCell {
                    selectedCell?.makeSelection()
                    actualCell = selectedCell
                }
            default:()
            }
        }
    }


    //MARK: - Delegate Collection View Methods

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CALENDAR_HEADER;
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return  CALENDAR_HOURS
    }

    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("hourCell", forIndexPath: indexPath) as CalendarCell

        if indexPath.section == 0 && indexPath.row == 0 {
            cell.cruisedCellFormat()
        }
        else if indexPath.section == 0 {
            cell.dayCellFormat(indexPath.row)
        }

        else if indexPath.row == 0 {
            cell.hourCellFormat(indexPath.section)
        }
        else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 0 && indexPath.row != 0 {
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as CalendarCell
            selectedCell.makeSelection()
        }
    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath:
        NSIndexPath) -> CGSize {
            let width  = ((calendarColView.frame.width  - CGFloat(CALENDAR_HEADER + 1)) / CGFloat(CALENDAR_HEADER)) * CGFloat(WIDTH_REDUCTION_PERCENTAGE)
            let height = ((calendarColView.frame.height - CGFloat(CALENDAR_HOURS  + 1)) / CGFloat(CALENDAR_HOURS))  * CGFloat(HEIGHT_REDUCTION_PERCENTAGE)

            return CGSizeMake(width, height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 1, 1, 1);
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }

    //MARK: - Action View methods
    
    @IBAction func addSchedule(sender: AnyObject) {
        var hour : NSMutableArray?
        var week = Array<Array<Bool>>()
        //creating week array(each day has an Array fo 12 hours)
        for day in 0...CALENDAR_HEADER - 1 {
            hour = NSMutableArray(capacity: CALENDAR_HOURS - 1)
            for h in 0...CALENDAR_HOURS - 1 {
                week.append(Array(count:CALENDAR_HOURS - 1, repeatedValue:false))
            }
        }
        //Setting selected cells in array
        for cell in calendarColView.visibleCells() {
            if (cell as CalendarCell).isSelected() {
                var indexPath = calendarColView.indexPathForCell((cell as CalendarCell))
                week[indexPath!.row - 1][indexPath!.section - 1] = true
            }
        }
        //SAVING THE SCHEDULE
        let schedule = Schedule()

        if actualClinic != nil {
            schedule.monday    = week[MONDAY].reverse()
            schedule.tuesday   = week[TUESDAY].reverse()
            schedule.wednesday = week[WEDNESDAY].reverse()
            schedule.thursday  = week[THURSDAY].reverse()
            schedule.friday    = week[FRIDAY].reverse()
            schedule.saturday  = week[SATURDAY].reverse()
            schedule.sunday    = week[SUNDAY].reverse()
            //setting clinic
            schedule.clinic = actualClinic
            //saving
            schedule.save()
            //printing schedule
            printSchedule(week)
        }
        else {
            //TODO ver como trataremos el error
            println("Error al salvar calendario")
        }
        //returning to previous stage
        self.navigationController?.popViewControllerAnimated(true)
    }

    //MARK: - Helper methods
    func printSchedule(week : NSArray) {
        let days  = ["HOURS", "Mon  ", "Tue  ", "Wed  ", "Thu  ", "Fri  ", "Sat  ", "Sun  "];
        let hours = NSMutableArray(capacity: CALENDAR_HOURS - 1)
        for h in 1...CALENDAR_HOURS - 1 {
            hours.addObject(CalendarCell.getFormattedHour("\(24 - h)-\(24 - (h - 1))"))
        }
        //printing header
        for day in 0...days.count - 1 {
            print("\(days[day])|")
        }
        println("")
        println("_________________________________________________")//printing hours
        for hour in 0...CALENDAR_HOURS - 2 {
            print("\(hours[hour])|")
            for day in 0...CALENDAR_HEADER - 2 {
                print("  \(week[day][hour])  |")
            }
            println("")
        }
    }

    func fillCalendarFromClinic() {
        var week = Array<Array<Bool>>()
        Schedule.getScheduleByClinic(actualClinic, sched: { (schedule : Schedule!) -> Void in
            if schedule != nil {
                week.append((schedule.monday as Array<Bool>).reverse())
                week.append((schedule.tuesday as Array<Bool>).reverse())
                week.append((schedule.wednesday as Array<Bool>).reverse())
                week.append((schedule.thursday as Array<Bool>).reverse())
                week.append((schedule.friday as Array<Bool>).reverse())
                week.append((schedule.saturday as Array<Bool>).reverse())
                week.append((schedule.sunday as Array<Bool>).reverse())
            }
//            for testing if u want
//            println("****scheduled de BD****")
//            self.printSchedule(week)
            //formating cell background
            for cell in self.calendarColView.visibleCells() {
                var indexPath = self.calendarColView.indexPathForCell((cell as CalendarCell))
                if indexPath!.row > 0 && indexPath!.row < self.CALENDAR_HEADER && indexPath!.section > 0 && indexPath!.section < self.CALENDAR_HOURS {
                    if week.count > 0 && week[indexPath!.row - 1][indexPath!.section - 1] {
                        (cell as CalendarCell).makeSelection()
                    }
                }
            }
        })
    }
}

