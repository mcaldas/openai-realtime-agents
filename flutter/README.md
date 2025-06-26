# Chat Supervisor Flutter App

This desktop Flutter app demonstrates the chat-supervisor agent pattern using GPT-4o realtime voice capabilities.

## Running

1. Copy `.env.example` to `.env` and fill in your OpenAI API key.
2. This project uses [FVM](https://fvm.app) for Flutter version management. The
   required Flutter SDK is installed automatically on first use, so you don't
   need to run `fvm install` yourself.
3. Run `fvm flutter pub get` inside the `flutter/` directory.
4. From the repo root, run `make -f Makefile.txt run` to generate the `macos/` project (if needed) and launch the app.
5. macOS users can verify a release build via `make -f Makefile.txt build-macos`.
