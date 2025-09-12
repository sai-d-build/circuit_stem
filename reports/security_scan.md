# Security Scan

No detected secrets (21 'password' mentions in auth params/code, no values/keys printed). 

Secure storage: No flutter_secure_storage; Firebase auth uses platform secure (Keychain/Keystore).

Over-broad permissions: Standard Flutter (internet for Firebase, storage for assets); no fine_location/camera evident.

Telemetry: Firebase (crashlytics/analytics?); PII logging in auth (email/password—recommend redaction).

Recommend scan with git-secrets or truffleHog.