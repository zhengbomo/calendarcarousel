import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class AnimatedAspectRatio extends ImplicitlyAnimatedWidget {
  AnimatedAspectRatio({
    Key key,
    @required this.aspectRatio,
    this.child,
    Curve curve = Curves.linear,
    @required Duration duration,
  }) : assert(aspectRatio != null),
       assert(aspectRatio.isFinite),
       super(key: key, curve: curve, duration: duration);
  
  final double aspectRatio;
  
  final Widget child;

  @override
  _AnimatedAspectRatioState createState() => _AnimatedAspectRatioState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('aspectRatio', aspectRatio));
  }
}

class _AnimatedAspectRatioState extends AnimatedWidgetBaseState<AnimatedAspectRatio> {
  Tween<double> _aspectRatio;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _aspectRatio = visitor(_aspectRatio, widget.aspectRatio, (dynamic value) {
      return Tween<double>(begin: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio.evaluate(animation),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<Tween<double>>('aspectRatio', _aspectRatio, defaultValue: null));
  }
}