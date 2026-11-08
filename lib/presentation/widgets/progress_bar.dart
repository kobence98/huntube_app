import 'dart:async';

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
  const ProgressBar({
    super.key,
    required this.fileData,
    required this.easterEggActivated,
  });

  final FileData fileData;
  final bool easterEggActivated;

  @override
  ConsumerState<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends ConsumerState<ProgressBar>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _likeController;
  late final Animation<double> _heartScale;
  late final Animation<double> _heartRise;
  late final Animation<double> _heartOpacity;
  late final AudioPlayer _player;
  late final StreamSubscription<void> _completionSubscription;
  var _playbackRequest = 0;
  var _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.2), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1), weight: 65),
    ]).animate(_likeController);
    _heartRise = Tween(
      begin: 4.0,
      end: -18.0,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_likeController);
    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 85),
    ]).animate(_likeController);
    _player = AudioPlayer();
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      _controller.reset();
      setState(() => _isPlaying = false);
      if (ref.read(progressBarNotifierProvider) == widget.fileData.id) {
        ref.read(progressBarNotifierProvider.notifier).reset();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.reset();
      _likeController.reset();
    }
  }

  @override
  void dispose() {
    _playbackRequest++;
    unawaited(_completionSubscription.cancel());
    _controller.dispose();
    _likeController.dispose();
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _playAudio() async {
    final request = ++_playbackRequest;
    ref
        .read(progressBarNotifierProvider.notifier)
        .setActiveBar(widget.fileData.id);
    final localPath = widget.fileData.localPath;
    if (localPath != null) {
      await _player.setSource(DeviceFileSource(localPath));
    } else {
      final audioPath = Assets.audios.values
          .firstWhere(
            (path) => path == 'assets/audios/${widget.fileData.assetName}.mp3',
          )
          .replaceFirst('assets/', '');
      await _player.setSource(AssetSource(audioPath));
    }
    if (!mounted || request != _playbackRequest) return;
    final duration = await _player.getDuration();
    if (!mounted || request != _playbackRequest) return;
    if (!widget.easterEggActivated &&
        ref.read(progressBarNotifierProvider) != widget.fileData.id) {
      return;
    }
    await _player.play(_player.source!);
    if (!mounted || request != _playbackRequest) return;
    setState(() => _isPlaying = true);
    if (duration != null &&
        duration > Duration.zero &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = duration;
      _controller.forward(from: 0);
    }
  }

  Future<void> _stopAudio({bool clearActive = true}) async {
    _playbackRequest++;
    _controller.reset();
    if (mounted) {
      setState(() => _isPlaying = false);
      if (clearActive &&
          ref.read(progressBarNotifierProvider) == widget.fileData.id) {
        ref.read(progressBarNotifierProvider.notifier).reset();
      }
    }
    try {
      await _player.stop();
    } catch (_) {
      if (mounted) {
        context.showSnackBar(text: 'Nem sikerült leállítani a hangot.');
      }
    }
  }

  Future<void> _onTap() async {
    ref
        .read(buttonPushNotifierProvider.notifier)
        .buttonDown(widget.fileData.id);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          ref
              .read(buttonPushNotifierProvider.notifier)
              .buttonUp(widget.fileData.id);
        }
      }),
    );
    try {
      if (_isPlaying && !widget.easterEggActivated) {
        await _stopAudio();
      } else {
        await _playAudio();
      }
    } catch (_) {
      if (!mounted) return;
      _controller.reset();
      setState(() => _isPlaying = false);
      if (ref.read(progressBarNotifierProvider) == widget.fileData.id) {
        ref.read(progressBarNotifierProvider.notifier).reset();
      }
      context.showSnackBar(text: 'Nem sikerült lejátszani a hangot.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(progressBarNotifierProvider, (_, activeId) {
      if (activeId != null &&
          activeId != widget.fileData.id &&
          !widget.easterEggActivated) {
        unawaited(_stopAudio(clearActive: false));
      }
    });
    ref.listen(cachedLikesProvider, (previous, next) {
      final wasLiked = previous?.valueOrNull?.any(
        (like) => like.id == widget.fileData.id,
      );
      final isLiked = next.valueOrNull?.any(
        (like) => like.id == widget.fileData.id,
      );
      if (wasLiked == false && isLiked == true) {
        if (!MediaQuery.disableAnimationsOf(context)) {
          _likeController.forward(from: 0);
        }
      } else if (isLiked == false) {
        _likeController.reset();
      }
    });
    return ref
        .watch(cachedLikesProvider)
        .when(
          data: (likes) {
            final liked = likes.any((like) => like.id == widget.fileData.id);
            final pushedDown =
                ref.watch(buttonPushNotifierProvider) == widget.fileData.id;
            final reduceMotion = MediaQuery.disableAnimationsOf(context);
            return Padding(
              padding: EdgeInsets.only(
                bottom: pushedDown ? 5 : 8,
                top: pushedDown ? 11 : 8,
                right: pushedDown ? 13 : 16,
                left: pushedDown ? 19 : 16,
              ),
              child: Dismissible(
                key: ValueKey('sound-swipe-${widget.fileData.id}'),
                direction: DismissDirection.horizontal,
                dismissThresholds: const {
                  DismissDirection.startToEnd: 0.3,
                  DismissDirection.endToStart: 0.3,
                },
                confirmDismiss: (direction) async {
                  try {
                    if (direction == DismissDirection.startToEnd && !liked) {
                      await _like(widget.fileData);
                    } else if (direction == DismissDirection.endToStart &&
                        liked) {
                      await _removeLike(widget.fileData.id);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      context.showSnackBar(
                        text: 'Nem sikerült menteni a kedvencet.',
                      );
                    }
                  }
                  return false;
                },
                background: const _FavouriteSwipeBackground(adding: true),
                secondaryBackground: const _FavouriteSwipeBackground(
                  adding: false,
                ),
                child: Semantics(
                  button: true,
                  selected: liked,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onTap,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _controller,
                        _likeController,
                      ]),
                      builder: (context, _) {
                        return AnimatedContainer(
                          key: ValueKey('sound-surface-${widget.fileData.id}'),
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: UIConstants.radiusAll16,
                            border: Border.all(
                              color: liked
                                  ? context.appColors.teal.withValues(
                                      alpha: 0.8,
                                    )
                                  : context.appColors.teal.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                            boxShadow: [
                              if (!pushedDown)
                                BoxShadow(
                                  color: context.appColors.teal.withValues(
                                    alpha: liked ? 0.45 : 0.3,
                                  ),
                                  offset: const Offset(2, 1),
                                  blurRadius: liked ? 9 : 5,
                                ),
                            ],
                            gradient: _controller.isDismissed
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: liked
                                        ? [
                                            context.appColors.navy,
                                            const Color(0xFF114B66),
                                          ]
                                        : [
                                            context.appColors.navy,
                                            context.appColors.navy,
                                          ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      context.appColors.teal,
                                      context.appColors.indigo,
                                      context.appColors.navy,
                                    ],
                                    stops: [
                                      0,
                                      _controller.value,
                                      _controller.value,
                                    ],
                                  ),
                          ),
                          child: ClipRRect(
                            borderRadius: UIConstants.radiusAll16,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (liked)
                                  const Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: HeartPatternPainter(),
                                      ),
                                    ),
                                  ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 64,
                                  ),
                                  child: Padding(
                                    key: ValueKey(
                                      'sound-label-padding-${widget.fileData.id}',
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 8,
                                    ),
                                    child: Center(
                                      child: H3Text(
                                        text: widget.fileData.title,
                                        textAlign: TextAlign.center,
                                        color: context.appColors.whiteStrong,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isPlaying)
                                  Positioned(
                                    left: 13,
                                    child: Icon(
                                      Icons.graphic_eq,
                                      color: context.appColors.whiteStrong,
                                      size: 19,
                                      semanticLabel: 'Lejátszás',
                                    ),
                                  ),
                                Positioned(
                                  right: 11,
                                  child: AnimatedSwitcher(
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : const Duration(milliseconds: 180),
                                    child: liked
                                        ? Container(
                                            key: ValueKey(
                                              'liked-badge-${widget.fileData.id}',
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: context.appColors.teal
                                                  .withValues(alpha: 0.2),
                                            ),
                                            child: Icon(
                                              Icons.favorite,
                                              size: 16,
                                              color:
                                                  context.appColors.whiteStrong,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                if (_likeController.isAnimating &&
                                    !reduceMotion)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Center(
                                        child: Transform.translate(
                                          offset: Offset(0, _heartRise.value),
                                          child: Transform.scale(
                                            scale: _heartScale.value,
                                            child: Opacity(
                                              opacity: _heartOpacity.value,
                                              child: Icon(
                                                Icons.favorite,
                                                key: ValueKey(
                                                  'like-burst-${widget.fileData.id}',
                                                ),
                                                color: context
                                                    .appColors
                                                    .whiteStrong,
                                                size: 36,
                                                shadows: [
                                                  Shadow(
                                                    color:
                                                        context.appColors.teal,
                                                    blurRadius: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          error: (_, __) =>
              ErrorPage(onRetry: () => ref.invalidate(cachedLikesProvider)),
          loading: () => const ActivityIndicator(),
        );
  }

  Future<void> _like(FileData fileData) async {
    final isar = ref.read(isarProvider).requireValue;
    await isar.writeTxn(() => isar.cachedLikes.put(fileData.toLike()));
  }

  Future<void> _removeLike(int id) async {
    final isar = ref.read(isarProvider).requireValue;
    await isar.writeTxn(() => isar.cachedLikes.delete(id));
  }
}

class _FavouriteSwipeBackground extends StatelessWidget {
  const _FavouriteSwipeBackground({required this.adding});

  final bool adding;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: adding ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: UIConstants.radiusAll16,
        gradient: LinearGradient(
          colors: [
            context.appColors.teal.withValues(alpha: 0.35),
            context.appColors.blackStrong,
          ],
          begin: adding ? Alignment.centerLeft : Alignment.centerRight,
          end: adding ? Alignment.centerRight : Alignment.centerLeft,
        ),
      ),
      child: Icon(
        adding ? Icons.favorite : Icons.heart_broken_outlined,
        color: context.appColors.whiteStrong,
        size: 26,
        semanticLabel: adding ? 'Kedvencekhez adás' : 'Kedvenc eltávolítása',
      ),
    );
  }
}

class HeartPatternPainter extends CustomPainter {
  const HeartPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final outline = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    _drawHeart(
      canvas,
      outline,
      Offset(size.width * 0.82, size.height * 0.25),
      26,
    );
    _drawHeart(
      canvas,
      outline,
      Offset(size.width * 0.12, size.height * 0.8),
      19,
    );
    for (var row = 0; row < (size.height / 32).ceil(); row++) {
      for (var column = 0; column < (size.width / 44).ceil(); column++) {
        final x = 12.0 + column * 44 + (row.isOdd ? 20 : 0);
        final y = 8.0 + row * 32;
        final atEdge = x < size.width * 0.2 || x > size.width * 0.8;
        final fill = Paint()
          ..color = AppColors.teal.withValues(alpha: atEdge ? 0.16 : 0.06);
        _drawHeart(canvas, fill, Offset(x, y), row.isOdd ? 4 : 5);
      }
    }
    canvas.restore();
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset origin, double radius) {
    final path = Path()
      ..moveTo(0, radius * 0.3)
      ..cubicTo(
        -radius,
        -radius * 0.45,
        -radius,
        radius * 0.65,
        0,
        radius * 1.25,
      )
      ..cubicTo(radius, radius * 0.65, radius, -radius * 0.45, 0, radius * 0.3)
      ..close();
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HeartPatternPainter oldDelegate) => false;
}
