---
trigger: always_on
description: "Architecture guidelines for the privacy-first mental health platform"
---
# Architectural Guardrails
- **State Management:** Use Flutter BLoC exclusively for screen state transitions. Keep UI views completely clean of complex business logic.
- **Local Storage:** Use Hive for ultra-fast NoSQL local-first client caching.
- **Security:** Use the `encrypt` package for AES-256 client-side encryption. Raw text logs must never touch Cloud Firestore.
- **Performance:** Compute analytical correlations inside a separate Dart Isolate background thread to prevent UI frame drops.
- **Anonymity:** Strip Firebase UIDs from the community collections; use SHA-256 pseudonyms for posting.