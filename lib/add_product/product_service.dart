import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tg_erp/add_product/models/variant.dart';

class ProductService {
  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  // ────────────────────────────────────────────────────────────────────────────
  // Storage
  Future<String?> uploadToSupabase(File file) async {
    final filePath =
        'products/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final bytes = await file.readAsBytes();
    final response =
    await _supabase.storage.from('erp').uploadBinary(filePath, bytes);
    if (response.isEmpty) return null;
    return _supabase.storage.from('erp').getPublicUrl(filePath);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Search / Read
  Future<PaginatedResult> searchProductsByName({
    required String searchText,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final lower = searchText.toLowerCase();

    final filteredDocs = snapshot.docs.where((doc) {
      final name = (doc['name'] ?? '').toString().toLowerCase();
      return name.contains(lower);
    }).toList();

    final items = filteredDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, ...data};
    }).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return PaginatedResult(items: items, lastDoc: lastDoc);
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Create (Variant-only: prices/expiry are inside Variant)
  Future<void> saveProduct({
    required String name,
    required List<String> imageUrls,
    required List<Variant> variants, // must be non-empty
    String? category,
    String? description,
    bool showInWeb = false,
    List<String>? tags,
  }) async {
    if (variants.isEmpty) {
      throw ArgumentError('variants cannot be empty');
    }

    final data = <String, dynamic>{
      'name': name,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
      'showInWeb': showInWeb,
      'variants': variants.map((v) => v.toMap()).toList(),
      'hasVariants': true,
    };

    if (category != null) data['category'] = category;
    if (description != null) data['description'] = description;
    if (tags != null) data['tags'] = tags;

    await _firestore.collection('products').add(data);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Update (no product-level buyingPrice/mrp/expiryDate)
  Future<void> updateProduct({
    required String id,
    String? name,
    List<String>? imageUrls,
    String? imageUrl, // legacy single if you still need it
    String? category,
    String? description,
    bool? showInWeb,
    List<Variant>? variants, // replaces the whole array if provided
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;

    if (imageUrls != null) {
      data['imageUrls'] = imageUrls;
    } else if (imageUrl != null) {
      data['imageUrl'] = imageUrl; // legacy single
    }

    if (category != null) data['category'] = category;
    if (description != null) data['description'] = description;
    if (showInWeb != null) data['showInWeb'] = showInWeb;

    if (variants != null) {
      data['variants'] = variants.map((v) => v.toMap()).toList();
      data['hasVariants'] = variants.isNotEmpty;
    }

    if (data.isEmpty) return;
    await _firestore.collection('products').doc(id).update(data);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Variant helpers
  Future<void> updateVariants(String productId, List<Variant> variants) async {
    await _firestore.collection('products').doc(productId).update({
      'variants': variants.map((v) => v.toMap()).toList(),
      'hasVariants': variants.isNotEmpty,
    });
  }

  Future<void> addVariant(String productId, Variant variant) async {
    final ref = _firestore.collection('products').doc(productId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = (snap.data() ?? {}) as Map<String, dynamic>;
      final existing = (data['variants'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      existing.add(variant.toMap());
      tx.update(ref, {
        'variants': existing,
        'hasVariants': existing.isNotEmpty,
      });
    });
  }

  Future<void> removeVariantsAt(String productId, List<int> indexes) async {
    final ref = _firestore.collection('products').doc(productId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = (snap.data() ?? {}) as Map<String, dynamic>;
      final existing = (data['variants'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      indexes.toSet().toList()
        ..sort((a, b) => b.compareTo(a))
        ..forEach((i) {
          if (i >= 0 && i < existing.length) existing.removeAt(i);
        });

      tx.update(ref, {
        'variants': existing,
        'hasVariants': existing.isNotEmpty,
      });
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Misc
  Future<String?> reuploadProductImage(File file) async {
    final filePath =
        'products/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final bytes = await file.readAsBytes();
    final res =
    await _supabase.storage.from('erp').uploadBinary(filePath, bytes);
    if (res.isEmpty) return null;
    return _supabase.storage.from('erp').getPublicUrl(filePath);
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}

class PaginatedResult {
  final List<Map<String, dynamic>> items;
  final DocumentSnapshot? lastDoc;

  PaginatedResult({required this.items, required this.lastDoc});
}
