# Reacting to Firestore changes with Google Cloud Functions and EventArc

This is the source code used in this video: [Reacting to Firestore changes with Cloud Functions and Eventarc]( https://youtu.be/0PK53ndn3Lc)

## Prerequisites

- Java 17
- Maven
- Install the gcloud CLI

## How to deploy to Cloud Run

Run the command bellow, replacing the value of `GCLOUD_PROJECT` ("fun-firebase-functions") with your actual Firebase project id.

```bash
gcloud functions deploy myfunc \
  --gen2 \
  --entry-point functions.FirebaseUppercaseText \
  --runtime=java17 \
  --trigger-event-filters="type=google.cloud.firestore.document.v1.written" \
  --trigger-event-filters="database=(default)" \
  --trigger-event-filters-path-pattern=document="robot/{docId}" \
  --trigger-location=nam5 \
  --region=us-central1 \
  --set-env-vars GCLOUD_PROJECT=fun-firebase-functions \
  --memory=512MiB
```

## Testing in the Firebase console

Create a new Firestore collection named "robot" and add a new document to it. This document should have a "yell" field which will be converted to uppercase as soon as it's created.
