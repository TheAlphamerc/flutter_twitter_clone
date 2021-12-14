part of 'theme.dart';

class TextStyles {
  TextStyles._();

  static TextStyle get onPrimaryTitleText {
    return const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
  }

  static TextStyle get onPrimarySubTitleText {
    return const TextStyle(
      color: Colors.white,
    );
  }

  static TextStyle get titleStyle {
    return const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle get subtitleStyle {
    return const TextStyle(
        color: AppColor.darkGrey, fontSize: 14, fontWeight: FontWeight.bold);
  }

  static TextStyle get userNameStyle {
    return const TextStyle(
        color: AppColor.darkGrey, fontSize: 14, fontWeight: FontWeight.bold);
  }

  static TextStyle get textStyle14 {
    return const TextStyle(
        color: AppColor.darkGrey, fontSize: 14, fontWeight: FontWeight.bold);
  }
}
