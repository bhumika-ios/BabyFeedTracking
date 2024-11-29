//
//  ContentView.swift
//  BabyFeedTracking
//
//  Created by Bhumika Patel on 29/11/24.
//

import SwiftUI
import UserNotifications

func requestNotificationPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error {
            print("Notification permission error: \(error.localizedDescription)")
        } else if granted {
            print("Notification permissions granted")
        } else {
            print("Notification permissions denied")
        }
    }
}


struct ContentView: View {
    @StateObject private var feedingData = FeedingData()
    @State private var showingAddFeeding = false

    var body: some View {
        NavigationView {
            VStack {
                List(feedingData.feedings) { feeding in
                    VStack(alignment: .leading) {
                        Text("Time: \(feeding.date, formatter: DateFormatter.shortTime)")
                        Text("Amount: \(feeding.amount, specifier: "%.1f") oz")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                NavigationLink(destination: AnalyticsView(feedings: feedingData.feedings)) {
                    Text("View Analytics")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            }
            .navigationTitle("Feeding Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddFeeding = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFeeding) {
                AddFeedingView(feedings: $feedingData.feedings)
            }
        }
    }
}




#Preview {
    ContentView()
}
struct FeedingLog: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let amount: Double
}



struct AddFeedingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var feedings: [FeedingLog]
    @State private var feedingAmount: String = ""
    @State private var feedingDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Feeding Details")) {
                    TextField("Amount (oz)", text: $feedingAmount)
                        .keyboardType(.decimalPad)
                    DatePicker("Time", selection: $feedingDate, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Feeding")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(feedingAmount) {
                            feedings.append(FeedingLog(date: feedingDate, amount: amount))
                            scheduleReminder(after: 3) // Default 3-hour reminder
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    func scheduleReminder(after hours: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Feed"
        content.body = "Don't forget to feed your baby!"
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .hour, value: hours, to: Date())
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}


class FeedingData: ObservableObject {
    @Published var feedings: [FeedingLog] = [] {
        didSet {
            saveFeedings()
        }
    }

    init() {
        loadFeedings()
    }

    private func saveFeedings() {
        if let encoded = try? JSONEncoder().encode(feedings) {
            UserDefaults.standard.set(encoded, forKey: "Feedings")
        }
    }

    private func loadFeedings() {
        if let data = UserDefaults.standard.data(forKey: "Feedings"),
           let decoded = try? JSONDecoder().decode([FeedingLog].self, from: data) {
            feedings = decoded
        }
    }
}
