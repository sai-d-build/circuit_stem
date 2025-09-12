# Observability & Logging

**Crash Reporting:** No Crashlytics/Sentry (0 occurrences); Firebase core present but no crashlytics setup.

**Breadcrumbs:** No (no events tracked).

**Sensitive Logs:** Some PII in auth (email/password in debug); recommend redaction in production.

**Telemetry:** Firebase (auth/firestore); missing funnel events (level complete, share).

**Log Policy:** StructuredLogger used, but no levels/redaction; suggest FirebasePerformance for diagnostics.