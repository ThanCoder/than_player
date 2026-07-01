enum VideoFolderType {
  allVideo,
  allFolders;

  static VideoFolderType fromName(String type) {
    if (type == allFolders.name) return allFolders;
    return allVideo;
  }
}
