import 'package:flutter/material.dart';
import 'tools/one_rep_max_screen.dart';
import 'tools/plate_calculator_screen.dart';

class FitnessToolsHubScreen extends StatelessWidget {
  const FitnessToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolTile(
          context,
          title: '1RM (Tek Tekrar Maksimumu) Hesaplayıcı',
          desc: 'Kaldırdığın ağırlık ve tekrardan maksimum kaldırabileceğin tek tekrarı bilimsel formülle hesapla.',
          icon: '🏋️‍♂️',
          color: const Color(0xFF06B6D4),
          target: const OneRepMaxScreen(),
        ),
        const SizedBox(height: 12),
        _buildToolTile(
          context,
          title: 'Barbell Plaka Dağılım Hesaplayıcı',
          desc: 'Hedeflenen toplam ağırlık için bara hangi plakalardan kaçar tane takman gerektiğini gör.',
          icon: '🧮',
          color: const Color(0xFFF59E0B),
          target: const PlateCalculatorScreen(),
        ),
      ],
    );
  }

  Widget _buildToolTile(BuildContext context, {
    required String title,
    required String desc,
    required String icon,
    required Color color,
    required Widget target,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => target));
          },
        ),
      ),
    );
  }
}
