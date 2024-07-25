import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/generated/assets.gen.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/extensions/model_extensions.dart';
import 'package:huntube_app/presentation/features/one_part_list/notifier/button_push_notifier.dart';
import 'package:huntube_app/presentation/features/one_part_list/notifier/progress_bar_notifier.dart';
import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:huntube_app/presentation/widgets/error_page.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

class ProgressBar extends ConsumerStatefulWidget {
  final FileData fileData;

  const ProgressBar({
    Key? key,
    required this.fileData,
  }) : super(key: key);

  @override
  ConsumerState<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends ConsumerState<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _player;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _controller.reset();
            ref.read(progressBarNotifierProvider.notifier).reset();
          }
        });
      }
    });

    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    ref
        .read(progressBarNotifierProvider.notifier)
        .setActiveBar(widget.fileData.id);
    String audioPath = Assets.audios.values
        .firstWhere((title) =>
            title.replaceAll('assets/audios/', '').replaceAll('.mp3', '') ==
            widget.fileData.assetName)
        .replaceAll('assets/', '');
    await _player.setSource(AssetSource(audioPath));

    Duration? audioDuration = await _player.getDuration();
    if (audioDuration != null) {
      _controller.duration = audioDuration;

      await _player.play(_player.source!);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(cachedLikesProvider).when(
          data: (likes) {
            final activeBarId = ref.watch(progressBarNotifierProvider);
            final pushedDownButtonId = ref.watch(buttonPushNotifierProvider);
            final buttonPushedDown = pushedDownButtonId != null &&
                pushedDownButtonId == widget.fileData.id;

            if (activeBarId != null && activeBarId != widget.fileData.id) {
              _controller.reset();
              _player.stop();
            }

            final liked =
                likes.map((like) => like.id).contains(widget.fileData.id);
            return Padding(
              padding: EdgeInsets.only(
                bottom: buttonPushedDown ? 5 : 8,
                top: buttonPushedDown ? 11 : 8,
                right: buttonPushedDown ? 13 : 16,
                left: buttonPushedDown ? 19 : 16,
              ),
              child: Dismissible(
                dismissThresholds: {DismissDirection.vertical: 20},
                confirmDismiss: (direction) async {
                  direction == DismissDirection.startToEnd
                      ? _like(widget.fileData)
                      : _removeLike(widget.fileData.id);
                  return false;
                },
                direction: DismissDirection.horizontal,
                background: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.appColors.teal,
                        context.appColors.blackStrong
                      ],
                    ),
                    borderRadius: UIConstants.radiusAll16,
                  ),
                  child: liked
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.favorite_border,
                              color: context.appColors.navy,
                              size: 30,
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(
                              Icons.favorite,
                              color: context.appColors.navy,
                              size: 30,
                            ),
                          ),
                        ),
                ),
                key: UniqueKey(),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    ref
                        .read(buttonPushNotifierProvider.notifier)
                        .buttonDown(widget.fileData.id);
                    Future.delayed(
                      Duration(milliseconds: 150),
                      () => ref
                          .read(buttonPushNotifierProvider.notifier)
                          .buttonUp(widget.fileData.id),
                    );
                    if (_controller.isAnimating) {
                      _controller.reset();
                      _player.stop();
                    } else {
                      await _playAudio();
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: UIConstants.radiusAll16,
                          boxShadow: [
                            if (!buttonPushedDown)
                              BoxShadow(
                                color: context.appColors.teal,
                                offset: Offset(2, 1),
                                blurRadius: 5,
                              ),
                          ],
                          gradient: _controller.isDismissed
                              ? LinearGradient(
                                  colors: [
                                    context.appColors.navy,
                                    context.appColors.navy
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    context.appColors.teal,
                                    context.appColors.indigo,
                                    context.appColors.navy
                                  ],
                                  stops: [
                                    0.0,
                                    _controller.value,
                                    _controller.value
                                  ],
                                ),
                        ),
                        child: liked
                            ? CustomPaint(
                                painter: HeartPatternPainter(),
                                child: Center(
                                  child: H3AutosizeText(
                                    text: widget.fileData.title,
                                    color: context.appColors.whiteStrong,
                                  ),
                                ),
                              )
                            : Center(
                                child: H3AutosizeText(
                                  text: widget.fileData.title,
                                  color: context.appColors.whiteStrong,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          error: (_, __) => ErrorPage(onRetry: () => ref.invalidate(cachedLikesProvider)),
          loading: () => const ActivityIndicator(),
        );
  }

  void _like(FileData fileData) {
    final isar = ref.read(isarProvider).requireValue;
    isar.writeTxn(() {
      return isar.cachedLikes.put(fileData.toLike());
    });
  }

  void _removeLike(int id) {
    final isar = ref.read(isarProvider).requireValue;
    isar.writeTxn(() {
      return isar.cachedLikes.delete(id);
    });
  }
}

class HeartPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.teal.withOpacity(0.2);
    final heartSize = 10.0;

    // Define heart positions in a more irregular, but fixed pattern
    final hearts = [
      Offset(25 - 10, 20),
      Offset(50 - 10, 40),
      Offset(75 - 10, 15),
      Offset(100 - 10, 35),
      Offset(125 - 10, 25),
      Offset(150 - 10, 45),
      Offset(175 - 10, 20),
      Offset(200 - 10, 45),
      Offset(225 - 10, 15),
      Offset(250 - 10, 35),
      Offset(275 - 10, 25),
      Offset(300 - 10, 40),
      Offset(325 - 10, 20),
      Offset(350 - 10, 40),
      Offset(375 - 10, 25),
    ];

    for (final offset in hearts) {
      _drawHeart(canvas, paint, offset.dx, offset.dy, heartSize);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    path.moveTo(x, y);
    path.cubicTo(x, y - size / 2, x - size, y - size / 2, x - size, y);
    path.cubicTo(x - size, y + size / 2, x, y + size * 3 / 4, x, y + size);
    path.cubicTo(x, y + size * 3 / 4, x + size, y + size / 2, x + size, y);
    path.cubicTo(x + size, y - size / 2, x, y - size / 2, x, y);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
