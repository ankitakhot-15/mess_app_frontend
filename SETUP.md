# Mayechi Chav – Flutter (GetX + http) – role based app

Roles: **CUSTOMER**, **MAVSHI** (mess owner), **DELIVERY** (boy).  
ADMIN uses the web panel – an admin login in this app is politely refused.

## 1. Run
    flutter pub get
    flutter run

## 2. Backend URL – `lib/core/constants/api_constants.dart`
    Android emulator  http://10.0.2.2:5000/api/v1
    Real phone        http://<PC-IP>:5000/api/v1   (same Wi-Fi)

## 3. Android – `android/app/src/main/AndroidManifest.xml`
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <application android:usesCleartextTraffic="true" ...>     <!-- http:// dev only -->
  `android/app/build.gradle` -> `minSdkVersion 21` (Razorpay) and `compileSdk 34` or higher.

## 4. iOS – `ios/Runner/Info.plist`
    <key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Delivery location is shown to the customer</string>

## 5. Role based flow
    Splash -> logged in?  no  -> Login
                          yes -> AuthService.startRoute()  (by user.role)
    Login / Register -> POST /auth/login | /auth/register/{customer|delivery|mavshi}
                     -> save token + user -> AuthService.goHome()

    CUSTOMER -> /customer   (messes | my orders | profile) -> mess detail -> checkout -> order detail
    MAVSHI   -> /mavshi     (PENDING/REJECTED = status screen, ACTIVE = orders + menu)
    DELIVERY -> /delivery   (duty switch, active / history orders, pickup, traffic, deliver, live GPS)

Route guard: `lib/app/role_middleware.dart` – a user can only open the screens of
his own role; anything else is redirected to his own home (or login).

## 6. Structure
    lib/app/                 routes, pages (with role middleware), bindings
    lib/core/constants/      api_constants (endpoints), app_enums (roles, plans, order status)
    lib/core/network/        api_service (network check + http), api_response, api_exception, network_info
    lib/core/services/       auth_service (role -> home route, logout), payment_service (Razorpay), location_service (GPS)
    lib/repository/         auth / common / customer / mavshi / delivery  (one method per API)
    lib/model/               user, auth_data, mess, menu_item, order, tracking, misc
    lib/controllers/         login, register, notification, customer/*, mavshi/*, delivery/*   (business logic)
    lib/screens/             splash, login, register, notifications, customer/*, mavshi/*, delivery/*
    lib/widgets/             loader, button, text field, dropdown, panel, order_card, status_chip, menu_card ...

Call chain:  Screen -> Controller -> Repository -> ApiService (network check) -> backend
