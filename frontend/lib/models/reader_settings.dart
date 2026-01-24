enum FontSize {
  small,
  medium,
  large;

  double toPixels() {
    switch (this) {
      case FontSize.small:
        return 14.0;
      case FontSize.medium:
        return 16.0;
      case FontSize.large:
        return 20.0;
    }
  }

  static FontSize fromString(String value) {
    return FontSize.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FontSize.medium,
    );
  }
}

enum BackgroundColor {
  cream,
  mint,
  softBlue;

  String toHex() {
    switch (this) {
      case BackgroundColor.cream:
        return '#FBF7F0';
      case BackgroundColor.mint:
        return '#F0F8F5';
      case BackgroundColor.softBlue:
        return '#F5F5FF';
    }
  }

  static BackgroundColor fromString(String value) {
    return BackgroundColor.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BackgroundColor.cream,
    );
  }
}

class ReaderSettings {
  final bool useOpenDyslexic;
  final bool useBionicReading;
  final FontSize fontSize;
  final BackgroundColor backgroundColor;

  const ReaderSettings({
    this.useOpenDyslexic = false,
    this.useBionicReading = false,
    this.fontSize = FontSize.medium,
    this.backgroundColor = BackgroundColor.cream,
  });

  ReaderSettings copyWith({
    bool? useOpenDyslexic,
    bool? useBionicReading,
    FontSize? fontSize,
    BackgroundColor? backgroundColor,
  }) {
    return ReaderSettings(
      useOpenDyslexic: useOpenDyslexic ?? this.useOpenDyslexic,
      useBionicReading: useBionicReading ?? this.useBionicReading,
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'useOpenDyslexic': useOpenDyslexic,
      'useBionicReading': useBionicReading,
      'fontSize': fontSize.name,
      'backgroundColor': backgroundColor.name,
    };
  }

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      useOpenDyslexic: json['useOpenDyslexic'] as bool? ?? false,
      useBionicReading: json['useBionicReading'] as bool? ?? false,
      fontSize: FontSize.fromString(json['fontSize'] as String? ?? 'medium'),
      backgroundColor: BackgroundColor.fromString(
        json['backgroundColor'] as String? ?? 'cream',
      ),
    );
  }
}
