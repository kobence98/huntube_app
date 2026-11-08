#!/usr/bin/env python3
"""Print catalog metadata for a local MP3 that has been uploaded to Drive."""
import argparse
import hashlib
import json
from pathlib import Path
import re
from urllib.parse import urlparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('file', type=Path)
parser.add_argument('--drive-id', required=True, help='Drive file ID or share URL')
parser.add_argument('--id', type=int, required=True, help='Permanent unique ID >= 1000000')
parser.add_argument('--title', required=True)
args = parser.parse_args()
file_id = args.drive_id
if file_id.startswith('https://'):
    match = re.fullmatch(r'/file/d/([A-Za-z0-9_-]+)/.*', urlparse(file_id).path)
    if not match or urlparse(file_id).hostname != 'drive.google.com':
        parser.error('Expected a drive.google.com/file/d/... share URL')
    file_id = match.group(1)
if not re.fullmatch(r'[A-Za-z0-9_-]{10,200}', file_id):
    parser.error('Invalid Drive file ID')
if not 1000000 <= args.id <= 2147483647:
    parser.error('ID must be between 1000000 and 2147483647')
if args.file.suffix.lower() != '.mp3':
    parser.error('Expected an MP3 file')
size = args.file.stat().st_size
if not 0 < size <= 50 * 1024 * 1024:
    parser.error('MP3 must be nonempty and at most 50 MiB')
with args.file.open('rb') as audio:
    hasher = hashlib.sha256()
    for chunk in iter(lambda: audio.read(1024 * 1024), b''):
        hasher.update(chunk)
    digest = hasher.hexdigest()
print(json.dumps(dict(id=args.id, title=args.title, driveFileId=file_id,
                     sha256=digest, bytes=size), ensure_ascii=False, indent=2))
