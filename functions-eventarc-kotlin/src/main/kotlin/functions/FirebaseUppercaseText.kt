package functions

import com.google.cloud.firestore.Firestore
import com.google.cloud.functions.CloudEventsFunction
import com.google.events.cloud.firestore.v1.DocumentEventData
import com.google.firebase.FirebaseApp
import com.google.firebase.cloud.FirestoreClient
import com.google.protobuf.InvalidProtocolBufferException
import io.cloudevents.CloudEvent
import java.util.Locale
import java.util.concurrent.ExecutionException
import java.util.logging.Logger

class FirebaseUppercaseText : CloudEventsFunction {
  @Throws(InvalidProtocolBufferException::class)
  override fun accept(cloudEvent: CloudEvent) {
    logger.info("Function started executing")
    logger.warning(cloudEvent.toString())
    var docPath = cloudEvent.getExtension("document")
    if(docPath !is String) {
      logger.warning("Document path needs to be a String");
      return;
    }
    val eventData = cloudEvent.data ?: return
    val docEventData: DocumentEventData = DocumentEventData.parseFrom(eventData.toBytes())
    val docValue = docEventData.value ?: return
    if (!docValue.containsFields("yell")) {
      logger.warning("No field named 'yell' on document, exiting")
      return
    }
    val name: String = docValue.fieldsMap.get("yell")?.let { it.stringValue } ?: {""}.toString()
    if (name === uppercaseText(name)) {
      logger.warning("Field is already uppercase")
      return
    }
    writeToDatabase(uppercaseText(name), docPath)
  }

  private fun uppercaseText(text: String): String = text.uppercase(Locale.getDefault())

  private fun writeToDatabase(text: String, path: String) {
    val db: Firestore = FirestoreClient.getFirestore(app)
    try {
      db.document(path).update("yell", text).get()
    } catch (e: InterruptedException) {
      logger.severe(e.message)
    } catch (e: ExecutionException) {
      logger.severe(e.message)
    }
  }
  companion object {
    private val logger: Logger = Logger.getLogger(FirebaseUppercaseText::class.java.name)
    // USE THE ADC TO INIT THE APP
    private val app: FirebaseApp = FirebaseApp.initializeApp()
  }
}