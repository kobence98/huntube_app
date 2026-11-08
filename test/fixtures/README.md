# Legacy favourites fixture

`isar_3_1_favourites.isar` was created locally with the original `isar: 3.1.0+1`
package and this repository's original `CachedLike` model and generated schema
from commit `6aa66b1`. It contains only synthetic favourite IDs `0`, `42`, `149`.

The database name is the original default `default`. The migration test copies
the fixture to a temporary directory, opens it with Isar Community, verifies all
three IDs, changes favourites, and reopens it to verify persistence. No user data
is included.
