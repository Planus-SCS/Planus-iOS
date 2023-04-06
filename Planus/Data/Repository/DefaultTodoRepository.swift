//
//  DefaultTodoRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

class TestTodoRepository: TodoRepository {
    
    let container = TodoContainer()
    
    func createTodo(todo: Todo) -> Single<Void> {
        return Single<Void>.create { [weak self] emitter in
            self?.container.uploadTodo(todo: todo)
            
            emitter(.success(()))
            return Disposables.create()
        }
    }
    
    func readTodo(from: Date, to: Date) -> Single<[Todo]> {
        return Single<[Todo]>.create { [weak self] emitter in
            guard let self else { return Disposables.create() }
            emitter(.success(self.container.getTodo(from: from, to: to)))
            return Disposables.create()
        }
    }
    
    func updateTodo(todo: Todo) -> Single<Void> {
        return Single<Void>.just(()).delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
    }
    
    func deleteTodo() -> Single<Void> {
        return Single<Void>.just(()).delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
    }
}

class TodoContainer {
    var todoDict = [Date: [Todo]]()
    var calendar = Calendar.current
    var standardDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date())) ?? Date()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter
    }()
    init() {
        
        var dict = [Date: [Todo]]()
        var calendarDate = Calendar.current.date(byAdding: DateComponents(day: 0), to: Calendar.current.date(byAdding: DateComponents(month: 0), to: standardDate) ?? Date()) ?? Date()
        print(calendarDate)
        todoDict[calendarDate] = []
        todoDict[calendarDate]?.append(Todo(title: "창재형이랑 롤하기", date: calendarDate, category: .green, type: .normal)) //일상
        todoDict[calendarDate]?.append(Todo(title: "SCSY 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 2시")) //미팅
        todoDict[calendarDate]?.append(Todo(title: "알고리즘 스터디 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 5시")) //미팅
        todoDict[calendarDate]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .purple, type: .normal)) //개인 공부
        todoDict[calendarDate]?.append(Todo(title: "헬스장!!", date: calendarDate, category: .green, type: .normal))
        todoDict[calendarDate]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .yello, type: .normal)) //개인 공부
        todoDict[calendarDate]?.append(Todo(title: "헬스장!!", date: calendarDate, category: .navy, type: .normal))
        let date2 = Calendar.current.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()

        todoDict[date2] = []
        todoDict[date2]?.append(Todo(title: "창재형이랑 롤하기2", date: calendarDate, category: .green, type: .normal)) //일상
        todoDict[date2]?.append(Todo(title: "SCSY 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 2시")) //미팅
        todoDict[date2]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .purple, type: .normal)) //개인 공부


        let date3 = Calendar.current.date(byAdding: DateComponents(day: 1), to: date2) ?? Date()

        todoDict[date3] = []
        todoDict[date3]?.append(Todo(title: "창재형이랑 롤하기3", date: calendarDate, category: .green, type: .normal)) //일상
        todoDict[date3]?.append(Todo(title: "SCSY 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 2시")) //미팅
        todoDict[date3]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .purple, type: .normal)) //개인 공부


        let date4 = Calendar.current.date(byAdding: DateComponents(day: 1), to: date3) ?? Date()

        todoDict[date4] = []
        todoDict[date4]?.append(Todo(title: "창재형이랑 롤하기4", date: calendarDate, category: .green, type: .normal)) //일상
        todoDict[date4]?.append(Todo(title: "SCSY 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 2시")) //미팅
        todoDict[date4]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .purple, type: .normal)) //개인 공부

        let date5 = Calendar.current.date(byAdding: DateComponents(day: 1), to: date4) ?? Date()

        todoDict[date5] = []
        todoDict[date5]?.append(Todo(title: "창재형이랑 롤하기5", date: calendarDate, category: .green, type: .normal)) //일상
        todoDict[date5]?.append(Todo(title: "SCSY 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 2시")) //미팅
        todoDict[date5]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .purple, type: .normal)) //개인 공부


        let date6 = Calendar.current.date(byAdding: DateComponents(day: 1), to: date5) ?? Date()

        todoDict[date6] = []
        todoDict[date6]?.append(Todo(title: "창재형이랑 롤하기6", date: calendarDate, category: .green, type: .normal)) //일상
        todoDict[date6]?.append(Todo(title: "SCSY 미팅", date: calendarDate, category: .blue, type: .normal, time: "오후 2시")) //미팅
        todoDict[date6]?.append(Todo(title: "백준 12746 풀기", date: calendarDate, category: .purple, type: .normal)) //개인 공부
        
        calendarDate = Calendar.current.date(byAdding: DateComponents(year: -1), to: calendarDate) ?? Date()
        
        for i in 0..<5000 {

            let tmpCalendarDate = Calendar.current.date(byAdding: DateComponents(day: i), to: calendarDate) ?? Date()

            todoDict[tmpCalendarDate] = []
            for j in 0..<2 {
                todoDict[tmpCalendarDate]?.append(Todo(title: "\(dateFormatter.string(from: tmpCalendarDate))", date: tmpCalendarDate, category: .init(rawValue: j)!, type: .normal))
            }
        }
        
        
    }
    
    func getTodo(from: Date, to: Date) -> [Todo] {
        
        var todoList = [Todo]()
        var date = from
        let components = DateComponents(day: 1)
        while date != to {
            if let list = todoDict[date] {
                todoList += list
            }
            guard let newDate = calendar.date(byAdding: components, to: date) else {
                return []
            }
            date = newDate
        }
        return todoList
    }
    
    func uploadTodo(todo: Todo) {
        if todoDict[todo.date] == nil {
            todoDict[todo.date] = []
        }
        todoDict[todo.date]?.append(todo)
        
    }
}
