import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/nepal_location.dart';


class Step1Location extends StatelessWidget {
  final String? province, district, municipality;
  final ValueChanged<String?> onProvince, onDistrict, onMunicipality;
  const Step1Location({
    required this.province,
    required this.district,
    required this.municipality,
    required this.onProvince,
    required this.onDistrict,
    required this.onMunicipality,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'स्थान छान्नुहोस्',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'आफू नजिकको डाक्टर खोज्न स्थान छान्नुहोस्',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 24),

        // Province
        _LocDrop(
          icon: Icons.map_outlined,
          label: 'प्रदेश / Province *',
          hint: 'प्रदेश छान्नुहोस्',
          value: province,
          items: NepalLocation.provinces,
          onChanged: onProvince,
        ),
        const SizedBox(height: 14),

        // District — populated after province selected
        _LocDrop(
          icon: Icons.location_city_outlined,
          label: 'जिल्ला / District *',
          hint: province == null
              ? 'पहिले प्रदेश छान्नुहोस्'
              : 'जिल्ला छान्नुहोस्',
          value: district,
          enabled: province != null,
          items: province != null ? NepalLocation.districtsOf(province!) : [],
          onChanged: onDistrict,
        ),
        const SizedBox(height: 14),

        // Municipality — optional, populated after district selected
        // Shows type label (म.न.पा. / उप.म.न.पा. / न.पा. / गा.पा.) in dropdown
        _LocDrop(
          icon: Icons.apartment_outlined,
          label: 'नगरपालिका / Municipality (वैकल्पिक)',
          hint: district == null ? 'पहिले जिल्ला छान्नुहोस्' : 'सबै (जिल्लाभर)',
          value: municipality,
          enabled: district != null,
          items: district != null
              ? [
                  '',
                  ...NepalLocation.municipalitiesOf(province ?? '', district!),
                ]
              : [],
          display: (v) {
            if (v.isEmpty) return 'सबै (जिल्लाभर)';
            // Append unit type label for clarity
            final typeLabel = NepalLocation.typeLabel(v);
            return typeLabel.isNotEmpty ? '$v ($typeLabel)' : v;
          },
          onChanged: onMunicipality,
        ),
        const SizedBox(height: 20),

        // Selected location summary pill
        if (province != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    [
                      province,
                      if (district != null) district,
                      if (municipality != null && municipality!.isNotEmpty)
                        municipality,
                    ].join(' › '),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _LocDrop extends StatelessWidget {
  final IconData icon;
  final String label, hint;
  final String? value;
  final List<String> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final String Function(String)? display;
  const _LocDrop({
    required this.icon,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.display,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 13, color: AppConstants.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: (value != null && items.contains(value)) ? value : null,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                hint,
                style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              ),
            ),
            isExpanded: true,
            icon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        display != null ? display!(item) : item,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: enabled ? onChanged : null,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );
}
