import 'package:calender_demo/app/routes/app_pages.dart';
import 'package:calender_demo/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark));
  runApp(
    GetMaterialApp(
      title: LocaleKeys.app_name,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      translationsKeys: AppTranslation.translations,
      locale: const Locale('pt', ''),
      fallbackLocale: const Locale('pt', ''),
    ),
  );
}
