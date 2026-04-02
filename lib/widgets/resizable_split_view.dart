import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ResizableSplitView extends StatefulWidget {
  final Widget first;
  final Widget second;
  final Axis axis;
  final double initialFraction;

  const ResizableSplitView({
    Key? key,
    required this.first,
    required this.second,
    this.axis = Axis.horizontal,
    this.initialFraction = 0.5,
  }) : super(key: key);

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  late double _fraction;

  @override
  void initState() {
    super.initState();
    _fraction = widget.initialFraction;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = widget.axis == Axis.horizontal;
        // Adjust for handle size so we don't overflow constraints. Wait, constraints might be infinity? It shouldn't be.
        final handleSize = 8.0;
        final maxSize = isHorizontal ? constraints.maxWidth - handleSize : constraints.maxHeight - handleSize;

        // If constraints are somehow 0 or less, avoid weird rendering.
        if (maxSize <= 0) return const SizedBox();

        return Flex(
          direction: widget.axis,
          children: [
            SizedBox(
              width: isHorizontal ? maxSize * _fraction : null,
              height: isHorizontal ? null : maxSize * _fraction,
              child: widget.first,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  final delta = isHorizontal ? details.delta.dx : details.delta.dy;
                  _fraction += delta / maxSize;
                  _fraction = _fraction.clamp(0.1, 0.9);
                });
              },
              child: MouseRegion(
                cursor: isHorizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
                child: Container(
                  width: isHorizontal ? handleSize : double.infinity,
                  height: isHorizontal ? double.infinity : handleSize,
                  color: AppColors.panelBackground, // Distinct split color
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thin divider line
                      Container(
                        width: isHorizontal ? 1 : double.infinity,
                        height: isHorizontal ? double.infinity : 1,
                        color: AppColors.border,
                      ),
                      // Grab indicator
                      Container(
                        width: isHorizontal ? 2 : 24,
                        height: isHorizontal ? 24 : 2,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryText,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: widget.second,
            ),
          ],
        );
      },
    );
  }
}
