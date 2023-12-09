import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CommonSkeleton extends ConsumerStatefulWidget {
  const CommonSkeleton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommonSkeletonState();
}

class _CommonSkeletonState extends ConsumerState<CommonSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: ref.read(themeProvider) ? kBlackColor() : null,
      enabled: true,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return kDocumentCard(context);
        },
      ),
    );
  }

  Stack kDocumentCard(BuildContext context) {
    return Stack(
      children: [
        Card(
          surfaceTintColor: kWhiteColor(),
          color: kWhiteColor(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Row(
                children: [
                  Container(
                      width: 220,
                      child: Text(
                        "Untitled Doc",
                        overflow: TextOverflow.ellipsis,
                      )),
                  Spacer(),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Members:"),
                      Row(
                          children: List.generate(4, (membersIndex) {
                        return Text(
                          " O ",
                        );
                      }))
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Text("last edited: "),
                          Text(" acca casjlc ajkc ajc"),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                  Row(
                    children: [Text("Owner: "), Text(" skasdjaslal lsakk")],
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
            top: 15,
            right: 30,
            child: StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Image.asset("assets/images/notbookmarked.png");
              },
            )),
      ],
    );
  }
}
