// Utility functions for Firestore operations

/// Converts an integer ID to a Firestore document ID (string)
String idToDocId(int? id) {
  if (id == null) return '';
  return id.toString();
}

/// Converts a Firestore document ID (string) to an integer ID
int? docIdToId(String docId) {
  return int.tryParse(docId);
}

/// Generates a new document ID for Firestore
String generateDocId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

