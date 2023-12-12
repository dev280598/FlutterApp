import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/screens/widget/shirt_child_widget.dart';

// import 'shirt_child_render_box.dart';

class TravelingBagWidget extends MultiChildRenderObjectWidget {
  const TravelingBagWidget({
    Key? key,
    List<ShirtWidget> children = const [],
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      TravelingBagRenderObject();

  @override
  void updateRenderObject(
    BuildContext context,
    covariant TravelingBagRenderObject renderObject,
  ) {}
}

class TravelingBagRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TravelingBagParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TravelingBagParentData> {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TravelingBagParentData) {
      child.parentData = TravelingBagParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  /// The [performLayout] is where we handle positioning of children widgets
  /// using offsets
  @override
  void performLayout() {
    size = getDryLayout(constraints);
    _performLayout(constraints);

    var childOffset = const Offset(0, 0);

    loopThroughChildren(
      actionToPerform: (
        fillRightColumn,
        child,
        isRightColumnTopMostItem,
        isLeftColumnTopMostItem,
      ) {
        final childParentData = child!.parentData as TravelingBagParentData;

        if (fillRightColumn) {
          childOffset = _computeRightColumnChildOffset(
            isRightColumnTopMostItem,
            childOffset,
            childParentData,
            child,
          );
        } else {
          childOffset = _computeLeftColumnChildOffset(
            isLeftColumnTopMostItem,
            childParentData,
            childOffset,
            child,
          );
        }
      },
    );
  }

  /// [constraints] this is the constraints of the parent
  /// This method lays out it's children based on the constraint.
  /// It tell it's children the constraint left and the children are
  /// required to obey
  void _performLayout(BoxConstraints constraints) {
    double rowWidth =
        childCount > 1 ? constraints.maxWidth / 2 : constraints.maxWidth;

    loopThroughChildren(
      actionToPerform: (fillRightColumn, child, _, __) {
        child!.layout(
          _childConstraints(
            rowWidth,
            fillRightColumn,
            constraints,
            rightColumCount,
            leftColumnCount,
          ),
          parentUsesSize: true,
        );
      },
    );
  }

  /// This method aligns first child to the right (left column + childWidth) and
  /// subsequent children to the right and bottom of previous child
  Offset _computeRightColumnChildOffset(
    bool isRightColumnTopMostItem,
    Offset childOffset,
    TravelingBagParentData childParentData,
    RenderBox child,
  ) {
    double dxOffset = child.size.width;

    if (isRightColumnTopMostItem) {
      dxOffset = dxOffset + childOffset.dx;
      debugPrint('TOP MOST RIGHT WIDGET');

      childOffset = Offset(dxOffset, 0);
    } else {
      childOffset = Offset(
        dxOffset,
        (child.size.height + childOffset.dy),
      );
    }
    childParentData.offset = childOffset;
    return childOffset;
  }

  /// This method aligns first child to the Left and
  /// subsequent children to the left and bottom of previous child
  Offset _computeLeftColumnChildOffset(
    bool isLeftColumnTopMostItem,
    TravelingBagParentData childParentData,
    Offset childOffset,
    RenderBox child,
  ) {
    if (isLeftColumnTopMostItem) {
      childOffset = Offset(
        0,
        childOffset.dy,
      );
    } else {
      childOffset = Offset(
        0,
        child.size.height + childOffset.dy,
      );
    }

    childParentData.offset = childOffset;

    return childOffset;
  }

  /// Computes the constraints of this child, based on parents space left
  BoxConstraints _childConstraints(
    double rowWidth,
    bool fillRightColumn,
    BoxConstraints constraints,
    int? rightColumCount,
    int leftColumnCount,
  ) {
    return BoxConstraints(
      maxWidth: rowWidth,
      maxHeight: _getChildMaxHeight(
        fillRightColumn,
        constraints,
        rightColumCount,
        leftColumnCount,
      ),
    );
  }

  double _getChildMaxHeight(
    bool fillRightColumn,
    BoxConstraints constraints,
    int? rightColumCount,
    int leftColumnCount,
  ) {
    return fillRightColumn
        ? constraints.maxHeight / (rightColumCount ?? 0)
        : constraints.maxHeight / leftColumnCount;
  }

  /// Just a method to loop through children
  /// [actionToPerform] a callback method to perform a task for each loop
  void loopThroughChildren({
    required Function(
      bool fillRightColumn,
      RenderBox? child,
      bool isFirstRightColumnItem,
      bool isFirstLeftColumnItem,
    ) actionToPerform,
  }) {
    RenderBox? child = firstChild;

    /// A flag to know when to start filling in right column
    bool fillRightColumn = false;

    /// This is to track the number of widgets rendered on the left column
    int leftColumnRenderedRecord = leftColumnCount;

    /// This is to track when first item on the right column is rendered
    bool isRightColumnTopMostItem = false;

    while (child != null) {
      final childParentData = child.parentData as TravelingBagParentData;

      if (leftColumnRenderedRecord <= 0) {
        if (leftColumnRenderedRecord == 0) {
          isRightColumnTopMostItem = true;
        } else {
          isRightColumnTopMostItem = false;
        }
        fillRightColumn = true;
      }

      actionToPerform(
        fillRightColumn,
        child,
        isRightColumnTopMostItem,
        leftColumnRenderedRecord == leftColumnCount,
      );

      child = childParentData.nextSibling;
      leftColumnRenderedRecord--;
    }
  }

  double get widgetDivision => (childCount / 2);

  int get leftColumnCount => widgetDivision.round();

  int? get rightColumCount => childCount > 1 ? widgetDivision.toInt() : null;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return constraints.maxHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return constraints.maxHeight;
  }
}

class TravelingBagParentData extends ContainerBoxParentData<RenderBox> {}
