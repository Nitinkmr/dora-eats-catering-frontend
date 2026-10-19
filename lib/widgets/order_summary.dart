import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/catering_state.dart';
import '../models/catalogue_item.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer<CateringState>(builder: (context, state, _) {
      return Container(
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE5DE))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Expanded(child: Text('Your catering plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), if (state.selectedFoods.isNotEmpty || state.selectedAddOns.isNotEmpty) TextButton(onPressed: state.clearCart, child: const Text('Clear'))]),
          const SizedBox(height: 16),
          const Text('NUMBER OF GUESTS', style: TextStyle(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: Color(0xFF817970))),
          const SizedBox(height: 8),
          Row(children: [
            _roundControl(Icons.remove, state.guests <= 1, () => state.setGuests(state.guests - 1)),
            Expanded(child: Center(child: Text('${state.guests} guests', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
            _roundControl(Icons.add, state.guests >= 10000, () => state.setGuests(state.guests + 1)),
          ]),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          if (state.selectedFoods.isEmpty && state.selectedAddOns.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Center(child: Column(children: [Icon(Icons.tapas_outlined, size: 30, color: Color(0xFFB6AAA0)), SizedBox(height: 8), Text('Your menu is waiting', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Add dishes to start planning', style: TextStyle(fontSize: 12, color: Color(0xFF817970))) ])))
          else ...[
            ...state.selectedFoods.map((item) => _line(item.displayName, '${state.guests} × ${_money(item.perPersonPrice)}', item.perPersonPrice * state.guests)),
            if (state.selectedAddOns.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('ADD-ON SERVICES', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w800, color: Color(0xFF817970))),
              const SizedBox(height: 8),
              ...state.selectedAddOns.map((item) => _addonLine(context, item, state)),
            ],
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _totalLine('Food subtotal', state.foodTotal),
          const SizedBox(height: 8),
          _totalLine('Add-ons', state.addOnTotal),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFECE5DE)),
          const SizedBox(height: 14),
          Row(children: [const Expanded(child: Text('Estimated total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))), Text(_money(state.total), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Color(0xFFC42B2B)))]),
          const SizedBox(height: 5),
          const Text('Taxes, delivery and final availability may be confirmed at booking.', style: TextStyle(fontSize: 11, color: Color(0xFF817970), height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: state.selectedFoods.isEmpty ? null : () => _showBookingDialog(context, state),
            icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Continue to event details'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          )),
        ]),
      );
    });
  }

  Widget _addonLine(BuildContext context, CatalogueItem item, CateringState state) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text('${_money(item.fixedPrice)} each', style: const TextStyle(color: Color(0xFF817970), fontSize: 11))])),
      _roundControl(Icons.remove, false, () => state.setAddOnCount(item, state.addOnCount(item) - 1), small: true),
      SizedBox(width: 28, child: Center(child: Text('${state.addOnCount(item)}', style: const TextStyle(fontWeight: FontWeight.w700)))),
      _roundControl(Icons.add, false, () => state.setAddOnCount(item, state.addOnCount(item) + 1), small: true),
    ]),
  );

  Widget _line(String name, String detail, double total) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(detail, style: const TextStyle(fontSize: 11, color: Color(0xFF817970)))])), Text(_money(total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]));
  Widget _totalLine(String label, double amount) => Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF716B65), fontSize: 13))), Text(_money(amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]);
  Widget _roundControl(IconData icon, bool disabled, VoidCallback onTap, {bool small = false}) => SizedBox(width: small ? 27 : 36, height: small ? 27 : 36, child: IconButton.filledTonal(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, onPressed: disabled ? null : onTap, icon: Icon(icon, size: small ? 15 : 18), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF7F0EA), foregroundColor: const Color(0xFF4B4038), disabledBackgroundColor: const Color(0xFFF7F0EA))));

  void _showBookingDialog(BuildContext context, CateringState state) {
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Event details'),
      content: Text('Your menu for ${state.guests} guests is ready to review. Connect this button to your booking API to submit the order.\n\nEstimated total: ${_money(state.total)}'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Keep editing')), FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Got it'))],
    ));
  }
  static String _money(double value) => '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
}
