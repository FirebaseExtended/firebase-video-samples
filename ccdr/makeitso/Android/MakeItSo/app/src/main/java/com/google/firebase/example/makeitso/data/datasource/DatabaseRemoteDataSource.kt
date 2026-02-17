package com.google.firebase.example.makeitso.data.datasource

import com.google.firebase.firestore.FirebaseFirestore
import javax.inject.Inject

class DatabaseRemoteDataSource @Inject constructor(
    private val firestore: FirebaseFirestore
) {

}