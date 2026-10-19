class CatalogueItem {
  const CatalogueItem({
    required this.categoryId,
    required this.displayName,
    required this.type,
    this.pricePerPerson,
    this.quantityPerPerson,
    this.price,
    this.categoryName,
    this.description,
    this.imageUrl,
    this.id,
  });

  final String categoryId;
  final String displayName;
  final String type;
  final double? pricePerPerson;
  final double? quantityPerPerson;
  final double? price;
  final String? categoryName;
  final String? description;
  final String? imageUrl;
  final String? id;

  bool get isFood => type.toLowerCase() == 'food';
  bool get isAddOn => type.toLowerCase() == 'add-on' || type.toLowerCase() == 'addon';
  double get perPersonPrice => pricePerPerson ?? 0;
  double get fixedPrice => price ?? 0;
  String get categoryLabel => (categoryName?.trim().isNotEmpty ?? false) ? categoryName!.trim() : _humanize(categoryId);
  String get stableId => id ?? '${type.toLowerCase()}::$categoryId::${displayName.toLowerCase()}';

  factory CatalogueItem.fromJson(Map<String, dynamic> json) {
    double? number(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '').replaceAll('₹', '').trim());
    }

    return CatalogueItem(
      id: json['id']?.toString() ?? json['itemId']?.toString(),
      categoryId: (json['categoryId'] ?? 'other').toString(),
      categoryName: json['categoryName']?.toString() ?? json['categoryDisplayName']?.toString(),
      displayName: (json['displayName'] ?? json['name'] ?? 'Unnamed item').toString(),
      type: (json['type'] ?? 'food').toString(),
      pricePerPerson: number(json['pricePerPerson']),
      quantityPerPerson: number(json['quantityPerPerson']),
      price: number(json['price']),
      description: json['description']?.toString(),
      imageUrl: (json['imageUrl'] ?? json['image'] ?? json['photoUrl'])?.toString(),
    );
  }

  static String _humanize(String input) {
    final words = input.replaceAll(RegExp(r'[-_]+'), ' ').split(' ');
    return words.where((w) => w.isNotEmpty).map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
