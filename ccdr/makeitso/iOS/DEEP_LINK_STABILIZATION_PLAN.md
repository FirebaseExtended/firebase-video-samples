# Deep Link Stabilization & Security Report

## 1. Phase 2: Implementation Plan
### Infrastructure Improvements
- [ ] **Standardize Info.plist**: Create a physical `Info.plist` file in `MakeItSo/Supporting Files/` to permanently store the `makeitso` scheme and `com.apple.developer.associated-domains`.
- [ ] **Project Cleanup**: Remove all `INFOPLIST_KEY_...` settings from the build configuration to resolve merging conflicts.

### Website "Handshake" Deployment
- [ ] **AASA Creation**: Generate the `apple-app-site-association` file in `public/.well-known/`.
- [ ] **Firebase Hosting Headers**: Configure `firebase.json` to serve the AASA file with the correct `application/json` content-type.
- [ ] **Official Deploy**: Use `firebase deploy --only hosting` to enable Universal Links for production.

### UI/UX Refinement
- [ ] **Auto-Navigation**: Update the app state so the UI automatically pushes the `TaskListView` for a `listId` immediately after a successful join.
- [ ] **Feedback UI**: Add a SwiftUI overlay or Alert to show "Joining list..." and "Success!" messages.

---

## 2. Firestore Security Review
The following vulnerabilities were identified in the current `firestore.rules`:

| Severity | Issue | Risk | Status |
| :--- | :--- | :--- | :--- |
| **Critical** | **List Hijacking** | Shared members can currently change the `userId` (owner) or `title` of a list they were invited to. | 🔴 Pending Fix |
| **High** | **Member Erasure** | The current join handshake allows a new user to replace the entire `sharedWith` array, potentially kicking out other members. | 🔴 Pending Fix |
| **Medium** | **Token Exposure** | The secret `shareToken` is visible to all members of a list, rather than just the owner. | 🔴 Pending Fix |
| **Low** | **Schema Validation** | Lack of field type and existence checks allows "junk data" injection into documents. | 🔴 Pending Fix |

### Recommended Rule Hardening
- **Access Control**: Split `read` and `update` permissions so shared members have read-only access to list metadata.
- **Join Integrity**: Update the handshake to use `.hasAll()` and strict `.size()` checks to ensure the `sharedWith` array is only appended to, never replaced.
- **Metadata Protection**: Explicitly prevent modification of `userId`, `title`, and `shareToken` by anyone other than the owner.
