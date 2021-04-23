import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String butonText;
  final Color butonColor;
  final Color textColor;
  final double radius;
  final double yukseklik;
  final Widget butonIcon;
  final VoidCallback onPressed;

  const SocialLoginButton(

      /// note : assert Kullanımı
      /// assert ile null olamayacakları belirtiyoruz.
      {Key key,
      @required this.butonText,
      this.butonColor: Colors.amber,
      this.textColor: Colors.white,
      this.radius: 16,
      this.yukseklik: 40,
      this.butonIcon,
      @required this.onPressed})
      : assert(butonText != null, onPressed != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: yukseklik,
        child: RaisedButton(
          onPressed: onPressed,

          /// note : Köşelere border vermek için kullan.
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (butonIcon != null) ...[
                butonIcon,
                Text(
                  butonText,
                  style: TextStyle(color: textColor),
                ),
                Opacity(opacity: 0, child: butonIcon),
              ],
              if (butonIcon == null) ...[
                Container(),
                Text(
                  butonText,
                  style: TextStyle(color: textColor),
                ),
                Opacity(opacity: 0, child: Container()),
              ],
            ],
          ),
          color: butonColor,
        ),
      ),
    );
  }
}

/// eski yöntem
/*
butonIcon != null ? butonIcon : Container(),
Text(
butonText,
style: TextStyle(color: textColor),
),
Opacity(
opacity: 0,
child: butonIcon != null ? butonIcon : Container(),
)*/
