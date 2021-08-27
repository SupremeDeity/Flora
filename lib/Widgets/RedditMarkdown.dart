import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

// TODO: Add support for weird characters
class RedditMarkdown extends StatelessWidget {
  const RedditMarkdown({Key? key, required String data})
      : data = data,
        super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MarkdownBody(
        key: UniqueKey(),
        onTapLink: (text, link, title) => {launch(link!)},
        data: data,
        inlineSyntaxes: [
          InlineHTMLLineBreak(),
          InlineSmallText(),
        ],
        builders: {
          'breakLine': InlineHTMLLineBreakBuilder(),
          'smallText': InlineSmallTextBuilder()
        },
      ),
    );
  }
}

// TODO: add support for ^Text

class InlineHTMLLineBreak extends md.InlineSyntax {
  InlineHTMLLineBreak({String pattern = r"&#x200B;"}) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    print("on match: ${match.pattern}, ${match.group(0).toString()}");
    md.Element el = md.Element.text("breakLine", match.group(0).toString());
    parser.addNode(el);
    return true;
  }
}

class InlineHTMLLineBreakBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text("\n");
  }
}

class InlineSmallText extends md.InlineSyntax {
  InlineSmallText({String pattern = r"\^\((.*?)\)"}) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final textOnly = match.group(0)!.replaceAll(RegExp(r"[\^\(\)]"), "");
    md.Element el = md.Element.text("smallText", textOnly);
    parser.addNode(el);
    return true;
  }
}

class InlineSmallTextBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    print(element.textContent);
    return Text(
      element.textContent,
      style: TextStyle(fontSize: 8),
    );
  }
}
