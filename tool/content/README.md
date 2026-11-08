# Új tartalmak appfrissítés nélkül

A meglévő 251 MP3 beépítve marad. Az új főmappákat, almappákat és hangokat
az alkalmazás ebből a szerkeszthető Google-dokumentumból olvassa:

https://docs.google.com/document/d/1Z7ueja_ALWhbyCWf1mn-OMV8OURkKJGzkWXpVak01xg/edit

A tartalomhoz fenntartott Drive-mappa:
https://drive.google.com/drive/folders/1PIjzRR0bVgtv2vwOP_A3arnWV4vwv_rU

Ez a mappa **a link birtokában bárki számára olvasható**. Csak az appban
nyilvánosan elérhető tartalmat tölts ide; fiókadatot, kulcsot ne.
A dokumentum teljes szövege JSON: ne legyen benne cím, magyarázat vagy kódkerítés.
Az alkalmazás mindig a dokumentum ugyanazon azonosítóját használja; ne készíts
helyette új dokumentumot. Az eredeti, üres catalog.json fájl csak kezdeti sablon,
nem az élő forrás.

## Új főmappa és almappa

A `collections` listában egy új főmappa, a `parts` listában az almappái szerepelnek.
A beépített főmappák azonosítói: `herri`, `gyuru`, `srekk`, `karib`, `pom`.
Ezekhez is hozzáadhatsz új almappákat. Üres főmappa és üres almappa is megjelenik.

```json
{
  "schemaVersion": 1,
  "collections": [
    {"id": "uj_parodia", "title": "Új paródia"}
  ],
  "parts": [
    {
      "id": 1000000,
      "title": "Első rész",
      "collection": "uj_parodia",
      "sounds": []
    }
  ]
}
```

A főmappa `id` mezője kisbetűvel kezdődik, kisbetűt, számot és aláhúzást
tartalmazhat, legfeljebb 64 karakter. A címek legfeljebb 500 karakteresek.
A főmappát az `id`, az almappát és hangot a számozott `id` azonosítja.
A hangok és almappák számai 1000000-tól indulnak; a hangazonosítók az egész
jegyzékben egyediek legyenek, és soha ne használd újra őket más hanghoz.
Átnevezéskor, átrendezéskor és hangcserekor tartsd meg az azonosítót,
így a kedvencek megmaradnak.

## Új hang

1. Töltsd az MP3-at a fenti Drive-mappába (örökli a nyilvános olvasási jogot).
2. Másold ki a fájl megosztási linkjét.
3. Generáld a hang adatait az eredeti fájlból:

```sh
python3 tool/content/audio_entry.py /absolute/path/hang.mp3 \
  --drive-id 'https://drive.google.com/file/d/FILE_ID/view' \
  --id 1000000 --title 'Új hang'
```

4. A kapott JSON-objektumot másold a megfelelő almappa `sounds` listájába.
5. Ellenőrizd a dokumentum JSON-szintaxisát, majd indítsd újra az appot,
   vagy használd a felhőikon mögötti Frissítés gombot.

Egy hang: `id`, `title`, `driveFileId`, `sha256`, `bytes`. A `sha256` és `bytes`
mező az MP3 pontos tartalmából származik; cserekor mindkettőt frissíteni kell.
A Drive-mappában önmagában létrehozott fájl/mappa még nem jelenik meg:
a Google-dokumentumban kell felvenni a jegyzékbe.

## Működés és korlátok

Induláskor a helyi tartalmak azonnal használhatók, a frissítés háttérben fut,
mobiladaton is. A letöltött hangok az alkalmazás tartós saját tárhelyén maradnak.
Csak a hiányzó, sérült vagy megváltozott fájl töltődik le. Megszakítás után az
elkészült fájlokat újra használjuk; a félbehagyott fájlt újrakezdjük.

Az új jegyzék csak az összes fájl sikeres ellenőrzése után lép életbe.
Hibás dokumentum, hálózati hiba vagy tárhelyhiány esetén a korábbi tartalom
marad elérhető. A dokumentumból törölt távoli bejegyzés a következő sikeres
frissítéskor eltűnik a listából; a letöltött fájlokat nem töröljük automatikusan.
A beépített hangok nem módosíthatók/törölhetők ezzel a jegyzékkel.

Korlát: 1 MiB dokumentum, 500 új főmappa, 5000 almappa és 5000 hang,
50 MiB/hang, összesen 500 MiB aktív távoli hanganyag. A Drive letöltési kvótái
és a dokumentum elérhetősége a frissítést befolyásolhatják; offline használatot nem.

A forrás teszteléshez felülírható a `--dart-define=CONTENT_MANIFEST_URL=...`
Flutter build paraméterrel; csak HTTPS Google Docs/Drive cím engedélyezett.
