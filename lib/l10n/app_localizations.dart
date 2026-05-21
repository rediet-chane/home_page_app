import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  Map<String, String> _localizedStrings = {};
  
  Future<void> load() async {
    // English strings
    if (locale.languageCode == 'en') {
      _localizedStrings = {
        'home': 'Home Page',
        'products': 'Products',
        'posts': 'Posts',
        'videos': 'Videos',
        'beauty': 'beauty',
        'fragrances': 'fragrances',
        'comments': 'Comments',
        'write_comment': 'Write a comment...',
        'reply': 'Reply',
        'playback_speed': 'Playback speed',
        'cancel': 'Cancel',
        'retry': 'Retry',
        'error_load': 'Failed to load data',
      };
    } 
    // Arabic strings
    else if (locale.languageCode == 'ar') {
      _localizedStrings = {
        'home': 'الصفحة الرئيسية',
        'products': 'المنتجات',
        'posts': 'المنشورات',
        'videos': 'الفيديوهات',
        'beauty': 'جمال',
        'fragrances': 'عطور',
        'comments': 'التعليقات',
        'write_comment': 'اكتب تعليقاً...',
        'reply': 'رد',
        'playback_speed': 'سرعة التشغيل',
        'cancel': 'إلغاء',
        'retry': 'إعادة المحاولة',
        'error_load': 'فشل تحميل البيانات',
      };
    }
    // French strings
    else if (locale.languageCode == 'fr') {
      _localizedStrings = {
        'home': 'Page d\'accueil',
        'products': 'Produits',
        'posts': 'Publications',
        'videos': 'Vidéos',
        'beauty': 'beauté',
        'fragrances': 'parfums',
        'comments': 'Commentaires',
        'write_comment': 'Écrire un commentaire...',
        'reply': 'Répondre',
        'playback_speed': 'Vitesse de lecture',
        'cancel': 'Annuler',
        'retry': 'Réessayer',
        'error_load': 'Échec du chargement',
      };
    }
  }
  
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}