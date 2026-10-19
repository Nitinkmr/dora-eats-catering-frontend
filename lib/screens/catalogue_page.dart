import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/catering_state.dart';
import '../widgets/food_card.dart';
import '../widgets/order_summary.dart';
import '../models/catalogue_item.dart';

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CateringState>(builder: (context, state, _) {
        final width = MediaQuery.sizeOf(context).width;
        final desktop = width >= 1080;
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _header(context, desktop)),
          SliverToBoxAdapter(child: _hero(context, desktop)),
          if (state.error != null)
            SliverToBoxAdapter(child: _errorPanel(context, state))
          else if (state.isLoading)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
          else if (state.items.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No catalogue items were returned by the API.')))
          else
            SliverToBoxAdapter(child: _catalogueBody(context, state, desktop, width)),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ]);
      }),
    );
  }

  Widget _header(BuildContext context, bool desktop) => Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: desktop ? 64 : 20, vertical: 17),
    child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFC42B2B), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 24)),
      const SizedBox(width: 11),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('dora', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1)), Text('CATERING, MADE EASY', style: TextStyle(fontSize: 8, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: Color(0xFF8A8178)))]),
      const Spacer(),
      if (desktop) ...[
        TextButton(onPressed: () {}, child: const Text('How it works', style: TextStyle(color: Color(0xFF514840)))),
        const SizedBox(width: 10),
        TextButton(onPressed: () {}, child: const Text('Corporate catering', style: TextStyle(color: Color(0xFF514840)))),
        const SizedBox(width: 16),
      ],
      OutlinedButton.icon(onPressed: () => _showHelp(context), icon: const Icon(Icons.support_agent, size: 18), label: const Text('Need help?')),
    ]),
  );

  Widget _hero(BuildContext context, bool desktop) => Container(
    margin: EdgeInsets.fromLTRB(desktop ? 64 : 18, 24, desktop ? 64 : 18, 26),
    padding: EdgeInsets.all(desktop ? 42 : 25),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A211D), Color(0xFF8B3028), Color(0xFFC34A37)])),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(30)), child: const Text('GOOD FOOD. GREAT GATHERINGS.', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800))),
        const SizedBox(height: 17),
        Text('Make every gathering\nworth gathering for.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: desktop ? 38 : 30, height: 1.12, letterSpacing: -.8)),
        const SizedBox(height: 12),
        const Text('Build your menu, choose your portions, and plan a feast everyone will remember.', style: TextStyle(color: Color(0xFFF5DED7), height: 1.55, fontSize: 14)),
        const SizedBox(height: 22),
        const Row(children: [Icon(Icons.check_circle_outline, color: Color(0xFFFFD6B9), size: 18), SizedBox(width: 7), Text('Flexible menus', style: TextStyle(color: Colors.white, fontSize: 12)), SizedBox(width: 16), Icon(Icons.check_circle_outline, color: Color(0xFFFFD6B9), size: 18), SizedBox(width: 7), Text('Simple pricing', style: TextStyle(color: Colors.white, fontSize: 12))]),
      ])),
      if (desktop) ...[
        const SizedBox(width: 22),
        Container(width: 235, height: 190, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), borderRadius: BorderRadius.circular(22)), child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.network('https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=700&q=80', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.dinner_dining, color: Colors.white, size: 80)))),
      ],
    ]),
  );

  Widget _catalogueBody(BuildContext context, CateringState state, bool desktop, double width) {
    final contentWidth = width >= 1440 ? 1320.0 : width;
    final gridWidth = desktop ? contentWidth - 64 * 2 - 350 - 30 : width - 36;
    final columns = gridWidth >= 780 ? 3 : gridWidth >= 520 ? 2 : 1;
    return Center(child: SizedBox(width: contentWidth, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: desktop ? 64 : 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('BUILD YOUR MENU', style: TextStyle(color: Color(0xFFC42B2B), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.6)),
          const SizedBox(height: 7),
          Text('Find your crowd favourites', style: TextStyle(fontSize: desktop ? 27 : 23, fontWeight: FontWeight.w900, letterSpacing: -.4)),
          const SizedBox(height: 6),
          Text('${state.foodItems.length} dishes to make your event delicious', style: const TextStyle(color: Color(0xFF817970), fontSize: 13)),
          const SizedBox(height: 20),
          TextField(onChanged: state.setSearch, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search dishes or categories', contentPadding: EdgeInsets.symmetric(vertical: 13))),
          const SizedBox(height: 14),
          SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: state.categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) {
            final category = state.categories[index]; final active = state.selectedCategory == category;
            return ChoiceChip(label: Text(category), selected: active, onSelected: (_) => state.setCategory(category), selectedColor: const Color(0xFFF5DDD8), side: BorderSide(color: active ? const Color(0xFFC42B2B).withValues(alpha: .5) : const Color(0xFFE9E2DA)), labelStyle: TextStyle(color: active ? const Color(0xFFC42B2B) : const Color(0xFF625950), fontWeight: FontWeight.w700));
          })),
          const SizedBox(height: 14),
          if (state.visibleFoodItems.isEmpty)
            const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No dishes match your search.')))
          else
            LayoutBuilder(builder: (context, constraints) {
              final count = constraints.maxWidth >= 780 ? 3 : constraints.maxWidth >= 520 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 335),
                itemCount: state.visibleFoodItems.length,
                itemBuilder: (context, index) { final item = state.visibleFoodItems[index]; return FoodCard(item: item, selected: state.isFoodSelected(item), onToggle: () => state.toggleFood(item)); },
              );
            }),
          if (state.addOnItems.isNotEmpty) ...[
            const SizedBox(height: 34),
            const Text('Make it extra special', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Add service extras to your catering plan.', style: TextStyle(color: Color(0xFF817970), fontSize: 13)),
            const SizedBox(height: 13),
            ...state.addOnItems.map((item) => _addonCard(item, state)),
          ],
        ])),
        if (desktop) ...[const SizedBox(width: 30), SizedBox(width: 350, child: OrderSummary())],
      ]),
    )));
  }

  Widget _addonCard(CatalogueItem item, CateringState state) => Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), child: Row(children: [
    Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF8EDE7), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.room_service_outlined, color: Color(0xFFC42B2B))),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('${_money(item.fixedPrice)} each', style: const TextStyle(color: Color(0xFF817970), fontSize: 12))])),
    IconButton(onPressed: () => state.setAddOnCount(item, state.addOnCount(item) - 1), icon: const Icon(Icons.remove_circle_outline), color: const Color(0xFFC42B2B)),
    Text('${state.addOnCount(item)}', style: const TextStyle(fontWeight: FontWeight.w800)),
    IconButton(onPressed: () => state.setAddOnCount(item, state.addOnCount(item) + 1), icon: const Icon(Icons.add_circle_outline), color: const Color(0xFFC42B2B)),
  ])));

  Widget _errorPanel(BuildContext context, CateringState state) => Center(child: Container(constraints: const BoxConstraints(maxWidth: 600), margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFECE5DE))), child: Column(children: [const Icon(Icons.cloud_off_outlined, size: 42, color: Color(0xFFC42B2B)), const SizedBox(height: 12), const Text('Could not load the menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF716B65), height: 1.5)), const SizedBox(height: 16), FilledButton.icon(onPressed: state.loadCatalogue, icon: const Icon(Icons.refresh), label: const Text('Try again'))])));

  void _showHelp(BuildContext context) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Need a hand?'), content: const Text('Add your support phone number or help URL here when it is available.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
  static String _money(double value) => '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
}
