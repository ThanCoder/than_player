enum VideoFolderType {
  allVideo,
  allFolders;

  static VideoFolderType fromName(String name) {
    if (name == allFolders.name) allFolders;
    return allVideo;
  }
}
