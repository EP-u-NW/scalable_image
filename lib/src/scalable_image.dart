import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:math';

class ScalableImage extends StatefulWidget {

  const ScalableImage({Key key,@required imageProvider,double maxScale,double dragSpeed,Size size,bool wrapInAspect,bool enableScaling}):
        assert(imageProvider != null),
        this._imageProvider=imageProvider,
        assert((maxScale??16.0)>1.0),
        this._maxScale=maxScale??16.0,
        this._dragSpeed=dragSpeed??8.0,
        this._size=size??const Size.square(double.infinity),
        this._wrapInAspect=wrapInAspect??false,
        this._enableScaling=enableScaling??true,
        super(key: key);

  final ImageProvider _imageProvider;
  final bool _wrapInAspect,_enableScaling;
  final double _maxScale,_dragSpeed;
  final Size _size;

  @override
  _ScalableImageState createState() => new _ScalableImageState();
}

class _ScalableImageState extends State<ScalableImage> {

  ImageStream _imageStream;
  ImageInfo _imageInfo;
  double _scale=1.0;
  double _lastEndScale=1.0;
  Offset _offset=Offset.zero;
  Offset _lastFocalPoint;
  Size _imageSize;
  Offset _targetPointPixelSpace;
  Offset _targetPointDrawSpace;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(ScalableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._imageProvider != oldWidget._imageProvider)
      _getImage();
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    _imageStream = widget._imageProvider.resolve(createLocalImageConfiguration(context));
    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_updateImage);
      _imageStream.addListener(_updateImage);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
      _imageSize=_imageInfo==null?null:new Size(_imageInfo.image.width.toDouble(),_imageInfo.image.height.toDouble());
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(_updateImage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_imageInfo==null){
      return new Container(
          alignment: Alignment.center,
          child: new FractionallySizedBox(
              widthFactor: 0.1,
              child: new AspectRatio(
                  aspectRatio: 1.0,
                  child: new CircularProgressIndicator()
              )
          )
      );
    } else {
      Widget painter=new CustomPaint(
        size: widget._size,
        painter: new _ScalableImagePainter(_imageInfo.image,_offset,_scale),
        willChange: true,
      );
      if(widget._wrapInAspect){
        painter=new AspectRatio(
            aspectRatio: _imageSize.width/_imageSize.height,
            child:painter);
      }
      if(widget._enableScaling) {
        return new GestureDetector(
          child: painter,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          onScaleStart: _handleScaleStart,
        );
      } else {
        return painter;
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails start){
    _lastFocalPoint=start.focalPoint;
    _targetPointDrawSpace=(context.findRenderObject() as RenderBox).globalToLocal(start.focalPoint);
    _targetPointPixelSpace=drawSpaceToPixelSpace(_targetPointDrawSpace,context.size,_offset,_imageSize,_scale);
  }

  void _handleScaleEnd(ScaleEndDetails end){
    _lastEndScale=_scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails event) {

    //init old values
    double newScale=_scale;
    Offset newOffset=_offset;

    if(event.scale==1.0){ //This is a movement
      //Calculate movement since last call
      Offset delta=(_lastFocalPoint-event.focalPoint)*widget._dragSpeed/_scale;
      //Store the new information
      _lastFocalPoint=event.focalPoint;
      //And move it
      newOffset+=delta;
    } else {
      //Round the scale to three points after comma to prevent shaking
      double roundedScale=_roundAfter(event.scale, 3);
      //Calculate new scale but do not scale to far out or in
      newScale= min(widget._maxScale, max(1.0, roundedScale*_lastEndScale));
      //Move the offset so that the target point stays at the same position after scaling
      newOffset=_elementwiseDivision(_targetPointDrawSpace, -_linearTransformationFactor(context.size, _imageSize, newScale))+_targetPointPixelSpace;
    }
    //Don't move to far left
    newOffset=_elementwiseMax(newOffset,Offset.zero);
    //Nor to far right
    double borderScale=1.0-1.0/newScale;
    newOffset=_elementwiseMin(newOffset,_asOffset(_imageSize*borderScale));
    if (newScale != _scale || newOffset != _offset) {
      setState(() {
        _scale = newScale;
        _offset=newOffset;
      });
    }
  }
}

class _ScalableImagePainter extends CustomPainter{

  final Image _image;
  final Paint _paint;
  final Rect _rect;

  _ScalableImagePainter(this._image,Offset offset,double scale) :
        this._rect=new Rect.fromLTWH(
            offset.dx,
            offset.dy,
            _image.width.toDouble()/scale,
            _image.height.toDouble()/scale
        ),
        this._paint = new Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
        _image,
        _rect,
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
        _paint);
  }

  @override
  bool shouldRepaint(_ScalableImagePainter oldDelegate) {
    return  _rect != oldDelegate._rect || _image!=oldDelegate._image;
  }

}

Offset _linearTransformationFactor(Size drawSpaceSize, Size imageSize,double scale){
  return new Offset(drawSpaceSize.width/(imageSize.width/scale), drawSpaceSize.height/(imageSize.height/scale));
}


Offset pixelSpaceToDrawSpace(Offset pixelSpace,Size drawSpaceSize,Offset offset, Size imageSize,double scale){
  return _elementwiseMultiplication(pixelSpace-offset,_linearTransformationFactor(drawSpaceSize, imageSize, scale));
}

Offset drawSpaceToPixelSpace(Offset drawSpace,Size drawSpaceSize,Offset offset, Size imageSize,double scale){
  return _elementwiseDivision(drawSpace, _linearTransformationFactor(drawSpaceSize, imageSize, scale))+offset;
}

double _roundAfter(double number,int position){
  double shift=pow(10,position).toDouble();
  return (number*shift).roundToDouble()/shift;
}

Offset _elementwiseDivision(Offset dividend,Offset divisor){
  return dividend.scale(1.0/divisor.dx, 1.0/divisor.dy);
}

Offset _elementwiseMultiplication(Offset a,Offset b){
  return a.scale(b.dx, b.dy);
}

Offset _elementwiseMin(Offset a,Offset b){
  return new Offset(min(a.dx,b.dx), min(a.dy,b.dy));
}

Offset _elementwiseMax(Offset a, Offset b){
  return new Offset(max(a.dx,b.dx), max(a.dy,b.dy));
}

Offset _asOffset(Size s){
  return new Offset(s.width,s.height);
}

