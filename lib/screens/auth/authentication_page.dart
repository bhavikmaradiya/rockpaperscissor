import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/auth/bloc/auth_bloc.dart';
import 'package:rockpaperscissor/utils/app_utils.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/widgets/app_filled_button.dart';
import 'package:rockpaperscissor/widgets/app_text_field.dart';
import 'package:rockpaperscissor/widgets/button_widget.dart';
import 'package:rockpaperscissor/widgets/loading_progress.dart';
import 'package:rockpaperscissor/widgets/toast_widget.dart';

class AuthenticationPage extends StatelessWidget {
  FToast? toastBuilder;
  final _emailTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();
  final _playerTextEditingController = TextEditingController();

  AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    toastBuilder ??= FToast();
    toastBuilder?.init(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous != current && current is! AuthInitialState,
        listener: (context, state) => _authStateChangeListener(
          context,
          state,
          appLocalizations,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: _welcomeWidget(
                  context,
                  appLocalizations,
                ),
              ),
              SizedBox(
                height: Dimens.dimens_10.h,
              ),
              _loginContentWidget(
                context,
                appLocalizations,
              ),
              SizedBox(
                height: Dimens.dimens_25.h,
              ),
              SafeArea(
                top: false,
                child: _otherContent(
                  context,
                  appLocalizations,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleSignButton(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return OutlinedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Dimens.dimens_7.r,
            ),
          ),
        ),
      ),
      onPressed: () async {
        final authBlocProvider = BlocProvider.of<AuthBloc>(context);
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
        authBlocProvider.add(GoogleSignInEvent());
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimens.dimens_10.h,
          horizontal: Dimens.dimens_15.w,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              Assets.googleLogo,
              height: Dimens.dimens_27.h,
              width: Dimens.dimens_27.h,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: Dimens.dimens_10.w,
              ),
              child: Text(
                appLocalizations.googleSignIn,
                style: TextStyle(
                  fontSize: Dimens.dimens_17.sp,
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.black1AColor,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otherContent(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        Text(
          appLocalizations.or,
          style: TextStyle(
            fontSize: Dimens.dimens_16.sp,
            color: ColorUtils.getColor(
              context,
              ColorEnums.gray6CColor,
            ),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: Dimens.dimens_12.h,
        ),
        _googleSignButton(
          context,
          appLocalizations,
        ),
      ],
    );
  }

  Widget _loginContentWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final authBlocProvider = BlocProvider.of<AuthBloc>(context);
    final errorTextStyle = TextStyle(
      color: ColorUtils.getColor(
        context,
        ColorEnums.redColor,
      ),
      fontSize: Dimens.dimens_13.sp,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.dimens_20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.login,
            style: TextStyle(
              fontSize: Dimens.dimens_24.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: Dimens.dimens_60.w,
            child: Divider(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayE0Color,
              ),
              thickness: Dimens.dimens_2.h,
            ),
          ),
          SizedBox(
            height: Dimens.dimens_20.h,
          ),
          AppTextField(
            title: appLocalizations.email,
            titleTextColor: ColorEnums.whiteColor,
            textEditingController: _emailTextEditingController,
            keyboardType: TextInputType.emailAddress,
            keyboardAction: TextInputAction.next,
            hint: appLocalizations.emailFieldHint,
            hintStyle: TextStyle(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayA8Color,
              ),
            ),
            onTextChange: (email) {
              authBlocProvider.add(
                EmailFieldTextChangeEvent(
                  email,
                ),
              );
            },
          ),
          SizedBox(
            height: Dimens.dimens_5.h,
          ),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                current is AuthEmailFieldValidationState,
            builder: (context, state) {
              if (state is AuthEmailFieldValidationState && !state.isValid) {
                return Text(
                  appLocalizations.invalidEmail,
                  style: errorTextStyle,
                );
              }
              return const SizedBox();
            },
          ),
          SizedBox(
            height: Dimens.dimens_20.h,
          ),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                previous != current &&
                (current is VisiblePasswordFieldState ||
                    current is InVisiblePasswordFieldState),
            builder: (context, state) {
              final passwordVisibleState = state is VisiblePasswordFieldState;
              return AppTextField(
                title: appLocalizations.password,
                titleTextColor: ColorEnums.whiteColor,
                textEditingController: _passwordTextEditingController,
                keyboardType: TextInputType.visiblePassword,
                hint: appLocalizations.passwordFieldHint,
                hintStyle: TextStyle(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.grayA8Color,
                  ),
                ),
                isPassword: !passwordVisibleState,
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisibleState
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.gray99Color,
                  ),
                  onPressed: () {
                    authBlocProvider.add(
                      passwordVisibleState
                          ? InVisiblePasswordFieldEvent()
                          : VisiblePasswordFieldEvent(),
                    );
                  },
                ),
                onTextChange: (password) {
                  authBlocProvider.add(
                    PasswordFieldTextChangeEvent(
                      password,
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(
            height: Dimens.dimens_5.h,
          ),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                current is AuthPasswordFieldValidationState,
            builder: (context, state) {
              if (state is AuthPasswordFieldValidationState && !state.isValid) {
                return Text(
                  appLocalizations.passwordHint,
                  style: errorTextStyle,
                );
              }
              return const SizedBox();
            },
          ),
          SizedBox(
            height: Dimens.dimens_20.h,
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (_, state) {
              final email = _emailTextEditingController.text.trim();
              final password = _passwordTextEditingController.text;
              final isValid = email.isNotEmpty &&
                  password.isNotEmpty &&
                  AppUtils.isValidEmail(email.trim()) &&
                  AppUtils.isValidPasswordToRegister(password);
              return AppFilledButton(
                title: appLocalizations.loginBtn,
                enabled: isValid,
                onButtonPressed: () {
                  _onLoginButtonClicked(
                    authBlocProvider,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _welcomeWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return SizedBox(
      width: double.infinity,
      height: Dimens.dimens_342.h,
      child: Center(
        child: Hero(
          tag: Assets.loginBanner,
          child: Image.asset(
            Assets.loginBanner,
            width: double.infinity,
            height: Dimens.dimens_300.h,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _onLoginButtonClicked(
    AuthBloc authBlocProvider,
  ) {
    final email = _emailTextEditingController.text.trim();
    final password = _passwordTextEditingController.text;
    if (email.isEmpty && password.isEmpty) {
      authBlocProvider.add(
        EmailFieldTextChangeEvent(
          email,
        ),
      );
      authBlocProvider.add(
        PasswordFieldTextChangeEvent(
          password,
        ),
      );
      return;
    } else if (email.isEmpty) {
      authBlocProvider.add(
        EmailFieldTextChangeEvent(
          email,
        ),
      );
      return;
    } else if (password.isEmpty) {
      authBlocProvider.add(
        PasswordFieldTextChangeEvent(
          password,
        ),
      );
      return;
    } else {
      authBlocProvider.add(
        EmailFieldTextChangeEvent(
          email,
        ),
      );
      authBlocProvider.add(
        PasswordFieldTextChangeEvent(
          password,
        ),
      );
    }
    authBlocProvider.add(
      VerifyCredentialEvent(
        email,
        password,
      ),
    );
  }

  void _authStateChangeListener(
    BuildContext context,
    AuthState state,
    AppLocalizations appLocalizations,
  ) {
    LoadingProgress.showHideProgress(
      context,
      state is AuthLoadingState,
    );
    if (state is FirebaseLoginInvalidUserState) {
      // invalid user
      _createNewUserDialog(
        context,
        state,
        appLocalizations,
      );
    } else if (state is FirebaseLoginInvalidPasswordState) {
      // invalid password
      toastBuilder?.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.invalidFirebasePassword,
          isSuccess: false,
        ),
      );
    } else if (state is FirebaseLoginFailedState) {
      // failed with firebase message
      toastBuilder?.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: state.errorMessage ?? appLocalizations.somethingWentWrong,
          isSuccess: false,
        ),
      );
    } else if (state is FirebaseAlreadyLoggedInUserState) {
      toastBuilder?.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.alreadyLoggedInUserError,
          isSuccess: false,
        ),
      );
    } else if (state is FirebaseLoginSuccessHomeState) {
      Navigator.pushReplacementNamed(
        context,
        Routes.home,
      );
    }
  }

  Future<void> _createNewUserDialog(
    BuildContext context,
    AuthState state,
    AppLocalizations appLocalizations,
  ) async {
    final authBlocProvider = BlocProvider.of<AuthBloc>(context);
    final playerName = await showModalBottomSheet<String?>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Dimens.dimens_15.r,
        ),
      ),
      backgroundColor: ColorUtils.getColor(
        context,
        ColorEnums.darkPurpleColor,
      ),
      builder: (context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(
            milliseconds: 100,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                Dimens.dimens_20.w,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations.userNotFoundTitle,
                    style: TextStyle(
                      fontSize: Dimens.dimens_22.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dimens.dimens_10.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: Dimens.dimens_15.w,
                    ),
                    child: Text(
                      appLocalizations.userNotFoundSubtitle,
                      style: TextStyle(
                        fontSize: Dimens.dimens_19.sp,
                        color: ColorUtils.getColor(
                          context,
                          ColorEnums.grayF5Color,
                        ).withOpacity(0.9),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dimens.dimens_20.h,
                  ),
                  AppTextField(
                    textEditingController: _playerTextEditingController,
                    keyboardType: TextInputType.text,
                    autoFocus: true,
                    keyboardAction: TextInputAction.done,
                    hint: appLocalizations.defaultNewPlayerName,
                    inputFormatter: [
                      LengthLimitingTextInputFormatter(
                        AppConfig.playerNameLength,
                      ),
                    ],
                    hintStyle: TextStyle(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.grayA8Color,
                      ),
                    ),
                    onTextChange: (name) {},
                  ),
                  SizedBox(
                    height: Dimens.dimens_5.h,
                  ),
                  Text(
                    appLocalizations.playerNameNote,
                    style: TextStyle(
                      fontSize: Dimens.dimens_18.sp,
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ).withOpacity(0.9),
                    ),
                  ),
                  SizedBox(
                    height: Dimens.dimens_32.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          title: appLocalizations.cancel,
                          textSize: Dimens.dimens_24.sp,
                          onTap: () {
                            Navigator.pop(
                              context,
                              null,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: Dimens.dimens_10.w,
                      ),
                      Expanded(
                        child: ButtonWidget(
                          title: appLocalizations.createAc,
                          textSize: Dimens.dimens_24.sp,
                          onTap: () {
                            final name = _playerTextEditingController.text;
                            if (name.trim().isNotEmpty) {
                              Navigator.pop(
                                context,
                                name,
                              );
                            } else {
                              toastBuilder?.showToast(
                                gravity: ToastGravity.TOP,
                                toastDuration: const Duration(
                                  seconds: AppConfig.defaultToastDuration,
                                ),
                                child: ToastWidget(
                                  message: appLocalizations.playerNameError,
                                  isSuccess: false,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    _playerTextEditingController.clear();
    if (playerName != null && playerName.trim().isNotEmpty) {
      final email = _emailTextEditingController.text.trim();
      final password = _passwordTextEditingController.text;
      authBlocProvider.add(
        CreateFirebaseUserEvent(
          name: playerName,
          email: email,
          password: password,
        ),
      );
    }
  }
}
