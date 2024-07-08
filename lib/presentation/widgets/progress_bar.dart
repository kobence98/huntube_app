import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/generated/assets.gen.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/features/one_part_list/notifier/button_push_notifier.dart';
import 'package:huntube_app/presentation/features/one_part_list/notifier/progress_bar_notifier.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';

class ProgressBar extends ConsumerStatefulWidget {
  final FileData fileData;
  final int id;

  const ProgressBar({
    Key? key,
    required this.fileData,
    required this.id,
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
    ref.read(progressBarNotifierProvider.notifier).setActiveBar(widget.id);
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
    final activeBarId = ref.watch(progressBarNotifierProvider);
    final pushedDownButtonId = ref.watch(buttonPushNotifierProvider);
    final buttonPushedDown = pushedDownButtonId != null && pushedDownButtonId == widget.id;

    if (activeBarId != null && activeBarId != widget.id) {
      _controller.reset();
      _player.stop();
    }

    //TODO csinálni egy providert arra, hogy lementjük valami local db-be a like-olt file id-ját vagy valamit
    // majd watch-al nézni itt és frissíteni az értékét az alapján, hogy a provider like-olva van-e
    //ha like-olva van, akkor üres szív, ha nincs akkor teli szív vagy valami ilyesmi

    return Padding(
      padding: EdgeInsets.only(
        bottom: buttonPushedDown ? 5 : 8,
        top: buttonPushedDown ? 11 : 8,
        right: buttonPushedDown ? 13 : 16,
        left: buttonPushedDown ? 19 : 16,
      ),
      child: Dismissible(
        direction: DismissDirection.startToEnd,
        background: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: context.appColors.teal,
            borderRadius: UIConstants.radiusAll16,
          ),
        ),
        key: UniqueKey(),
        child: GestureDetector(
          onTap: () async {
            if (_controller.isAnimating) {
              _controller.reset();
              _player.stop();
            } else {
              await _playAudio();
            }
          },
          onTapDown: (_) =>
              ref.read(buttonPushNotifierProvider.notifier).buttonDown(widget.id),
          onTapUp: (_) {
            Future.delayed(
              Duration(milliseconds: 150),
              () => ref
                  .read(buttonPushNotifierProvider.notifier)
                  .buttonUp(widget.id),
            );
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
                            Colors.indigo,
                            context.appColors.navy
                          ],
                          stops: [0.0, _controller.value, _controller.value],
                        ),
                ),
                child: Center(
                  child: Text(
                    widget.fileData.title,
                    style: TextStyle(fontSize: 22.0, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
