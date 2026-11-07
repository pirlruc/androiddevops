# Scorecard checks left open

These OpenSSF Scorecard alerts stay open on the repository. Nothing in this file dismisses or hides them.

Checked on 2026-11-07. This repository had no open Scorecard alerts. The checks below stay open when Scorecard reports them:

| Check | Why it stays open |
| --- | --- |
| Code-Review | One maintainer, so a second person does not approve changesets. The default-branch ruleset still requires a pull request. |
| Fuzzing | This repository publishes workflows and the Maestro image. It does not ship a library that parses untrusted input in-process. |
| CII-Best-Practices | No OpenSSF Best Practices badge is claimed. |
| Maintained | Leave the alert in place if Scorecard opens it. |
