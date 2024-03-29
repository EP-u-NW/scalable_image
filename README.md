# [DISCONTINUED] - 24.05.2021
While this widget was useful in the early days of Flutter, the Flutter team introduced an own way to zoom and pan, see [`InteractiveViewer`](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html).

# scalable_image

A widget that shows an image which can be scaled and dragged using gestures.
This package was designed for quadratic images. It can happen that it don't behave as you expect for non quadratic images.
A workaround is to wrap this image in an AspectRatio with an aspect ratio of the target image.
This has the drawback that it does not fill the whole space while zooming since it will contain the aspect ratio.
Feel free to fork on github.

## Getting Started

You can also try using an other ImageProvider, like NetworkImage and FileImage.
```
new ScalableImage(
          imageProvider: new AssetImage('assets/example.png'),
          dragSpeed: 4.0,
          maxScale: 16.0
        )
```


That's all you need. See below and [`example/`](https://github.com/epnw/scalable_image/tree/master/example)
for an example.

![demo!](https://raw.githubusercontent.com/epnw/scalable_image/master/example/demo.gif)