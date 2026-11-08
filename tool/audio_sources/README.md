# Audio source manifests

Each manifest records the source and clip boundaries in seconds. Clips retain
source stereo audio, encoded as 192 kbps MP3 at 44.1 kHz with tiny edit fades.

In `assets/text_files/file_names.txt`, an optional `/collection/<name>` line
immediately after the episode title assigns `herri`, `gyuru`, `srekk`, `karib` or `pom`.
Episodes without that line belong to Herri. The UI groups episodes independently
of their catalog order.

Append new episodes and sounds to the catalog: existing sequential sound IDs
are stored in favourites and must never be reassigned. The regression fixture
`test/fixtures/legacy_sound_assets.txt` protects the original 213 IDs from
before the 2Pom collection was introduced. Register all new MP3s in
`lib/generated/assets.gen.dart` as well as in the catalog.
