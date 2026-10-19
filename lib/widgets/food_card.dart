import 'package:flutter/material.dart';
import '../models/catalogue_item.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required this.item, required this.selected, required this.onToggle});
  final CatalogueItem item;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1.65,
          child: Stack(fit: StackFit.expand, children: [
            if (image != null && image.startsWith('http'))
              Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
            else
              _placeholder(),
            Positioned(left: 12, top: 12, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF218653), borderRadius: BorderRadius.circular(2), border: Border.all(color: const Color(0xFF218653)))),
                const SizedBox(width: 6), const Text('VEG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .5)),
              ]),
            )),
          ]),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(15, 13, 15, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('${_money(item.perPersonPrice)} / person', style: const TextStyle(color: Color(0xFF716B65), fontSize: 13)),
          if (item.quantityPerPerson != null) ...[
            const SizedBox(height: 3),
            Text('${_quantity(item.quantityPerPerson!)} per person', style: const TextStyle(color: Color(0xFF89827B), fontSize: 12)),
          ],
          if (item.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF716B65), fontSize: 12)),
          ],
          const SizedBox(height: 13),
          SizedBox(width: double.infinity, child: selected
            ? OutlinedButton.icon(onPressed: onToggle, icon: const Icon(Icons.check_circle, size: 18), label: const Text('Added'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC42B2B), side: const BorderSide(color: Color(0xFFC42B2B))))
            : FilledButton.icon(onPressed: onToggle, icon: const Icon(Icons.add, size: 18), label: const Text('Add dish'))),
        ])),
      ]),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFF0E9E1),
    child: const Center(child: Icon(Icons.restaurant_menu_rounded, size: 42, color: Color(0xFFB5A69A))),
  );
  static String _money(double value) => '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  static String _quantity(double value) => value == value.roundToDouble() ? '${value.toInt()} g' : '$value g';
}
