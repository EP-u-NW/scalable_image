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


That's all you need. See below and [`scalable_image_example/`](https://github.com/epnw/scalable_image/tree/master/scalable_image_example)
for an example.

![demo!](https://raw.githubusercontent.com/epnw/scalable_image/master/scalable_image_example/demo.gif)