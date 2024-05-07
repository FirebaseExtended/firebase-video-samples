package com.notes.app.model.service.module

import com.notes.app.model.service.AccountService
import com.notes.app.model.service.StorageService
import com.notes.app.model.service.impl.AccountServiceImpl
import com.notes.app.model.service.impl.StorageServiceImpl
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
abstract class ServiceModule {
  @Binds abstract fun provideAccountService(impl: AccountServiceImpl): AccountService

  @Binds abstract fun provideStorageService(impl: StorageServiceImpl): StorageService
}
