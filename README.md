# androiddevops

Reusable GitHub Actions for Android Gradle projects: one Gradle invocation,
CodeQL, MobSF, an APK bill, an emulator job, and a signed release APK.

Pin every `uses:` to a **commit SHA**. Pass that same SHA as `scripts_ref`.
A private caller also passes `checkout_token`.

This repository is public. The owner can set it private later. GitHub does not
let a public repository call a reusable workflow stored in a private
repository, so a public caller stops working on that day. A private caller,
such as [heimdall](https://github.com/pirlruc/heimdall), keeps working. The
fix for a public caller is to copy the workflow file at the pinned tag into
that caller.

[mat-aventuras](https://github.com/pirlruc/mat-aventuras) is the first caller.
[finsilo](https://github.com/pirlruc/finsilo) and heimdall still inline their
Android jobs.
