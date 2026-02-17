package com.google.firebase.example.makeitso.ui.newTask

import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class NewTaskViewModel @Inject constructor(
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {

}