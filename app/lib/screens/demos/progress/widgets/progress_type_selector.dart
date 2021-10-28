import 'package:fh_meet/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress/progress.dart';

class ProgressTypeSelector extends StatelessWidget {
  const ProgressTypeSelector({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  final Function(ProgressType type) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _items,
      ),
    );
  }

  Widget _buildItem(ProgressType type) {
    return Button(
      text: describeEnum(type),
      onTap: () => onChanged(type),
    );
  }

  List<Widget> get _items {
    return ProgressType.values.map(_buildItem).toList();
  }
}
