import 'package:tencent_extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tencent_im_base/base_widgets/tim_stateless_widget.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitTextField/special_text/DefaultSpecialTextSpanBuilder.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/link_preview/common/utils.dart';

class LinkTextMarkdown extends TIMStatelessWidget {
  /// Callback for when link is tapped
  final void Function(String)? onLinkTap;

  /// message text
  final String messageText;

  /// text style for default words
  final TextStyle? style;

  const LinkTextMarkdown(
      {Key? key, required this.messageText, this.onLinkTap, this.style})
      : super(key: key);

  @override
  Widget timBuild(BuildContext context) {
    return MarkdownBody(
      data: messageText,
      styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
              textTheme: TextTheme(
                  bodyText2: style ?? const TextStyle(fontSize: 16.0))))
          .copyWith(
        a: TextStyle(color: LinkUtils.hexToColor("015fff")),
      ),
      onTapLink: (
        String link,
        String? href,
        String title,
      ) {
        if (onLinkTap != null) {
          onLinkTap!(link);
        } else {
          LinkUtils.launchURL(context, link);
        }
      },
    );
  }
}

class LinkText extends TIMStatelessWidget {
  /// Callback for when link is tapped
  final void Function(String)? onLinkTap;

  /// message text
  final String messageText;

  /// text style for default words
  final TextStyle? style;

  final bool isUseDefaultEmoji;

  final List customEmojiStickerList;

  const LinkText(
      {Key? key,
      required this.messageText,
      this.onLinkTap,
      this.style,
      this.isUseDefaultEmoji = false,
      this.customEmojiStickerList = const []})
      : super(key: key);

  String _getContentSpan(String text, BuildContext context) {
    List<InlineSpan> _contentList = [];
    String contentData = '';

    Iterable<RegExpMatch> matches = LinkUtils.urlReg.allMatches(text);

    int index = 0;
    for (RegExpMatch match in matches) {
      String c = text.substring(match.start, match.end);
      if (match.start == index) {
        index = match.end;
      }
      if (index < match.start) {
        String a = text.substring(index, match.start);
        index = match.end;
        contentData += a;
        _contentList.add(
          TextSpan(text: a),
        );
      }

      if (LinkUtils.urlReg.hasMatch(c)) {
        contentData += '\$' + c + '\$';
        _contentList.add(TextSpan(
            text: c,
            style: TextStyle(color: LinkUtils.hexToColor("015fff")),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onLinkTap != null) {
                  onLinkTap!(text.substring(match.start, match.end));
                } else {
                  LinkUtils.launchURL(
                      context, text.substring(match.start, match.end));
                }
              }));
      } else {
        contentData += c;
        _contentList.add(
          TextSpan(text: c, style: style ?? const TextStyle(fontSize: 16.0)),
        );
      }
    }
    if (index < text.length) {
      String a = text.substring(index, text.length);
      contentData += a;
      _contentList.add(
        TextSpan(text: a, style: style ?? const TextStyle(fontSize: 16.0)),
      );
    }

    return contentData;
  }

  @override
  Widget timBuild(BuildContext context) {
    return
        // Text.rich(
        //   TextSpan(children: [..._getContentSpan(messageText, context)]),
        //   style: style ?? const TextStyle(fontSize: 16.0),
        // );
        ExtendedText(_getContentSpan(messageText, context), softWrap: true,
            onSpecialTextTap: (dynamic parameter) {
      if (parameter.toString().startsWith('\$')) {
        if (onLinkTap != null) {
          onLinkTap!((parameter.toString()).replaceAll('\$', ''));
        } else {
          LinkUtils.launchURL(
              context, (parameter.toString()).replaceAll('\$', ''));
        }
      }
    },
            style: style ?? const TextStyle(fontSize: 16.0),
            specialTextSpanBuilder: DefaultSpecialTextSpanBuilder(
              isUseDefaultEmoji: isUseDefaultEmoji,
              customEmojiStickerList: customEmojiStickerList,
              showAtBackground: true,
            ));
  }
}
