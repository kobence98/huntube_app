import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:huntube_app/presentation/theme/the_just_matthew_text_styles.dart';

class H1Text extends StatelessWidget {
  const H1Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.h1.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class H2Text extends StatelessWidget {
  const H2Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.h2.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class H3Text extends StatelessWidget {
  const H3Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.h3.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class H3AutosizeText extends StatelessWidget {
  const H3AutosizeText({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return AutoSizeText(
      text,
      style: styles?.h3.copyWith(color: color),
      textAlign: textAlign,
      minFontSize: 16,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class H4Text extends StatelessWidget {
  const H4Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.h4.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B1Text extends StatelessWidget {
  const B1Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b1.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B2Text extends StatelessWidget {
  const B2Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b2.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B3Text extends StatelessWidget {
  const B3Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b3.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B3BoldText extends StatelessWidget {
  const B3BoldText({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b3.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B4Text extends StatelessWidget {
  const B4Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b4.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B5Text extends StatelessWidget {
  const B5Text({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b5.copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class B5BoldText extends StatelessWidget {
  const B5BoldText({
    required this.text,
    this.color,
    this.textAlign,
    super.key,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TheJustMatthewTextStyles>();
    return Text(
      text,
      style: styles?.b5.copyWith(color: color, fontWeight: FontWeight.w700),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
