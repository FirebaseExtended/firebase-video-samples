import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ConnectivityTestView: View {
    @State private var status = "Starting test..."
    @State private var userId = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Firestore Connectivity Test")
                .font(.title)
            
            Text("Status: \(status)")
                .padding()
                .background(status.contains("PASSED") ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            
            Text("User ID: \(userId)")
                .font(.caption)
            
            Button("Run Test Again") {
                Task {
                    await runTest()
                }
            }
        }
        .task {
            await runTest()
        }
    }
    
    func runTest() async {
        status = "Signing in..."
        do {
            if Auth.auth().currentUser == nil {
                try await Auth.auth().signInAnonymously()
            }
            guard let uid = Auth.auth().currentUser?.uid else {
                status = "FAILED: No User ID"
                return
            }
            userId = uid
            
            status = "Writing to Firestore..."
            let db = Firestore.firestore()
            let testTask = TaskItem(
                title: "iOS Integration Test Task \(UUID().uuidString)",
                isCompleted: false,
                priority: .medium,
                userId: uid
            )
            
            let docRef = try await db.collection("tasks").addDocument(from: testTask)
            status = "Read back from Firestore..."
            
            let snapshot = try await docRef.getDocument()
            if snapshot.exists {
                status = "PASSED! Data written and read back."
                // Cleanup
                try await docRef.delete()
            } else {
                status = "FAILED: Document does not exist"
            }
        } catch {
            status = "FAILED: \(error.localizedDescription)"
            print("Test Error: \(error)")
        }
    }
}
