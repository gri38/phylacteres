# Phylactères

Add speech bubbles to your pictures.

# Release workflow

## 1. Prepare a release

Update `CHANGELOG.md` using the Keep a Changelog format.

Example:

```md
## 1.2.0

- Added something
- Fixed something
```

Then create and push a prepare tag:
```powershel
git tag prepare-1.2.0+7
git push origin prepare-1.2.0+7
```
This automatically triggers the GitHub Actions preparation workflow, which will:

- update pubspec.yaml
- generate Fastlane changelogs
- create and push branch: `release/1.2.0+7`
- create and push release tag: `1.2.0+7`
- build and publish the GitHub Release APK for IzzyOnDroid

## 2. Release on Google Play
Pull the generated release branch.
```powershel
git fetch
git checkout release/1.2.0+7
```
Then build the Android App Bundle:
```powershel
flutter clean
flutter build appbundle
```
Use the generated file: `build/app/outputs/bundle/release/app-release.aab` and upload it to Google Play Console.