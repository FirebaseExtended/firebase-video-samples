//
//  VideoView.swift
//  Favourites (iOS)
//
//  Created by Peter Friese on 23.10.23.
//  Copyright © 2021 Google LLC. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import AVKit
import PhotosUI
import FirebaseStorage

struct Movie: Transferable {
  let url: URL

  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .movie) { movie in
      SentTransferredFile(movie.url)
    } importing: { received in
      let copy = URL.documentsDirectory.appending(path: "movie.mp4")

      if FileManager.default.fileExists(atPath: copy.path()) {
        try FileManager.default.removeItem(at: copy)
      }

      try FileManager.default.copyItem(at: received.file, to: copy)
      return Self.init(url: copy)
    }
  }
}

struct VideoView: View {
  @State var videoProgress: Double?
  @State var downloadProgress: Double?
  @State var selectedVideo: PhotosPickerItem?
  
  @State var storageVideoURL: URL?
  @State var downloadedURL: URL?

  var streamPlayer: AVPlayer? {
    guard let storageVideoURL else { return nil }
    return AVPlayer(url: storageVideoURL)
  }

  var downloadPlayer: AVPlayer? {
    guard let downloadedURL else { return nil }
    return AVPlayer(url: downloadedURL)
  }

  func uploadVideo(from localURL: URL) async {
    let videoReference = Storage.storage().reference(withPath: "videos/example.mp4")

    let metaData = StorageMetadata()
    metaData.contentType = "video/mp4"

    do {
      let resultMetaData = try await videoReference.putFileAsync(from: localURL, metadata: metaData) { progress in
        if let progress {
          self.videoProgress = progress.fractionCompleted
          if progress.isFinished {
            self.videoProgress = nil
          }
        }
      }
      print("Upload finished. Metadata: \(resultMetaData)")
      storageVideoURL = try await videoReference.downloadURL()
    }
    catch {
      print("Error while uploading: \(error.localizedDescription)")
    }
  }

  func downloadVideo() async {
    let videoReference = Storage.storage().reference(withPath: "videos/example.mp4")
    let localURL = URL.documentsDirectory.appending(path: "download.mp4")
    do {
      downloadedURL = try await videoReference.writeAsync(toFile: localURL) { progress in
        if let progress {
          self.downloadProgress = progress.fractionCompleted
          if progress.isFinished {
            self.downloadProgress = nil
          }
        }
      }
    }
    catch {
      print(error)
    }
  }

  var body: some View {
    Form {
      Section("Upload") {
        PhotosPicker("Select a movie for uploading", selection: $selectedVideo, matching: .videos)
          .task(id: selectedVideo) {
            do {
              let movie = try await selectedVideo?.loadTransferable(type: Movie.self)
              if let url = movie?.url {
                  print(url)
                  await uploadVideo(from: url)
              }
            }
            catch {
              print(error.localizedDescription)
            }
          }
        if let videoProgress {
          ProgressView(value: videoProgress, total: 1) {
            Text("Uploading...")
          } currentValueLabel: {
            Text(videoProgress.formatted(.percent.precision(.fractionLength(0))))
          }
        }

      }

      Section("Download") {
        Button("Download") {
          Task {
            await downloadVideo()
          }
        }
        if let downloadProgress {
          ProgressView(value: downloadProgress, total: 1) {
            Text("Downloading...")
          } currentValueLabel: {
            Text(downloadProgress.formatted(.percent.precision(.fractionLength(0))))
          }
        }
        if let downloadPlayer {
          VideoPlayer(player: downloadPlayer)
            .frame(height: 400)
            .onAppear() {
              downloadPlayer.play()
            }
        }
      }

      Section("Stream") {
        if let streamPlayer {
          VideoPlayer(player: streamPlayer)
            .frame(height: 400)
            .onAppear() {
              streamPlayer.play()
            }
        }
      }
    }
  }
}

#Preview {
  VideoView()
}
