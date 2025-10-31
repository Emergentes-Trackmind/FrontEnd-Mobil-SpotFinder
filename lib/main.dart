import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:smartparking_mobile_application/parking-management/components/parking-map.component.dart';
import 'package:smartparking_mobile_application/shared/app_state.dart';
import 'package:smartparking_mobile_application/profile-management/pages/driver_details_page.dart';
import 'package:smartparking_mobile_application/profile-management/pages/edit_profile_page.dart';
import 'package:smartparking_mobile_application/profile-management/pages/payment_methods_page.dart';
import 'package:smartparking_mobile_application/profile-management/pages/payment_method_add_page.dart';
import 'package:smartparking_mobile_application/profile-management/pages/notifications_page.dart';
import 'package:smartparking_mobile_application/profile-management/pages/settings_page.dart';
import 'package:smartparking_mobile_application/rating-and-review/views/reviews_view.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-payment.dart';
import 'package:smartparking_mobile_application/reservations/views/reservations-screen.dart';
import 'iam/views/log-in.view.dart';
import 'iam/views/sign-up-driver.view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Load persisted app state (theme / language)
  await AppState.loadFromPrefs();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: AppState.locale,
          builder: (context, locale, __) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              initialRoute: '/login',
              routes: {
                '/login': (context) => LogInView(),
                '/signup-driver': (context) => SignUpDriverView(),
                '/home': (context) => ParkingMap(),
                '/reservation-payment': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>;
                  return ReservationPayment(
                    userId: args['userId'],
                    reservationId: args['reservationId'],
                    amount: args['amount'],
                  );
                },
                '/reservations': (context) => ReservationsScreen(),
                '/reviews': (context) => ReviewsView(title: 'Reseñas'),
                '/profile': (context) => DriverDetailsPage(),
                '/profile/edit': (context) => const EditProfilePage(),
                '/profile/payments': (context) => const PaymentMethodsPage(),
                '/profile/payments/add':
                    (context) => const PaymentMethodAddPage(),
                '/profile/notifications':
                    (context) => const NotificationsPage(),
                '/profile/settings': (context) => const SettingsPage(),
              },
              title: 'SmartParking App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                brightness: Brightness.dark,
              ),
              themeMode: themeMode,
              locale: locale,
              home: LogInView(),
            );
          },
        );
      },
    );
  }
}
