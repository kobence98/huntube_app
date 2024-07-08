import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/progress_bar.dart';

@RoutePage()
class OnePartListScreen extends StatefulWidget {
  const OnePartListScreen({super.key, required this.partFiles});

  final PartFiles partFiles;

  @override
  State<OnePartListScreen> createState() => _OnePartListScreenState();
}

class _OnePartListScreenState extends State<OnePartListScreen> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: context.appColors.teal,
            elevation: 10,
            backgroundColor: context.appColors.blackStrong,
            title: new Center(
              child: Text(
                widget.partFiles.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.whiteStrong,
                ),
              ),
            ),
            leading: TheJustMatthewElevatedButton(
              onTap: () => Future.delayed(
                Duration(milliseconds: 300),
                context.router.maybePop,
              ),
              width: 30,
              height: 30,
              margin: UIConstants.paddingAll8,
              borderRadius: UIConstants.radiusAll3,
              shadowOffset: Offset(2, 1),
              foregroundColor: context.appColors.navy,
              shadowColor: context.appColors.teal,
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  color: context.appColors.whiteStrong,
                  weight: 30,
                ),
              ),
            ),
          ),
          body: Container(
            color: Colors.black,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: widget.partFiles.files.length,
              itemBuilder: (context, position) {
                return ProgressBar(
                  id: widget.partFiles.files.elementAt(position).id,
                  fileData: widget.partFiles.files.elementAt(position),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
