import 'package:flutter/material.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key});

  static const supportEmail = 'kobence98@gmail.com';
  static const supportUrl =
      'https://siman-herri-support.kobence98.chatgpt.site';
  static const privacyUrl = '$supportUrl/privacy.html';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Segítség és adatvédelem'),
      scrollable: true,
      content: const SizedBox(
        width: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simán Herri', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SelectableText(
              'Fejlesztő és kapcsolattartó: Ubul Studio / Bence Kovács',
            ),
            SizedBox(height: 16),
            Text('Adatkezelés', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SelectableText(
              'Az alkalmazás használatához nem kell fiók. Nincs hirdetés, '
              'analitika vagy követés. A fejlesztő az alkalmazáson keresztül '
              'nem gyűjt és nem oszt meg felhasználói adatot; az alkalmazás '
              'nem továbbít használati vagy személyes adatokat a fejlesztőnek '
              'vagy más szolgáltatónak analitikai célból.',
            ),
            SizedBox(height: 16),
            Text(
              'Tartalomfrissítés',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SelectableText(
              'Az app induláskor a Google Drive-ról keresi és letölti az új '
              'hangokat. A Google a hálózati kérés kiszolgálásakor megkapja '
              'az IP-címet és a szokásos technikai kapcsolati adatokat. '
              'Google-fiókba bejelentkezés nem szükséges. A letöltött hangok '
              'a készüléken maradnak, és offline is használhatók.',
            ),
            SizedBox(height: 16),
            Text(
              'Kedvencek és törlés',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SelectableText(
              'A kedvencnek jelölt hangok azonosítóit az alkalmazás kizárólag '
              'a készüléken, a saját elkülönített tárhelyén őrzi. Ezek a '
              'kedvencek megjelenítését szolgálják, nem kerülnek fejlesztői '
              'szerverre. A kedvencek jelölését a hangoknál eltávolíthatod. '
              'Az összes helyi adatot az operációs rendszer alkalmazásadat-'
              'törlésével, ahol ez elérhető, vagy az alkalmazás törlésével '
              'távolíthatod el. Az operációs rendszer által készített '
              'biztonsági mentéseket külön, a rendszer beállításaiban '
              'kezelheted; egy visszaállítás visszahozhatja a mentett adatokat.',
            ),
            SizedBox(height: 16),
            Text(
              'Segítség és kapcsolat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SelectableText(
              'Ha e-mailben keresel meg, önként megadod az e-mail-címedet és '
              'az üzeneted tartalmát. Ezeket a megkeresés megválaszolására '
              'használjuk. Az e-mailes megkeresés adatainak törlését ugyanezen '
              'a címen kérheted.',
            ),
            SizedBox(height: 8),
            SelectableText(supportEmail),
            SizedBox(height: 16),
            Text(
              'Támogatási oldal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SelectableText(supportUrl),
            SizedBox(height: 16),
            Text(
              'Adatvédelmi tájékoztató online',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SelectableText(privacyUrl),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bezárás'),
        ),
      ],
    );
  }
}
