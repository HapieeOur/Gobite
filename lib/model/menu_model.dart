// menu_model.dart

class Variant {
  final String name;
  final int extraPrice;

  Variant({required this.name, required this.extraPrice});

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      name: json['name'] ?? 'Regular',
      extraPrice: json['extraPrice'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'extraPrice': extraPrice,
      };
}

class MenuModel {
  final int id;
  final String name;
  final String price;
  final String category;
  final String rating;
  final String descr;
  final String image;
  final List<Variant> variants;
  

  MenuModel(
    this.id,
    this.name,
    this.price,
    this.category,
    this.rating,
    this.descr,
    this.image, {
    this.variants = const [],
    
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    var variantList = <Variant>[];
    if (json['variants'] != null) {
      variantList = (json['variants'] as List)
          .map((v) => Variant.fromJson(v))
          .toList();
    }

    return MenuModel(
      json['id'] ?? 0,
      json['name'] ?? '',
      json['price']?.toString() ?? '0',
      json['category'] ?? '',
      json['rating']?.toString() ?? '0',
      json['descr'] ?? '',
      json['image'] ?? '',
      variants: variantList,
      
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'rating': rating,
        'descr': descr,
        'image': image,

        'variants': variants.map((v) => v.toJson()).toList(),
      };
}