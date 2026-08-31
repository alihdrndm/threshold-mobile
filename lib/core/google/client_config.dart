/// The user's own Android OAuth client id — public by nature for installed
/// apps (there is no secret; the redirect is bound to this app's package
/// name and signing certificate). Baked in as the default so nobody has to
/// type it on a phone keyboard; the Settings field can still override it.
const kDefaultGoogleClientId =
    '594332838822-ojgntdq9r56dcnla2lrkgoch8i42mk87.apps.googleusercontent.com';
