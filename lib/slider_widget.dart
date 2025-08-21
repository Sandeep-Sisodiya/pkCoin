import 'package:flutter/material.dart';
import 'package:pkcoin/slider_thumb_circle.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final int min;
  final int max;
  final bool fullWidth;
  final Function(double value) finalValue;

  const SliderWidget({
    Key? key,
    this.sliderHeight = 48,
    this.max = 10,
    this.min = 0,
    this.fullWidth = false,
    required this.finalValue,
  }) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    double paddingFactor = widget.fullWidth ? .3 : .2;

    return Container(
      width: widget.fullWidth ? double.infinity : (widget.sliderHeight) * 5.5,
      height: widget.sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(widget.sliderHeight * .3)),
        gradient: const LinearGradient(
          colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 1.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.sliderHeight * paddingFactor),
        child: Row(
          children: [
            Text(
              '${widget.min}',
              style: TextStyle(
                fontSize: widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: widget.sliderHeight * .1),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(.5),
                  trackHeight: 4.0,
                  thumbShape: CustomSliderThumbCircle(
                    thumbRadius: widget.sliderHeight * .4,
                    min: widget.min,
                    max: widget.max,
                  ),
                  overlayColor: Colors.white.withOpacity(.4),
                ),
                child: Slider(
                  value: _value,
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                    });
                    widget.finalValue(value);
                  },
                ),
              ),
            ),
            SizedBox(width: widget.sliderHeight * .1),
            Text(
              '${widget.max}',
              style: TextStyle(
                fontSize: widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


}