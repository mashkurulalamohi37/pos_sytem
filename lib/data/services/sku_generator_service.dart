import 'dart:math';
import 'package:uuid/uuid.dart';

class SkuGeneratorService {
  static const _uuid = Uuid();

  /// Generates a SKU based on the specified pattern
  /// 
  /// Available placeholders:
  /// - {category} - Category prefix (if provided)
  /// - {name} - Product name prefix
  /// - {random} - Random alphanumeric string
  /// - {number} - Sequential number (if provided)
  /// - {date} - Current date in format YYYYMMDD
  static String generateSku({
    required String pattern,
    required String productName,
    String? categoryPrefix,
    int? sequentialNumber,
  }) {
    String sku = pattern;
    
    // Replace category placeholder
    if (sku.contains('{category}')) {
      final categoryText = categoryPrefix ?? 'PROD';
      sku = sku.replaceAll('{category}', categoryText.toUpperCase());
    }
    
    // Replace name placeholder with first letters of each word
    if (sku.contains('{name}')) {
      final namePrefix = _generateNamePrefix(productName);
      sku = sku.replaceAll('{name}', namePrefix.toUpperCase());
    }
    
    // Replace random placeholder with random string
    if (sku.contains('{random}')) {
      final randomString = _generateRandomString(6);
      sku = sku.replaceAll('{random}', randomString);
    }
    
    // Replace number placeholder with sequential number
    if (sku.contains('{number}')) {
      final number = sequentialNumber?.toString().padLeft(4, '0') ?? '0001';
      sku = sku.replaceAll('{number}', number);
    }
    
    // Replace date placeholder with current date
    if (sku.contains('{date}')) {
      final now = DateTime.now();
      final dateString = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      sku = sku.replaceAll('{date}', dateString);
    }
    
    return sku;
  }
  
  /// Generates a completely random SKU
  static String generateRandomSku() {
    return _uuid.v4().substring(0, 8).toUpperCase();
  }
  
  /// Generates a prefix from the product name by taking the first letter of each word
  static String _generateNamePrefix(String productName) {
    if (productName.isEmpty) return 'PROD';
    
    final words = productName.split(' ');
    if (words.isEmpty) return productName.substring(0, min(3, productName.length));
    
    String prefix = '';
    for (final word in words) {
      if (word.isNotEmpty) {
        prefix += word[0];
      }
    }
    
    // If prefix is too short, add more characters from the first word
    if (prefix.length < 2 && words[0].length > 1) {
      prefix += words[0].substring(1, min(3, words[0].length));
    }
    
    return prefix;
  }
  
  /// Generates a random alphanumeric string of the specified length
  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length, 
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
