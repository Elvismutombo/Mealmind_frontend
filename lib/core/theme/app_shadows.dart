import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const subtle = <BoxShadow>[
    BoxShadow(color: Color(0x0F202722), blurRadius: 16, offset: Offset(0, 5)),
  ];

  static const floating = <BoxShadow>[
    BoxShadow(color: Color(0x17202722), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
