# Product Requirements Document (PRD): Productivity App MVP

| Document Details |  |
| --- | --- |
| **Project Name** | **Make It So** |
| **Version** | 1.2 |
| **Status** | Draft |
| **Backend** | Google Cloud Firestore |
| **UI Style** | Platform-Specific / Native |

## 1. Executive Summary

"Make It So" is a productivity application designed to help users capture and complete tasks efficiently. The app leverages **Firebase** for cloud storage and real-time syncing. The UI is strictly **Platform Native**, ensuring that an Android user feels at home with Material Design patterns, while an iOS user interacts with standard Apple interface elements.

---

## 2. Functional Requirements

### 2.1 Task Management

* **Create:** Users can add a new task with a title, priority, and due date.
* **Read:** Users view a filtered list of *only* their own tasks.
* **Update:** Users can edit task details or toggle the "Complete" status.
* **Delete:** Users can permanently remove tasks.

### 2.2 User Experience (UX)

* **Native Metaphors:**
* **iOS:** Uses standard navigation stacks, "Back" buttons with text, and bottom sheets for actions.
* **Android:** Uses the physical/gesture back button, potentially a Floating Action Button (FAB) for "Add", and standard toolbars.


* **List Interaction:** A clean, vertical list. No Kanban boards or grids.

---

## 3. Technical Architecture & Data Model

### 3.1 Collection Structure

**Collection Name:** `tasks`
**Path:** `tasks/{documentId}`

* **Security:** A Firestore Security Rule ensures users can only access documents where `userId` matches their Authentication UID.

### 3.2 Data Schema (The "Item" Object)

| Field Name | Data Type | Description |
| --- | --- | --- |
| `userId` | String | **Owner ID.** Matches the Auth UID. |
| `title` | String | The task name. |
| `isCompleted` | Boolean | `false` = Active, `true` = Done. |
| `priority` | String | "Low", "Medium", "High". |
| `dueDate` | Timestamp | Date/time the task is due. |
| `createdAt` | Timestamp | Used for sorting order. |

---

## 4. User Interface (UI) Guidelines

This section defines how the "Native Look" is achieved on both platforms for the main task list.

### 4.1 iOS Implementation (Cupertino)

* **List Style:** `UITableView` or Sidebar style.
* **Separators:** Thin gray lines between items, inset from the left.
* **Typography:** San Francisco font.
* **Add Action:** A "+" icon in the top right of the Navigation Bar.
* **Edit Action:** Swipe-left on a row to reveal "Edit" and "Delete" buttons.

### 4.2 Android Implementation (Material)

* **List Style:** `RecyclerView` / LazyColumn.
* **Density/Padding:** Items generally have slightly more vertical whitespace (min 48dp-56dp height) to ensure comfortable touch targets.
* **Separators:** Often omitted in modern Material design, relying on whitespace, or full-width if used.
* **Add Action:** A Floating Action Button (FAB) in the bottom right corner.
* **Edit Action:** Long-press on an item to enter "Selection Mode," or tap to open details.

---

## 5. Security & Logic

### 5.1 Firestore Security Rules

* **Read/Write:** Allowed only if `request.auth.uid == resource.data.userId`.

### 5.2 Business Logic

* **Sorting:** Primary sort by `isCompleted` (Active first), Secondary sort by `dueDate`.
* **Date Formats:** Display dates relative to the user's locale (e.g., MM/DD/YYYY in US, DD/MM/YYYY elsewhere).

---

## 6. Acceptance Criteria

1. App is named "Make It So" on the home screen.
2. Android version features a Floating Action Button (FAB) or native toolbar for adding tasks.
3. iOS version features a standard Navigation Bar button for adding tasks.
4. Tasks persist to the `tasks` root collection in Firestore.
5. Query filters ensure I never see another user's data.