//
//  EfficiencyServiceViewModel.swift
//  ToDoList
//
//  Created by 清水豪 on 2024/08/03.
//

import Foundation

class EfficiencyService {
    static func calculateMetrics(for item: ToDoListItem) -> ToDoListItem {
        var updatedItem = item
        updatedItem.calculateMetrics()
        return updatedItem
    }

    static func getEfficiencyMessage(for item: ToDoListItem) -> String {
        guard let efficiencyIndex = item.efficiencyIndex else {
            return "タスクが完了していません"
        }

        if efficiencyIndex < 0.8 {
            return "素晴らしい効率です！"
        } else if efficiencyIndex < 1.0 {
            return "良い効率です"
        } else if efficiencyIndex < 1.2 {
            return "予測時間内に収まっています"
        } else {
            return "次回はより正確な予測を目指しましょう"
        }
    }
}
