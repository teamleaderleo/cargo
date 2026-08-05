# Cargo 16574 exact-version result

- Cargo packet start head: `a365453b3e5925c12a775738fb836f96947efe1c`
- Fieldwork run: `30842332925`
- Fieldwork job: `91782183881`
- Runner: Ubuntu 24.04.4
- Contract: one local path patch, one unreachable git source, exact dependency requirement `=0.1.0`
- Observed state: **exact-version fast path absent**
- Product outcome: Cargo contacted the original git source and failed there
- Production source changes: none
- External contact: none; unauthorized

This result is evidence for design, not an implementation approval. The broad and narrow fixtures both demonstrate that current Cargo does not treat the patch as a complete textual replacement of the original source.
