import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/game_history/bloc/game_history_bloc.dart';
import 'package:rockpaperscissor/screens/game_history/bloc/game_history_event.dart';
import 'package:rockpaperscissor/screens/game_history/bloc/game_history_state.dart';
import 'package:rockpaperscissor/screens/game_history/widget/game_history_item.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/widgets/toolbar.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  GameHistoryBloc? _gameHistoryBloc;
  late AppLocalizations _appLocalizations;
  late FToast toastBuilder;

  @override
  void initState() {
    super.initState();
    toastBuilder = FToast();
    toastBuilder.init(context);
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_gameHistoryBloc == null) {
      _gameHistoryBloc = BlocProvider.of<GameHistoryBloc>(context);
      _gameHistoryBloc?.add(
        GameHistoryInitialEvent(),
      );
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.dimens_20.w,
          ),
          child: Column(
            children: [
              ToolbarWidget(
                title: _appLocalizations.gameHistoryTitle,
                onTap: () {
                  SoundUtils.playButtonClick();
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: Dimens.dimens_10.h,
              ),
              Expanded(
                child: BlocBuilder<GameHistoryBloc, GameHistoryState>(
                  buildWhen: (_, current) =>
                      current is GameHistoryLoadingState ||
                      current is GameHistoryUpdatedState ||
                      current is GameHistoryEmptyState,
                  builder: (_, state) {
                    final list = state is GameHistoryUpdatedState
                        ? state.roomList
                        : <Room>[];
                    if (state is GameHistoryLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (list.isEmpty) {
                      return Center(
                        child: FlickerNeonText(
                          text: _appLocalizations.noGameHistory,
                          flickerTimeInMilliSeconds: 0,
                          textColor: ColorUtils.getColor(
                            context,
                            ColorEnums.whiteColor,
                          ),
                          textOverflow: TextOverflow.ellipsis,
                          spreadColor: Colors.white,
                          blurRadius: 10,
                          textSize: Dimens.dimens_21.sp,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: list.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (_, index) {
                        final currentMatch = list[index];
                        return SafeArea(
                          top: false,
                          bottom: index == list.length - 1,
                          child: GameHistoryItem(
                            currentMatch: currentMatch,
                            appLocalizations: _appLocalizations,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.scoreboard,
                                arguments: currentMatch.roomId!,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
