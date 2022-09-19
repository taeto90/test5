library universal_ui;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:universal_html/html.dart' as html;
import '../resizewidget/resizeble.dart';
import 'fake_ui.dart' if (dart.library.html) 'real_ui.dart' as ui_instance;

List<EmbedBuilder> get defaultEmbedBuildersWeb => [
  ImageEmbedBuilderWeb(),
  //VideoEmbedBuilderWeb(),
];

class ImageEmbedBuilderWeb implements EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
      BuildContext context,
      QuillController controller,
      Embed node,
      bool readOnly,
      ) {
    final imageUrl = node.value.data;
    print('-------In ImageEmbedBuilderWeb--------------${imageUrl}');

    if (isImageBase64(imageUrl)) {
      // TODO: handle imageUrl of base64
      return const SizedBox();
    }
    final size = MediaQuery.of(context).size;
    UniversalUI().platformViewRegistry.registerViewFactory(
        imageUrl, (viewId) => html.ImageElement()..src = imageUrl);
    return Container(
      // padding: EdgeInsets.only(
      //   right: ResponsiveWidget.isMediumScreen(context)
      //       ? size.width * 0.5
      //       : (ResponsiveWidget.isLargeScreen(context))
      //       ? size.width * 0.75
      //       : size.width * 0.2,),
      child: ResizebleWidget(
        height: MediaQuery.of(context).size.height * 0.45,    //이미지 크기조절
        width: MediaQuery.of(context).size.height * 0.45,     //이미지 크기조절
        child: HtmlElementView(
          viewType: imageUrl,
        ),
      ),
    );
  }
}


class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    required this.largeScreen,
    this.mediumScreen,
    this.smallScreen,
    Key? key,
  }) : super(key: key);

  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width <= 1200;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return largeScreen;
        } else if (constraints.maxWidth <= 1200 &&
            constraints.maxWidth >= 800) {
          return mediumScreen ?? largeScreen;
        } else {
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}
class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

class PlatformViewRegistryFix {
  void registerViewFactory(dynamic x, dynamic y) {
      ui_instance.PlatformViewRegistry.registerViewFactory(
        x,
        y,
      );
  }
}

