"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.joinList = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
// joinList callable function
exports.joinList = functions.https.onCall(async (data, context) => {
    // Authentication requirement
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }
    const listId = data.listId;
    const shareToken = data.shareToken;
    if (typeof listId !== 'string' || typeof shareToken !== 'string') {
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with listId and shareToken.');
    }
    const listRef = db.collection('lists').doc(listId);
    const listDoc = await listRef.get();
    if (!listDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'The requested list does not exist.');
    }
    const listData = listDoc.data();
    if ((listData === null || listData === void 0 ? void 0 : listData.shareToken) !== shareToken) {
        throw new functions.https.HttpsError('permission-denied', 'Invalid share token.');
    }
    // Add the user to the sharedWith array
    await listRef.update({
        sharedWith: admin.firestore.FieldValue.arrayUnion(context.auth.uid)
    });
    return { success: true, listId };
});
//# sourceMappingURL=index.js.map