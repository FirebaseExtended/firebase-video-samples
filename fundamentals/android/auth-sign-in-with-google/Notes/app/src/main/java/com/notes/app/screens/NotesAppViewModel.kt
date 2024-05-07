package com.notes.app.screens

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.notes.app.ERROR_TAG
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

open class NotesAppViewModel : ViewModel() {
  fun launchCatching(block: suspend CoroutineScope.() -> Unit) =
    viewModelScope.launch(
      CoroutineExceptionHandler { _, throwable ->
        Log.d(ERROR_TAG, throwable.message.orEmpty())
      },
      block = block
    )
}
