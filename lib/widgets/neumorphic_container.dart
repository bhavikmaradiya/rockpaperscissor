import 'package:flutter/material.dart';

class NeumorphicContainer extends StatefulWidget {
  final Widget child;
  final double bevel;
  final Offset blurOffset;
  final Color? color;
  final Function()? onTap;
  final EdgeInsets? padding;

  NeumorphicContainer({
    super.key,
    required this.child,
    this.bevel = 10.0,
    this.color,
    this.onTap,
    this.padding,
  }) : blurOffset = Offset(bevel / 2, bevel / 2);

  @override
  _NeumorphicContainerState createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    if (mounted) {
      setState(() {
        _isPressed = true;
        widget.onTap?.call();
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (mounted) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = this.widget.color ?? Theme.of(context).colorScheme.background;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ?? const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.bevel * 10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isPressed ? color : color.mix(Colors.black, .1),
              _isPressed ? color.mix(Colors.black, .05) : color,
              _isPressed ? color.mix(Colors.black, .05) : color,
              color.mix(Colors.white, _isPressed ? .2 : .5),
            ],
            stops: [
              0.0,
              .3,
              .6,
              1.0,
            ],
          ),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    blurRadius: widget.bevel,
                    offset: -widget.blurOffset,
                    color: color.mix(Colors.white, .6),
                  ),
                  BoxShadow(
                    blurRadius: widget.bevel,
                    offset: widget.blurOffset,
                    color: color.mix(Colors.black, .3),
                  )
                ],
        ),
        child: widget.child,
      ),
    );
  }
}

extension ColorUtil on Color {
  Color mix(Color another, double amount) {
    return Color.lerp(this, another, amount)!;
  }
}
